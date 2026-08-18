import AVFoundation
import Foundation
import MediaPipeTasksVision
import UIKit

protocol MotionfitPoseEngineDelegate: AnyObject {
  func poseEngine(_ engine: MotionfitPoseEngine, didOutputPreview pixelBuffer: CVPixelBuffer)
  func poseEngine(_ engine: MotionfitPoseEngine, didOutput frame: MotionfitPoseFramePayload)
  func poseEngine(_ engine: MotionfitPoseEngine, didFail error: MotionfitPoseNativeError)
}

final class MotionfitPoseEngine: NSObject {
  weak var delegate: MotionfitPoseEngineDelegate?

  private let captureSession = AVCaptureSession()
  private let videoOutput = AVCaptureVideoDataOutput()
  private let sessionQueue = DispatchQueue(
    label: "com.namslab.motionfit_pose.capture",
    qos: .userInitiated
  )
  private let processingQueue = DispatchQueue(
    label: "com.namslab.motionfit_pose.inference",
    qos: .userInitiated
  )

  private var cameraInput: AVCaptureDeviceInput?
  private var observerTokens: [NSObjectProtocol] = []
  private var lastDeviceOrientation: UIDeviceOrientation = .portrait

  // Main-thread state.
  private var generation = 0
  private var isStarting = false
  private var isStarted = false
  private var isExplicitlyPaused = false
  private var isInterrupted = false
  private var isChangingCamera = false
  private var isChangingModel = false
  private var configuration: MotionfitPoseConfiguration?

  // Cross-queue lifecycle gate. No camera frame is inferred while this is false.
  private let lifecycleLock = NSLock()
  private var acceptedGeneration = 0
  private var acceptsCameraFrames = false
  private let videoRecordingLock = NSLock()
  private var retainsCaptureForVideoRecording = false

  // Processing-queue state.
  private var poseLandmarker: PoseLandmarker?
  private var processingGeneration = 0
  private var activeModel: MotionfitPoseModel = .lite
  private var activeTrackingProfile: MotionfitTrackingProfile = .squat
  private var targetFps = 30
  private var lastSubmittedUptime = 0.0
  private var lastSubmittedTimestampMs = -1
  private var inferenceInFlight = false
  private var inferenceContext: InferenceContext?
  private var pendingModelChange: PendingModelChange?
  private var pendingDisposeCompletion: (() -> Void)?
  private var frameId: Int64 = 0
  private var hadTrackedPerson = false
  private var consecutiveMissingFrames = 0
  private var lastInferenceErrorUptime = 0.0

  // Processing-queue recording state. The existing VideoDataOutput owns the
  // sample-buffer clock for preview, pose inference, and the silent MP4.
  private var videoWriter: AVAssetWriter?
  private var videoWriterInput: AVAssetWriterInput?
  private var videoPartialURL: URL?
  private var videoFinalURL: URL?
  private var videoOriginPresentationTime: CMTime?
  private var lastVideoElapsedUs: Int64 = 0
  private var pendingVideoStartCompletion:
    ((Result<MotionfitVideoRecordingStart, MotionfitPoseNativeError>) -> Void)?

  private struct InferenceContext {
    let landmarkerID: ObjectIdentifier
    let generation: Int
    let timestampMs: Int
    let startedUptime: Double
    let inputWidth: Int
    let inputHeight: Int
    let model: MotionfitPoseModel
    let videoElapsedUs: Int64?
  }

  private struct PendingModelChange {
    let generation: Int
    let model: MotionfitPoseModel
    let modelURL: URL
    let completion: (Result<Void, MotionfitPoseNativeError>) -> Void
  }

  override init() {
    super.init()
    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    installObservers()
  }

  deinit {
    observerTokens.forEach { NotificationCenter.default.removeObserver($0) }
    UIDevice.current.endGeneratingDeviceOrientationNotifications()
  }

  func start(
    configuration newConfiguration: MotionfitPoseConfiguration,
    completion: @escaping (Result<Void, MotionfitPoseNativeError>) -> Void
  ) {
    dispatchPrecondition(condition: .onQueue(.main))

    guard !isStarted && !isStarting else {
      completion(.failure(MotionfitPoseNativeError(
        "already_started",
        "The pose engine is already running. Dispose it before starting again."
      )))
      return
    }
    guard (15...30).contains(newConfiguration.targetFps) else {
      completion(.failure(MotionfitPoseNativeError(
        "invalid_arguments",
        "targetFps must be between 15 and 30."
      )))
      return
    }
    guard let modelURL = MotionfitModelLocator.url(for: newConfiguration.model) else {
      emitStatus(.modelUnavailable, model: newConfiguration.model)
      completion(.failure(MotionfitPoseNativeError(
        "model_unavailable",
        "The \(newConfiguration.model.rawValue) pose model is not bundled with the app.",
        details: [
          "expectedFile": "\(newConfiguration.model.resourceName).task",
          "resourceBundle": "motionfit_pose_models.bundle"
        ]
      )))
      return
    }

    isStarting = true
    isExplicitlyPaused = false
    generation += 1
    let operationGeneration = generation
    publishLifecycle(generation: operationGeneration, acceptsFrames: false)

    requestCameraAuthorization { [weak self] authorizationResult in
      guard let self else { return }
      guard self.isGenerationCurrent(operationGeneration) else {
        completion(.failure(Self.disposedError))
        return
      }

      switch authorizationResult {
      case .failure(let error):
        self.isStarting = false
        self.emitStatus(.cameraUnavailable, model: newConfiguration.model)
        completion(.failure(error))
      case .success:
        self.preparePoseLandmarker(
          configuration: newConfiguration,
          modelURL: modelURL,
          generation: operationGeneration,
          completion: completion
        )
      }
    }
  }

  func pause(completion: @escaping (Result<Void, MotionfitPoseNativeError>) -> Void) {
    dispatchPrecondition(condition: .onQueue(.main))
    guard isStarted else {
      completion(.failure(Self.notStartedError))
      return
    }

    isExplicitlyPaused = true
    setAcceptsCameraFrames(false)
    let keepCaptureRunning = videoRecordingRetainsCapture()
    sessionQueue.async { [weak self] in
      guard let self else { return }
      if self.captureSession.isRunning && !keepCaptureRunning {
        self.captureSession.stopRunning()
      }
      DispatchQueue.main.async { completion(.success(())) }
    }
  }

  func resume(completion: @escaping (Result<Void, MotionfitPoseNativeError>) -> Void) {
    dispatchPrecondition(condition: .onQueue(.main))
    guard isStarted else {
      completion(.failure(Self.notStartedError))
      return
    }

    isExplicitlyPaused = false
    startCaptureIfEligible(generation: generation, completion: completion)
  }

  func switchCamera(
    to camera: MotionfitCamera,
    completion: @escaping (Result<Void, MotionfitPoseNativeError>) -> Void
  ) {
    dispatchPrecondition(condition: .onQueue(.main))
    guard isStarted, var currentConfiguration = configuration else {
      completion(.failure(Self.notStartedError))
      return
    }
    guard !isChangingCamera && !isChangingModel else {
      completion(.failure(Self.busyError))
      return
    }
    guard !videoRecordingRetainsCapture() else {
      completion(.failure(Self.videoRecordingInProgressError))
      return
    }
    guard currentConfiguration.camera != camera else {
      completion(.success(()))
      return
    }

    isChangingCamera = true
    setAcceptsCameraFrames(false)
    let operationGeneration = generation
    let orientation = lastDeviceOrientation

    sessionQueue.async { [weak self] in
      guard let self, self.isGenerationCurrent(operationGeneration) else {
        DispatchQueue.main.async { completion(.failure(Self.disposedError)) }
        return
      }

      let replacementResult = self.replaceCameraInput(
        with: camera,
        orientation: orientation
      )
      DispatchQueue.main.async {
        guard self.generation == operationGeneration, self.isStarted else {
          completion(.failure(Self.disposedError))
          return
        }

        self.isChangingCamera = false
        switch replacementResult {
        case .failure(let error):
          self.refreshCaptureGate()
          completion(.failure(error))
        case .success:
          currentConfiguration = MotionfitPoseConfiguration(
            camera: camera,
            model: currentConfiguration.model,
            trackingProfile: currentConfiguration.trackingProfile,
            targetFps: currentConfiguration.targetFps,
            enableVideoRecording: currentConfiguration.enableVideoRecording
          )
          self.configuration = currentConfiguration
          self.startCaptureIfEligible(
            generation: operationGeneration,
            completion: completion
          )
        }
      }
    }
  }

  func setModel(
    _ model: MotionfitPoseModel,
    completion: @escaping (Result<Void, MotionfitPoseNativeError>) -> Void
  ) {
    dispatchPrecondition(condition: .onQueue(.main))
    guard isStarted, let currentConfiguration = configuration else {
      completion(.failure(Self.notStartedError))
      return
    }
    guard !isChangingModel && !isChangingCamera else {
      completion(.failure(Self.busyError))
      return
    }
    guard !videoRecordingRetainsCapture() else {
      completion(.failure(Self.videoRecordingInProgressError))
      return
    }
    guard currentConfiguration.model != model else {
      completion(.success(()))
      return
    }
    guard let modelURL = MotionfitModelLocator.url(for: model) else {
      emitStatus(.modelUnavailable, model: model)
      completion(.failure(MotionfitPoseNativeError(
        "model_unavailable",
        "The \(model.rawValue) pose model is not bundled with the app.",
        details: [
          "expectedFile": "\(model.resourceName).task",
          "resourceBundle": "motionfit_pose_models.bundle"
        ]
      )))
      return
    }

    isChangingModel = true
    setAcceptsCameraFrames(false)
    let operationGeneration = generation
    sessionQueue.async { [weak self] in
      guard let self else { return }
      if self.captureSession.isRunning {
        self.captureSession.stopRunning()
      }

      self.processingQueue.async {
        guard self.isGenerationCurrent(operationGeneration) else {
          DispatchQueue.main.async { completion(.failure(Self.disposedError)) }
          return
        }
        let request = PendingModelChange(
          generation: operationGeneration,
          model: model,
          modelURL: modelURL,
          completion: completion
        )
        if self.inferenceInFlight {
          self.pendingModelChange = request
        } else {
          self.performModelChange(request)
        }
      }
    }
  }

  func setTargetFps(
    _ fps: Int,
    completion: @escaping (Result<Void, MotionfitPoseNativeError>) -> Void
  ) {
    dispatchPrecondition(condition: .onQueue(.main))
    guard isStarted, let currentConfiguration = configuration else {
      completion(.failure(Self.notStartedError))
      return
    }
    guard (15...30).contains(fps) else {
      completion(.failure(MotionfitPoseNativeError(
        "invalid_arguments",
        "targetFps must be between 15 and 30."
      )))
      return
    }

    configuration = MotionfitPoseConfiguration(
      camera: currentConfiguration.camera,
      model: currentConfiguration.model,
      trackingProfile: currentConfiguration.trackingProfile,
      targetFps: fps,
      enableVideoRecording: currentConfiguration.enableVideoRecording
    )
    processingQueue.async { [weak self] in
      self?.targetFps = fps
      self?.lastSubmittedUptime = 0
      DispatchQueue.main.async { completion(.success(())) }
    }
  }

  func startVideoRecording(
    sessionId: String,
    completion: @escaping (
      Result<MotionfitVideoRecordingStart, MotionfitPoseNativeError>
    ) -> Void
  ) {
    dispatchPrecondition(condition: .onQueue(.main))
    guard isStarted, let configuration else {
      completion(.failure(Self.notStartedError))
      return
    }
    guard configuration.enableVideoRecording else {
      completion(.failure(MotionfitPoseNativeError(
        "video_not_supported",
        "Video recording was not enabled when the pose engine started."
      )))
      return
    }
    guard !isChangingCamera && !isChangingModel else {
      completion(.failure(Self.busyError))
      return
    }
    guard UIApplication.shared.applicationState == .active, !isInterrupted else {
      completion(.failure(MotionfitPoseNativeError(
        "camera_unavailable",
        "The app must be active before workout video recording can start."
      )))
      return
    }
    guard !videoRecordingRetainsCapture() else {
      completion(.failure(Self.videoRecordingInProgressError))
      return
    }

    let trimmedSessionId = sessionId.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedSessionId.isEmpty else {
      completion(.failure(MotionfitPoseNativeError(
        "invalid_arguments",
        "sessionId must not be empty."
      )))
      return
    }

    let operationGeneration = generation
    setVideoRecordingRetainsCapture(true)
    processingQueue.async { [weak self] in
      guard let self else { return }
      do {
        let directory = try self.workoutVideoDirectory()
        self.cleanupPartialRecordings(in: directory)
        let basename = "workout_\(self.sanitizeSessionId(trimmedSessionId))"
        let partialURL = directory.appendingPathComponent("\(basename).partial.mp4")
        let finalURL = directory.appendingPathComponent("\(basename).mp4")
        self.pruneCompletedRecordings(in: directory, protectedURL: finalURL)
        if FileManager.default.fileExists(atPath: partialURL.path) {
          try FileManager.default.removeItem(at: partialURL)
        }
        self.videoPartialURL = partialURL
        self.videoFinalURL = finalURL
        self.videoOriginPresentationTime = nil
        self.lastVideoElapsedUs = 0
        self.pendingVideoStartCompletion = completion
      } catch {
        self.setVideoRecordingRetainsCapture(false)
        DispatchQueue.main.async {
          completion(.failure(MotionfitPoseNativeError(
            "video_storage_failed",
            "The private workout video directory is unavailable.",
            details: ["cause": error.localizedDescription]
          )))
          self.refreshCaptureAfterVideoRecording()
        }
        return
      }

      DispatchQueue.main.async {
        guard self.generation == operationGeneration, self.isStarted else {
          self.processingQueue.async {
            self.discardVideoRecording(startError: Self.disposedError)
          }
          return
        }
        self.startCaptureIfEligible(generation: operationGeneration) { result in
          if case .failure(let error) = result {
            self.processingQueue.async {
              self.discardVideoRecording(startError: error)
            }
          }
        }
      }
    }
  }

  func stopVideoRecording(
    completion: @escaping (
      Result<MotionfitVideoRecordingResult, MotionfitPoseNativeError>
    ) -> Void
  ) {
    dispatchPrecondition(condition: .onQueue(.main))
    guard isStarted else {
      completion(.failure(Self.notStartedError))
      return
    }
    guard videoRecordingRetainsCapture() else {
      completion(.failure(Self.videoNotRecordingError))
      return
    }

    setVideoRecordingRetainsCapture(false)
    processingQueue.async { [weak self] in
      guard let self else { return }
      self.finishVideoRecording(completion: completion)
    }
  }

  func cancelVideoRecording(
    completion: @escaping (Result<Void, MotionfitPoseNativeError>) -> Void
  ) {
    dispatchPrecondition(condition: .onQueue(.main))
    guard isStarted else {
      completion(.failure(Self.notStartedError))
      return
    }
    guard videoRecordingRetainsCapture() else {
      completion(.success(()))
      return
    }

    setVideoRecordingRetainsCapture(false)
    processingQueue.async { [weak self] in
      guard let self else { return }
      self.discardVideoRecording(startError: MotionfitPoseNativeError(
        "video_recording_cancelled",
        "The workout video recording was cancelled."
      ))
      DispatchQueue.main.async {
        completion(.success(()))
        self.refreshCaptureAfterVideoRecording()
      }
    }
  }

  func dispose(completion: @escaping () -> Void) {
    dispatchPrecondition(condition: .onQueue(.main))

    generation += 1
    let disposalGeneration = generation
    publishLifecycle(generation: disposalGeneration, acceptsFrames: false)
    isStarting = false
    isStarted = false
    isExplicitlyPaused = true
    isInterrupted = false
    isChangingCamera = false
    isChangingModel = false
    configuration = nil
    setVideoRecordingRetainsCapture(false)

    sessionQueue.async { [weak self] in
      guard let self else {
        DispatchQueue.main.async(execute: completion)
        return
      }
      self.teardownCaptureSession()
      self.processingQueue.async {
        if let pendingModelChange = self.pendingModelChange {
          DispatchQueue.main.async {
            pendingModelChange.completion(.failure(Self.disposedError))
          }
          self.pendingModelChange = nil
        }

        self.processingGeneration = disposalGeneration
        if self.inferenceInFlight {
          self.pendingDisposeCompletion = completion
        } else {
          self.finishProcessingDispose(completion: completion)
        }
      }
    }
  }

  private func preparePoseLandmarker(
    configuration newConfiguration: MotionfitPoseConfiguration,
    modelURL: URL,
    generation operationGeneration: Int,
    completion: @escaping (Result<Void, MotionfitPoseNativeError>) -> Void
  ) {
    processingQueue.async { [weak self] in
      guard let self, self.isGenerationCurrent(operationGeneration) else {
        DispatchQueue.main.async { completion(.failure(Self.disposedError)) }
        return
      }

      do {
        let landmarker = try self.makePoseLandmarker(modelURL: modelURL)
        self.poseLandmarker = landmarker
        self.processingGeneration = operationGeneration
        self.activeModel = newConfiguration.model
        self.activeTrackingProfile = newConfiguration.trackingProfile
        self.targetFps = newConfiguration.targetFps
        self.resetInferenceState()
      } catch {
        let nativeError = MotionfitPoseNativeError(
          "model_initialization_failed",
          "MediaPipe could not initialize the \(newConfiguration.model.rawValue) pose model.",
          details: ["cause": error.localizedDescription]
        )
        DispatchQueue.main.async {
          self.isStarting = false
          completion(.failure(nativeError))
        }
        return
      }

      guard self.isGenerationCurrent(operationGeneration) else {
        self.poseLandmarker = nil
        DispatchQueue.main.async { completion(.failure(Self.disposedError)) }
        return
      }

      let orientation = DispatchQueue.main.sync {
        self.resolveDeviceOrientation()
      }
      self.sessionQueue.async {
        guard self.isGenerationCurrent(operationGeneration) else {
          DispatchQueue.main.async { completion(.failure(Self.disposedError)) }
          return
        }

        let captureResult = self.configureCaptureSession(
          camera: newConfiguration.camera,
          orientation: orientation
        )
        DispatchQueue.main.async {
          guard self.generation == operationGeneration else {
            completion(.failure(Self.disposedError))
            return
          }

          switch captureResult {
          case .failure(let error):
            self.isStarting = false
            self.processingQueue.async {
              self.poseLandmarker = nil
              self.resetInferenceState()
            }
            completion(.failure(error))
          case .success:
            self.configuration = newConfiguration
            self.isStarting = false
            self.isStarted = true
            self.startCaptureIfEligible(
              generation: operationGeneration,
              completion: completion
            )
          }
        }
      }
    }
  }

  private func requestCameraAuthorization(
    completion: @escaping (Result<Void, MotionfitPoseNativeError>) -> Void
  ) {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      completion(.success(()))
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { granted in
        DispatchQueue.main.async {
          if granted {
            completion(.success(()))
          } else {
            completion(.failure(MotionfitPoseNativeError(
              "camera_permission_denied",
              "Camera permission is required for real-time pose detection."
            )))
          }
        }
      }
    case .denied, .restricted:
      completion(.failure(MotionfitPoseNativeError(
        "camera_permission_denied",
        "Camera permission is denied or restricted. Enable it in Settings."
      )))
    @unknown default:
      completion(.failure(MotionfitPoseNativeError(
        "camera_unavailable",
        "The camera authorization state is unsupported."
      )))
    }
  }

  private func configureCaptureSession(
    camera: MotionfitCamera,
    orientation: UIDeviceOrientation
  ) -> Result<Void, MotionfitPoseNativeError> {
    if captureSession.isRunning {
      captureSession.stopRunning()
    }

    captureSession.beginConfiguration()
    defer { captureSession.commitConfiguration() }

    captureSession.inputs.forEach(captureSession.removeInput)
    captureSession.outputs.forEach(captureSession.removeOutput)
    cameraInput = nil

    if captureSession.canSetSessionPreset(.vga640x480) {
      captureSession.sessionPreset = .vga640x480
    } else {
      captureSession.sessionPreset = .high
    }

    guard let device = cameraDevice(for: camera) else {
      return .failure(MotionfitPoseNativeError(
        "camera_unavailable",
        "The requested \(camera.rawValue) camera is unavailable."
      ))
    }
    configureDeviceForStableCapture(device)

    do {
      let input = try AVCaptureDeviceInput(device: device)
      guard captureSession.canAddInput(input) else {
        return .failure(MotionfitPoseNativeError(
          "camera_configuration_failed",
          "The requested camera input cannot be added to the capture session."
        ))
      }
      captureSession.addInput(input)
      cameraInput = input
    } catch {
      return .failure(MotionfitPoseNativeError(
        "camera_configuration_failed",
        "The requested camera input could not be created.",
        details: ["cause": error.localizedDescription]
      ))
    }

    videoOutput.alwaysDiscardsLateVideoFrames = true
    videoOutput.videoSettings = [
      kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
    ]
    videoOutput.setSampleBufferDelegate(self, queue: processingQueue)
    guard captureSession.canAddOutput(videoOutput) else {
      return .failure(MotionfitPoseNativeError(
        "camera_configuration_failed",
        "The BGRA video output cannot be added to the capture session."
      ))
    }
    captureSession.addOutput(videoOutput)
    configureVideoConnection(orientation: orientation)
    return .success(())
  }

  private func replaceCameraInput(
    with camera: MotionfitCamera,
    orientation: UIDeviceOrientation
  ) -> Result<Void, MotionfitPoseNativeError> {
    guard let device = cameraDevice(for: camera) else {
      return .failure(MotionfitPoseNativeError(
        "camera_unavailable",
        "The requested \(camera.rawValue) camera is unavailable."
      ))
    }
    configureDeviceForStableCapture(device)

    let oldInput = cameraInput
    captureSession.beginConfiguration()
    defer { captureSession.commitConfiguration() }

    if let oldInput {
      captureSession.removeInput(oldInput)
    }

    do {
      let newInput = try AVCaptureDeviceInput(device: device)
      guard captureSession.canAddInput(newInput) else {
        restoreCameraInput(oldInput)
        return .failure(MotionfitPoseNativeError(
          "camera_configuration_failed",
          "The requested camera input cannot be added to the capture session."
        ))
      }
      captureSession.addInput(newInput)
      cameraInput = newInput
      configureVideoConnection(orientation: orientation)
      return .success(())
    } catch {
      restoreCameraInput(oldInput)
      return .failure(MotionfitPoseNativeError(
        "camera_configuration_failed",
        "The requested camera input could not be created.",
        details: ["cause": error.localizedDescription]
      ))
    }
  }

  private func restoreCameraInput(_ input: AVCaptureDeviceInput?) {
    guard let input, captureSession.canAddInput(input) else {
      cameraInput = nil
      return
    }
    captureSession.addInput(input)
    cameraInput = input
  }

  private func cameraDevice(for camera: MotionfitCamera) -> AVCaptureDevice? {
    let position: AVCaptureDevice.Position = camera == .front ? .front : .back
    return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
  }

  private func configureDeviceForStableCapture(_ device: AVCaptureDevice) {
    if #available(iOS 14.5, *) {
      // Center Stage continuously pans and changes the crop on supported
      // iPads. A fixed field of view is required for stable pose geometry.
      AVCaptureDevice.centerStageControlMode = .app
      AVCaptureDevice.isCenterStageEnabled = false
    }

    do {
      try device.lockForConfiguration()
      defer { device.unlockForConfiguration() }

      let neutralZoom = min(
        max(1.0, device.minAvailableVideoZoomFactor),
        device.maxAvailableVideoZoomFactor
      )
      device.videoZoomFactor = neutralZoom
      if device.isFocusModeSupported(.continuousAutoFocus) {
        device.focusMode = .continuousAutoFocus
      }
      if device.isExposureModeSupported(.continuousAutoExposure) {
        device.exposureMode = .continuousAutoExposure
      }
      if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
        device.whiteBalanceMode = .continuousAutoWhiteBalance
      }
      if device.isSmoothAutoFocusSupported {
        device.isSmoothAutoFocusEnabled = true
      }
      device.isSubjectAreaChangeMonitoringEnabled = true
    } catch {
      // Capture can still proceed with the device's default configuration.
    }
  }

  private func configureVideoConnection(orientation: UIDeviceOrientation) {
    guard let connection = videoOutput.connection(with: .video) else { return }

    if connection.isVideoMirroringSupported {
      connection.automaticallyAdjustsVideoMirroring = false
      connection.isVideoMirrored = false
    }

    if connection.isVideoOrientationSupported {
      // Keep capture orientation tied to the app interface. A horizon-based
      // rotation can briefly flip an iPad that is flat or still settling.
      connection.videoOrientation = legacyVideoOrientation(for: orientation)
    } else if #available(iOS 17.0, *), let device = cameraInput?.device {
      let coordinator = AVCaptureDevice.RotationCoordinator(
        device: device,
        previewLayer: nil
      )
      let angle = coordinator.videoRotationAngleForHorizonLevelCapture
      if connection.isVideoRotationAngleSupported(angle) {
        connection.videoRotationAngle = angle
      }
    }
  }

  private func resolveDeviceOrientation() -> UIDeviceOrientation {
    let deviceOrientation = UIDevice.current.orientation
    if deviceOrientation == .portrait ||
      deviceOrientation == .portraitUpsideDown ||
      deviceOrientation == .landscapeLeft ||
      deviceOrientation == .landscapeRight {
      lastDeviceOrientation = deviceOrientation
      return deviceOrientation
    }

    let interfaceOrientation = UIApplication.shared.connectedScenes
      .compactMap { ($0 as? UIWindowScene)?.interfaceOrientation }
      .first
    let resolved: UIDeviceOrientation
    switch interfaceOrientation {
    case .portraitUpsideDown:
      resolved = .portraitUpsideDown
    case .landscapeLeft:
      resolved = .landscapeLeft
    case .landscapeRight:
      resolved = .landscapeRight
    case .portrait:
      resolved = .portrait
    default:
      resolved = lastDeviceOrientation
    }
    lastDeviceOrientation = resolved
    return resolved
  }

  @available(iOS, introduced: 4.0, deprecated: 17.0)
  private func legacyVideoOrientation(
    for orientation: UIDeviceOrientation
  ) -> AVCaptureVideoOrientation {
    switch orientation {
    case .landscapeLeft:
      return .landscapeRight
    case .landscapeRight:
      return .landscapeLeft
    case .portraitUpsideDown:
      return .portraitUpsideDown
    default:
      return .portrait
    }
  }

  private func startCaptureIfEligible(
    generation operationGeneration: Int,
    completion: ((Result<Void, MotionfitPoseNativeError>) -> Void)? = nil
  ) {
    dispatchPrecondition(condition: .onQueue(.main))
    guard self.generation == operationGeneration, isStarted else {
      completion?(.failure(Self.disposedError))
      return
    }

    guard captureShouldRun else {
      setAcceptsCameraFrames(false)
      completion?(.success(()))
      return
    }

    setAcceptsCameraFrames(true)
    sessionQueue.async { [weak self] in
      guard let self, self.isGenerationCurrent(operationGeneration) else {
        DispatchQueue.main.async { completion?(.failure(Self.disposedError)) }
        return
      }
      if !self.captureSession.isRunning {
        self.captureSession.startRunning()
      }
      let isRunning = self.captureSession.isRunning
      DispatchQueue.main.async {
        guard self.generation == operationGeneration, self.isStarted else {
          completion?(.failure(Self.disposedError))
          return
        }
        if isRunning {
          completion?(.success(()))
        } else {
          self.setAcceptsCameraFrames(false)
          completion?(.failure(MotionfitPoseNativeError(
            "camera_unavailable",
            "The camera capture session did not start."
          )))
        }
      }
    }
  }

  private var captureShouldRun: Bool {
    isStarted && !isExplicitlyPaused && !isInterrupted && !isChangingModel &&
      !isChangingCamera && UIApplication.shared.applicationState == .active
  }

  private func refreshCaptureGate() {
    dispatchPrecondition(condition: .onQueue(.main))
    setAcceptsCameraFrames(captureShouldRun)
  }

  private func teardownCaptureSession() {
    videoOutput.setSampleBufferDelegate(nil, queue: nil)
    if captureSession.isRunning {
      captureSession.stopRunning()
    }
    captureSession.beginConfiguration()
    captureSession.inputs.forEach(captureSession.removeInput)
    captureSession.outputs.forEach(captureSession.removeOutput)
    captureSession.commitConfiguration()
    cameraInput = nil
  }

  private func appendVideoSample(_ sampleBuffer: CMSampleBuffer) -> Int64? {
    dispatchPrecondition(condition: .onQueue(processingQueue))
    guard videoRecordingRetainsCapture(),
          CMSampleBufferDataIsReady(sampleBuffer),
          videoPartialURL != nil else {
      return nil
    }

    do {
      if videoWriter == nil {
        try startVideoWriter(with: sampleBuffer)
        return 0
      }
      guard let writer = videoWriter,
            let input = videoWriterInput,
            let origin = videoOriginPresentationTime else {
        return nil
      }
      guard writer.status == .writing else {
        throw writer.error ?? MotionfitPoseNativeError(
          "video_recording_failed",
          "The workout video writer stopped unexpectedly."
        )
      }

      let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
      let elapsedSeconds = CMTimeGetSeconds(
        CMTimeSubtract(presentationTime, origin)
      )
      let elapsedUs = elapsedSeconds.isFinite
        ? max(0, Int64(elapsedSeconds * 1_000_000))
        : lastVideoElapsedUs

      if input.isReadyForMoreMediaData && !input.append(sampleBuffer) {
        throw writer.error ?? MotionfitPoseNativeError(
          "video_recording_failed",
          "The workout video frame could not be written."
        )
      }
      lastVideoElapsedUs = max(lastVideoElapsedUs, elapsedUs)
      return lastVideoElapsedUs
    } catch {
      let nativeError = MotionfitPoseNativeError(
        "video_recording_failed",
        "The workout video could not be recorded.",
        details: ["cause": error.localizedDescription]
      )
      setVideoRecordingRetainsCapture(false)
      discardVideoRecording(startError: nativeError)
      DispatchQueue.main.async { [weak self] in
        self?.refreshCaptureAfterVideoRecording()
      }
      return nil
    }
  }

  private func startVideoWriter(with sampleBuffer: CMSampleBuffer) throws {
    dispatchPrecondition(condition: .onQueue(processingQueue))
    guard let partialURL = videoPartialURL,
          let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else {
      throw MotionfitPoseNativeError(
        "video_recording_failed",
        "The first workout video frame has no format description."
      )
    }

    let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
    let width = max(1, Int(dimensions.width))
    let height = max(1, Int(dimensions.height))
    let writer = try AVAssetWriter(outputURL: partialURL, fileType: .mp4)
    let settings: [String: Any] = [
      AVVideoCodecKey: AVVideoCodecType.h264,
      AVVideoWidthKey: width,
      AVVideoHeightKey: height,
      AVVideoCompressionPropertiesKey: [
        AVVideoAverageBitRateKey: 1_500_000,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264BaselineAutoLevel
      ]
    ]
    guard writer.canApply(outputSettings: settings, forMediaType: .video) else {
      throw MotionfitPoseNativeError(
        "video_not_supported",
        "This device cannot encode the workout video as H.264."
      )
    }

    let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
    input.expectsMediaDataInRealTime = true
    guard writer.canAdd(input) else {
      throw MotionfitPoseNativeError(
        "video_not_supported",
        "The workout video input cannot be added to the writer."
      )
    }
    writer.add(input)

    let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
    guard writer.startWriting() else {
      throw writer.error ?? MotionfitPoseNativeError(
        "video_recording_failed",
        "The workout video writer could not start."
      )
    }
    writer.startSession(atSourceTime: presentationTime)
    guard input.append(sampleBuffer) else {
      throw writer.error ?? MotionfitPoseNativeError(
        "video_recording_failed",
        "The first workout video frame could not be written."
      )
    }

    videoWriter = writer
    videoWriterInput = input
    videoOriginPresentationTime = presentationTime
    lastVideoElapsedUs = 0
    if let startCompletion = pendingVideoStartCompletion {
      pendingVideoStartCompletion = nil
      let originUs = Int64(ProcessInfo.processInfo.systemUptime * 1_000_000)
      DispatchQueue.main.async {
        startCompletion(.success(MotionfitVideoRecordingStart(
          timelineOriginUs: originUs
        )))
      }
    }
  }

  private func finishVideoRecording(
    completion: @escaping (
      Result<MotionfitVideoRecordingResult, MotionfitPoseNativeError>
    ) -> Void
  ) {
    dispatchPrecondition(condition: .onQueue(processingQueue))
    guard let writer = videoWriter,
          let input = videoWriterInput,
          let partialURL = videoPartialURL,
          let finalURL = videoFinalURL else {
      let error = MotionfitPoseNativeError(
        "video_recording_failed",
        "The workout video ended before a frame was recorded."
      )
      discardVideoRecording(startError: error)
      DispatchQueue.main.async { completion(.failure(error)) }
      return
    }

    let durationMilliseconds = max(0, lastVideoElapsedUs / 1_000)
    input.markAsFinished()
    writer.finishWriting { [weak self] in
      guard let self else { return }
      self.processingQueue.async {
        guard writer.status == .completed else {
          let error = MotionfitPoseNativeError(
            "video_recording_failed",
            "The workout video could not be finalized.",
            details: ["cause": writer.error?.localizedDescription ?? "unknown"]
          )
          self.discardVideoRecording(startError: error)
          DispatchQueue.main.async {
            completion(.failure(error))
            self.refreshCaptureAfterVideoRecording()
          }
          return
        }

        do {
          if FileManager.default.fileExists(atPath: finalURL.path) {
            try FileManager.default.removeItem(at: finalURL)
          }
          try FileManager.default.moveItem(at: partialURL, to: finalURL)
          self.excludeFromBackup(finalURL)
          self.pruneCompletedRecordings(
            in: finalURL.deletingLastPathComponent(),
            protectedURL: finalURL
          )
          self.resetVideoRecordingState()
          DispatchQueue.main.async {
            completion(.success(MotionfitVideoRecordingResult(
              path: finalURL.path,
              durationMilliseconds: durationMilliseconds
            )))
            self.refreshCaptureAfterVideoRecording()
          }
        } catch {
          let nativeError = MotionfitPoseNativeError(
            "video_storage_failed",
            "The finalized workout video could not be stored.",
            details: ["cause": error.localizedDescription]
          )
          self.discardVideoRecording(startError: nativeError)
          DispatchQueue.main.async {
            completion(.failure(nativeError))
            self.refreshCaptureAfterVideoRecording()
          }
        }
      }
    }
  }

  private func discardVideoRecording(startError: MotionfitPoseNativeError) {
    dispatchPrecondition(condition: .onQueue(processingQueue))
    setVideoRecordingRetainsCapture(false)
    let startCompletion = pendingVideoStartCompletion
    let partialURL = videoPartialURL
    if videoWriter?.status == .writing {
      videoWriterInput?.markAsFinished()
      videoWriter?.cancelWriting()
    }
    resetVideoRecordingState()
    if let partialURL, FileManager.default.fileExists(atPath: partialURL.path) {
      try? FileManager.default.removeItem(at: partialURL)
    }
    if let startCompletion {
      DispatchQueue.main.async { startCompletion(.failure(startError)) }
    }
  }

  private func resetVideoRecordingState() {
    videoWriter = nil
    videoWriterInput = nil
    videoPartialURL = nil
    videoFinalURL = nil
    videoOriginPresentationTime = nil
    lastVideoElapsedUs = 0
    pendingVideoStartCompletion = nil
  }

  private func cancelVideoRecordingForLifecycleChange() {
    dispatchPrecondition(condition: .onQueue(.main))
    guard videoRecordingRetainsCapture() else { return }
    setVideoRecordingRetainsCapture(false)
    processingQueue.async { [weak self] in
      guard let self else { return }
      self.discardVideoRecording(startError: MotionfitPoseNativeError(
        "video_recording_interrupted",
        "The workout video was cancelled because camera capture was interrupted."
      ))
    }
  }

  private func refreshCaptureAfterVideoRecording() {
    dispatchPrecondition(condition: .onQueue(.main))
    guard isStarted else { return }
    if captureShouldRun {
      startCaptureIfEligible(generation: generation)
      return
    }
    setAcceptsCameraFrames(false)
    sessionQueue.async { [weak self] in
      guard let self, self.captureSession.isRunning else { return }
      self.captureSession.stopRunning()
    }
  }

  private func workoutVideoDirectory() throws -> URL {
    guard let applicationSupport = FileManager.default.urls(
      for: .applicationSupportDirectory,
      in: .userDomainMask
    ).first else {
      throw MotionfitPoseNativeError(
        "video_storage_failed",
        "The Application Support directory is unavailable."
      )
    }
    let directory = applicationSupport.appendingPathComponent(
      "motionfit_workout_videos",
      isDirectory: true
    )
    try FileManager.default.createDirectory(
      at: directory,
      withIntermediateDirectories: true
    )
    excludeFromBackup(directory)
    return directory
  }

  private func excludeFromBackup(_ url: URL) {
    var mutableURL = url
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try? mutableURL.setResourceValues(values)
  }

  private func cleanupPartialRecordings(in directory: URL) {
    guard let contents = try? FileManager.default.contentsOfDirectory(
      at: directory,
      includingPropertiesForKeys: nil,
      options: [.skipsHiddenFiles]
    ) else { return }
    for url in contents where url.lastPathComponent.hasSuffix(".partial.mp4") {
      try? FileManager.default.removeItem(at: url)
    }
  }

  private func pruneCompletedRecordings(in directory: URL, protectedURL: URL?) {
    let keys: Set<URLResourceKey> = [
      .contentModificationDateKey,
      .fileSizeKey,
      .isRegularFileKey
    ]
    guard let contents = try? FileManager.default.contentsOfDirectory(
      at: directory,
      includingPropertiesForKeys: Array(keys),
      options: [.skipsHiddenFiles]
    ) else { return }
    let files = contents.compactMap { url -> (URL, Date, Int64)? in
      guard url.pathExtension.lowercased() == "mp4",
            url != protectedURL,
            let values = try? url.resourceValues(forKeys: keys),
            values.isRegularFile == true else { return nil }
      return (
        url,
        values.contentModificationDate ?? .distantPast,
        Int64(values.fileSize ?? 0)
      )
    }.sorted { $0.1 < $1.1 }

    let protectedBytes: Int64
    if let protectedURL,
       let values = try? protectedURL.resourceValues(forKeys: [.fileSizeKey]) {
      protectedBytes = Int64(values.fileSize ?? 0)
    } else {
      protectedBytes = 0
    }
    var totalBytes = files.reduce(protectedBytes) { $0 + $1.2 }
    let limit: Int64 = 2 * 1_024 * 1_024 * 1_024
    for (url, _, size) in files where totalBytes > limit {
      if (try? FileManager.default.removeItem(at: url)) != nil {
        totalBytes -= size
      }
    }
  }

  private func sanitizeSessionId(_ sessionId: String) -> String {
    let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
    let scalars = sessionId.unicodeScalars.prefix(96).map { scalar in
      allowed.contains(scalar) ? Character(String(scalar)) : "_"
    }
    let sanitized = String(scalars)
    return sanitized.isEmpty ? "session" : sanitized
  }

  private func makePoseLandmarker(modelURL: URL) throws -> PoseLandmarker {
    let options = PoseLandmarkerOptions()
    options.baseOptions.modelAssetPath = modelURL.path
    options.runningMode = .liveStream
    // Match motion-fit3's mobile worker: one person and the Lite model's
    // production confidence thresholds. MediaPipe still returns all 33
    // landmarks when only part of the body is visible.
    options.numPoses = 1
    options.minPoseDetectionConfidence = 0.4
    options.minPosePresenceConfidence = 0.4
    options.minTrackingConfidence = 0.5
    options.shouldOutputSegmentationMasks = false
    options.poseLandmarkerLiveStreamDelegate = self
    return try PoseLandmarker(options: options)
  }

  private func performModelChange(_ request: PendingModelChange) {
    dispatchPrecondition(condition: .onQueue(processingQueue))
    guard isGenerationCurrent(request.generation) else {
      DispatchQueue.main.async { request.completion(.failure(Self.disposedError)) }
      return
    }

    let changeResult: Result<Void, MotionfitPoseNativeError>
    do {
      let replacement = try makePoseLandmarker(modelURL: request.modelURL)
      poseLandmarker = replacement
      activeModel = request.model
      resetInferenceState(resetFrameCounter: false)
      changeResult = .success(())
    } catch {
      changeResult = .failure(MotionfitPoseNativeError(
        "model_initialization_failed",
        "MediaPipe could not initialize the \(request.model.rawValue) pose model.",
        details: ["cause": error.localizedDescription]
      ))
    }

    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      guard self.generation == request.generation, self.isStarted else {
        request.completion(.failure(Self.disposedError))
        return
      }

      self.isChangingModel = false
      if case .success = changeResult, let oldConfiguration = self.configuration {
        self.configuration = MotionfitPoseConfiguration(
          camera: oldConfiguration.camera,
          model: request.model,
          trackingProfile: oldConfiguration.trackingProfile,
          targetFps: oldConfiguration.targetFps,
          enableVideoRecording: oldConfiguration.enableVideoRecording
        )
      }

      self.startCaptureIfEligible(generation: request.generation) { restartResult in
        switch (changeResult, restartResult) {
        case (.failure(let error), _):
          request.completion(.failure(error))
        case (.success, .failure(let error)):
          request.completion(.failure(error))
        case (.success, .success):
          request.completion(.success(()))
        }
      }
    }
  }

  private func finishProcessingDispose(completion: @escaping () -> Void) {
    dispatchPrecondition(condition: .onQueue(processingQueue))
    discardVideoRecording(startError: Self.disposedError)
    poseLandmarker = nil
    inferenceContext = nil
    inferenceInFlight = false
    pendingModelChange = nil
    pendingDisposeCompletion = nil
    resetInferenceState()
    DispatchQueue.main.async(execute: completion)
  }

  private func resetInferenceState(resetFrameCounter: Bool = true) {
    lastSubmittedUptime = 0
    lastSubmittedTimestampMs = -1
    inferenceInFlight = false
    inferenceContext = nil
    if resetFrameCounter {
      frameId = 0
    }
    hadTrackedPerson = false
    consecutiveMissingFrames = 0
    lastInferenceErrorUptime = 0
  }

  private func publishLifecycle(generation: Int, acceptsFrames: Bool) {
    lifecycleLock.lock()
    acceptedGeneration = generation
    acceptsCameraFrames = acceptsFrames
    lifecycleLock.unlock()
  }

  private func setAcceptsCameraFrames(_ value: Bool) {
    lifecycleLock.lock()
    acceptsCameraFrames = value
    lifecycleLock.unlock()
  }

  private func lifecycleSnapshot() -> (generation: Int, acceptsFrames: Bool) {
    lifecycleLock.lock()
    let snapshot = (acceptedGeneration, acceptsCameraFrames)
    lifecycleLock.unlock()
    return snapshot
  }

  private func isGenerationCurrent(_ expectedGeneration: Int) -> Bool {
    lifecycleLock.lock()
    let isCurrent = acceptedGeneration == expectedGeneration
    lifecycleLock.unlock()
    return isCurrent
  }

  private func videoRecordingRetainsCapture() -> Bool {
    videoRecordingLock.lock()
    let value = retainsCaptureForVideoRecording
    videoRecordingLock.unlock()
    return value
  }

  private func setVideoRecordingRetainsCapture(_ value: Bool) {
    videoRecordingLock.lock()
    retainsCaptureForVideoRecording = value
    videoRecordingLock.unlock()
  }

  private func installObservers() {
    let center = NotificationCenter.default
    observerTokens.append(center.addObserver(
      forName: UIDevice.orientationDidChangeNotification,
      object: UIDevice.current,
      queue: .main
    ) { [weak self] _ in
      self?.deviceOrientationDidChange()
    })
    observerTokens.append(center.addObserver(
      forName: UIApplication.willResignActiveNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.applicationDidEnterBackground()
    })
    observerTokens.append(center.addObserver(
      forName: UIApplication.didEnterBackgroundNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.applicationDidEnterBackground()
    })
    observerTokens.append(center.addObserver(
      forName: UIApplication.didBecomeActiveNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.applicationDidBecomeActive()
    })
    observerTokens.append(center.addObserver(
      forName: .AVCaptureSessionWasInterrupted,
      object: captureSession,
      queue: .main
    ) { [weak self] _ in
      self?.captureSessionWasInterrupted()
    })
    observerTokens.append(center.addObserver(
      forName: .AVCaptureSessionInterruptionEnded,
      object: captureSession,
      queue: .main
    ) { [weak self] _ in
      self?.captureSessionInterruptionEnded()
    })
    observerTokens.append(center.addObserver(
      forName: .AVCaptureSessionRuntimeError,
      object: captureSession,
      queue: .main
    ) { [weak self] notification in
      self?.captureSessionRuntimeError(notification)
    })
  }

  private func deviceOrientationDidChange() {
    let orientation = UIDevice.current.orientation
    guard orientation == .portrait || orientation == .portraitUpsideDown ||
      orientation == .landscapeLeft || orientation == .landscapeRight else {
      return
    }
    lastDeviceOrientation = orientation
    sessionQueue.async { [weak self] in
      self?.configureVideoConnection(orientation: orientation)
    }
  }

  private func applicationDidEnterBackground() {
    guard isStarted else { return }
    setAcceptsCameraFrames(false)
    cancelVideoRecordingForLifecycleChange()
    sessionQueue.async { [weak self] in
      guard let self, self.captureSession.isRunning else { return }
      self.captureSession.stopRunning()
    }
  }

  private func applicationDidBecomeActive() {
    guard isStarted else { return }
    startCaptureIfEligible(generation: generation)
  }

  private func captureSessionWasInterrupted() {
    guard isStarted else { return }
    isInterrupted = true
    setAcceptsCameraFrames(false)
    cancelVideoRecordingForLifecycleChange()
    emitStatus(.cameraUnavailable, model: configuration?.model ?? .lite)
  }

  private func captureSessionInterruptionEnded() {
    guard isStarted else { return }
    isInterrupted = false
    startCaptureIfEligible(generation: generation)
  }

  private func captureSessionRuntimeError(_ notification: Notification) {
    guard isStarted else { return }
    let avError = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError
    let details: [String: Any]? = avError.map {
      ["avErrorCode": $0.code.rawValue]
    }
    let error = MotionfitPoseNativeError(
      "camera_runtime_error",
      avError?.localizedDescription ?? "The camera capture session failed.",
      details: details
    )
    setAcceptsCameraFrames(false)
    emitStatus(.cameraUnavailable, model: configuration?.model ?? .lite)
    delegate?.poseEngine(self, didFail: error)

    if avError?.code == .mediaServicesWereReset {
      startCaptureIfEligible(generation: generation)
    }
  }

  private func emitStatus(
    _ trackingState: MotionfitTrackingState,
    model: MotionfitPoseModel
  ) {
    processingQueue.async { [weak self] in
      guard let self else { return }
      self.frameId += 1
      let emptyLandmarks = [Float32](repeating: 0, count: 33 * 5)
      let frame = MotionfitPoseFramePayload(
        frameId: self.frameId,
        timestampUs: Int64(ProcessInfo.processInfo.systemUptime * 1_000_000),
        videoElapsedUs: nil,
        trackingState: trackingState,
        personCount: 0,
        normalizedLandmarks: emptyLandmarks,
        worldLandmarks: emptyLandmarks,
        inputWidth: 0,
        inputHeight: 0,
        inferenceLatencyMilliseconds: 0,
        model: model
      )
      self.delegate?.poseEngine(self, didOutput: frame)
    }
  }

  private func reportInferenceError(_ error: Error) {
    let now = ProcessInfo.processInfo.systemUptime
    guard now - lastInferenceErrorUptime >= 2 else { return }
    lastInferenceErrorUptime = now
    // A single bad frame is not fatal. Keep the stream alive and allow the
    // next camera frame to reacquire the person automatically.
    emitStatus(.lost, model: configuration?.model ?? .lite)
  }

  private static let notStartedError = MotionfitPoseNativeError(
    "not_started",
    "Start the pose engine before calling this method."
  )
  private static let busyError = MotionfitPoseNativeError(
    "busy",
    "Another camera or model transition is already in progress."
  )
  private static let disposedError = MotionfitPoseNativeError(
    "disposed",
    "The pose engine operation was cancelled because the engine was disposed."
  )
  private static let videoRecordingInProgressError = MotionfitPoseNativeError(
    "video_recording_in_progress",
    "Stop or cancel the workout video before changing the camera or pose model."
  )
  private static let videoNotRecordingError = MotionfitPoseNativeError(
    "video_not_recording",
    "No workout video recording is active."
  )
}

extension MotionfitPoseEngine: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    dispatchPrecondition(condition: .onQueue(processingQueue))
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

    delegate?.poseEngine(self, didOutputPreview: pixelBuffer)

    let videoElapsedUs = appendVideoSample(sampleBuffer)

    let lifecycle = lifecycleSnapshot()
    guard lifecycle.acceptsFrames,
          lifecycle.generation == processingGeneration,
          !inferenceInFlight,
          let poseLandmarker else {
      return
    }

    let now = ProcessInfo.processInfo.systemUptime
    let minimumInterval = 1.0 / Double(max(1, targetFps))
    guard lastSubmittedUptime == 0 || now - lastSubmittedUptime >= minimumInterval else {
      return
    }
    lastSubmittedUptime = now

    do {
      let image = try MPImage(pixelBuffer: pixelBuffer, orientation: .up)
      let timestampMs = max(Int(now * 1_000), lastSubmittedTimestampMs + 1)
      lastSubmittedTimestampMs = timestampMs
      inferenceInFlight = true
      inferenceContext = InferenceContext(
        landmarkerID: ObjectIdentifier(poseLandmarker),
        generation: lifecycle.generation,
        timestampMs: timestampMs,
        startedUptime: now,
        inputWidth: CVPixelBufferGetWidth(pixelBuffer),
        inputHeight: CVPixelBufferGetHeight(pixelBuffer),
        model: activeModel,
        videoElapsedUs: videoElapsedUs
      )
      try poseLandmarker.detectAsync(
        image: image,
        timestampInMilliseconds: timestampMs
      )
    } catch {
      inferenceInFlight = false
      inferenceContext = nil
      reportInferenceError(error)
    }
  }
}

extension MotionfitPoseEngine: PoseLandmarkerLiveStreamDelegate {
  func poseLandmarker(
    _ poseLandmarker: PoseLandmarker,
    didFinishDetection result: PoseLandmarkerResult?,
    timestampInMilliseconds: Int,
    error: Error?
  ) {
    processingQueue.async { [weak self] in
      guard let self else { return }
      guard let context = self.inferenceContext,
            context.landmarkerID == ObjectIdentifier(poseLandmarker),
            context.timestampMs == timestampInMilliseconds else {
        return
      }

      self.inferenceInFlight = false
      self.inferenceContext = nil
      let lifecycle = self.lifecycleSnapshot()
      if lifecycle.acceptsFrames,
         lifecycle.generation == context.generation,
         let result {
        let frame = self.makeFramePayload(result: result, context: context)
        self.delegate?.poseEngine(self, didOutput: frame)
      }
      if let error {
        self.reportInferenceError(error)
      }

      if let disposeCompletion = self.pendingDisposeCompletion {
        self.finishProcessingDispose(completion: disposeCompletion)
      } else if let pendingModelChange = self.pendingModelChange {
        self.pendingModelChange = nil
        self.performModelChange(pendingModelChange)
      }
    }
  }

  private func makeFramePayload(
    result: PoseLandmarkerResult,
    context: InferenceContext
  ) -> MotionfitPoseFramePayload {
    let personCount = result.landmarks.count
    let primaryIndex = result.motionfitPrimaryPoseIndex()
    let normalizedPose = primaryIndex.map { result.landmarks[$0] } ?? []
    let worldPose: [Landmark]
    if let primaryIndex, result.worldLandmarks.indices.contains(primaryIndex) {
      worldPose = result.worldLandmarks[primaryIndex]
    } else {
      worldPose = []
    }

    let trackingState = trackingState(
      personCount: personCount,
      normalizedPose: normalizedPose
    )
    frameId += 1
    let latency = max(
      0,
      Int((ProcessInfo.processInfo.systemUptime - context.startedUptime) * 1_000)
    )

    return MotionfitPoseFramePayload(
      frameId: frameId,
      timestampUs: Int64(context.timestampMs) * 1_000,
      videoElapsedUs: context.videoElapsedUs,
      trackingState: trackingState,
      personCount: personCount,
      normalizedLandmarks: flattenNormalizedLandmarks(normalizedPose),
      worldLandmarks: flattenWorldLandmarks(worldPose),
      inputWidth: context.inputWidth,
      inputHeight: context.inputHeight,
      inferenceLatencyMilliseconds: latency,
      model: context.model
    )
  }

  private func trackingState(
    personCount: Int,
    normalizedPose: [NormalizedLandmark]
  ) -> MotionfitTrackingState {
    if personCount == 0 {
      consecutiveMissingFrames += 1
      let lostFrameLimit = max(3, targetFps / 2)
      if hadTrackedPerson && consecutiveMissingFrames <= lostFrameLimit {
        return .lost
      }
      hadTrackedPerson = false
      return .noPerson
    }

    consecutiveMissingFrames = 0
    if personCount > 1 {
      return .multiplePeople
    }
    if poseIsPartial(normalizedPose) {
      return .partialBody
    }

    hadTrackedPerson = true
    return .tracking
  }

  private func poseIsPartial(_ pose: [NormalizedLandmark]) -> Bool {
    guard pose.count >= 33 else { return true }
    let requiredSides: [[Int]]
    switch activeTrackingProfile {
    case .squat:
      // One visible shoulder-hip-knee chain is sufficient for squat tracking.
      requiredSides = [
        [11, 23, 25],
        [12, 24, 26],
      ]
    case .pushup, .plank:
      // Push-ups and planks need one complete arm and body line to be visible.
      requiredSides = [
        [11, 13, 15, 23, 27],
        [12, 14, 16, 24, 28],
      ]
    }
    let hasRequiredBody = requiredSides.contains { side in
      side.allSatisfy { isUsable(pose[$0]) }
    }
    return !hasRequiredBody
  }

  private func isUsable(_ landmark: NormalizedLandmark) -> Bool {
    let confidence = confidenceValues(
      visibility: landmark.visibility,
      presence: landmark.presence
    )
    return landmark.x.isFinite && landmark.y.isFinite && landmark.z.isFinite &&
      landmark.x >= -0.02 && landmark.x <= 1.02 &&
      landmark.y >= -0.02 && landmark.y <= 1.02 &&
      min(confidence.visibility, confidence.presence) >= 0.25
  }

  private func flattenNormalizedLandmarks(
    _ landmarks: [NormalizedLandmark]
  ) -> [Float32] {
    var flattened = [Float32](repeating: 0, count: 33 * 5)
    for index in 0..<min(33, landmarks.count) {
      let landmark = landmarks[index]
      let offset = index * 5
      flattened[offset] = finiteOrZero(landmark.x)
      flattened[offset + 1] = finiteOrZero(landmark.y)
      flattened[offset + 2] = finiteOrZero(landmark.z)
      let confidence = confidenceValues(
        visibility: landmark.visibility,
        presence: landmark.presence
      )
      flattened[offset + 3] = confidence.visibility
      flattened[offset + 4] = confidence.presence
    }
    return flattened
  }

  private func flattenWorldLandmarks(_ landmarks: [Landmark]) -> [Float32] {
    var flattened = [Float32](repeating: 0, count: 33 * 5)
    for index in 0..<min(33, landmarks.count) {
      let landmark = landmarks[index]
      let offset = index * 5
      flattened[offset] = finiteOrZero(landmark.x)
      flattened[offset + 1] = finiteOrZero(landmark.y)
      flattened[offset + 2] = finiteOrZero(landmark.z)
      let confidence = confidenceValues(
        visibility: landmark.visibility,
        presence: landmark.presence
      )
      flattened[offset + 3] = confidence.visibility
      flattened[offset + 4] = confidence.presence
    }
    return flattened
  }

  private func confidenceValues(
    visibility: NSNumber?,
    presence: NSNumber?
  ) -> (visibility: Float32, presence: Float32) {
    let visibilityValue = visibility?.floatValue
    let presenceValue = presence?.floatValue
    return (
      finiteOrZero(visibilityValue ?? presenceValue ?? 0),
      finiteOrZero(presenceValue ?? visibilityValue ?? 0)
    )
  }

  private func finiteOrZero(_ value: Float) -> Float32 {
    value.isFinite ? Float32(value) : 0
  }
}
