import AVFoundation
import CoreVideo
import Foundation
import UIKit

protocol MotionfitStillCaptureDelegate: AnyObject {
  func stillCapture(
    _ capture: MotionfitStillCapture,
    didOutputPreview pixelBuffer: CVPixelBuffer
  )
}

struct MotionfitStillCaptureStart {
  let previewWidth: Int
  let previewHeight: Int
  let mirrored: Bool
}

struct MotionfitStillPhoto {
  let directory: String
  let fileName: String
  let width: Int
  let height: Int
}

/// Full-resolution photo capture for Body Progress.
///
/// This owns a capture session that is entirely separate from
/// `MotionfitPoseEngine`. The workout session runs a VGA preset tuned for
/// MediaPipe latency, which would produce unusable progress photos, and the two
/// never run at the same time because the plugin refuses to start one while the
/// other holds the camera.
final class MotionfitStillCapture: NSObject {
  private static let directoryName = "motionfit_body_progress"

  weak var delegate: MotionfitStillCaptureDelegate?

  private let sessionQueue = DispatchQueue(
    label: "com.namslab.motionfit_pose.still.session"
  )
  private let previewQueue = DispatchQueue(
    label: "com.namslab.motionfit_pose.still.preview"
  )
  private let captureSession = AVCaptureSession()
  private let previewOutput = AVCaptureVideoDataOutput()
  private let photoOutput = AVCapturePhotoOutput()
  private var cameraInput: AVCaptureDeviceInput?
  private var camera: MotionfitCamera = .front
  private var running = false
  private var pendingCapture: ((Result<MotionfitStillPhoto, MotionfitPoseNativeError>) -> Void)?

  var isRunning: Bool {
    var value = false
    sessionQueue.sync { value = running }
    return value
  }

  func start(
    camera: MotionfitCamera,
    completion: @escaping (Result<MotionfitStillCaptureStart, MotionfitPoseNativeError>) -> Void
  ) {
    sessionQueue.async { [weak self] in
      guard let self else { return }
      guard !self.running else {
        completion(.failure(MotionfitPoseNativeError(
          "already_started",
          "Still capture is already running."
        )))
        return
      }
      self.requestCameraAuthorization { authorized in
        self.sessionQueue.async {
          guard authorized else {
            completion(.failure(MotionfitPoseNativeError(
              "permission_denied",
              "Camera permission must be granted before capturing photos."
            )))
            return
          }
          do {
            let start = try self.configureSession(camera: camera)
            self.captureSession.startRunning()
            self.running = true
            completion(.success(start))
          } catch let error as MotionfitPoseNativeError {
            self.teardown()
            completion(.failure(error))
          } catch {
            self.teardown()
            completion(.failure(MotionfitPoseNativeError(
              "camera_unavailable",
              error.localizedDescription
            )))
          }
        }
      }
    }
  }

  func switchCamera(
    to camera: MotionfitCamera,
    completion: @escaping (Result<MotionfitStillCaptureStart, MotionfitPoseNativeError>) -> Void
  ) {
    sessionQueue.async { [weak self] in
      guard let self else { return }
      guard self.running else {
        completion(.failure(MotionfitPoseNativeError(
          "not_started",
          "Still capture is not running."
        )))
        return
      }
      let previous = self.cameraInput
      self.captureSession.beginConfiguration()
      if let previous { self.captureSession.removeInput(previous) }
      do {
        try self.attachCameraInput(camera)
        self.captureSession.commitConfiguration()
        self.configureConnections()
        completion(.success(self.startPayload()))
      } catch {
        if let previous, self.captureSession.canAddInput(previous) {
          self.captureSession.addInput(previous)
          self.cameraInput = previous
        }
        self.captureSession.commitConfiguration()
        completion(.failure(MotionfitPoseNativeError(
          "camera_unavailable",
          "The requested camera could not be attached."
        )))
      }
    }
  }

  func capturePhoto(
    completion: @escaping (Result<MotionfitStillPhoto, MotionfitPoseNativeError>) -> Void
  ) {
    sessionQueue.async { [weak self] in
      guard let self else { return }
      guard self.running else {
        completion(.failure(MotionfitPoseNativeError(
          "not_started",
          "Still capture is not running."
        )))
        return
      }
      guard self.pendingCapture == nil else {
        completion(.failure(MotionfitPoseNativeError(
          "capture_busy",
          "A photo capture is already in progress."
        )))
        return
      }
      self.pendingCapture = completion
      self.configureConnections()
      let settings = AVCapturePhotoSettings(
        format: [AVVideoCodecKey: AVVideoCodecType.jpeg]
      )
      settings.flashMode = .off
      self.photoOutput.capturePhoto(with: settings, delegate: self)
    }
  }

  func stop(completion: @escaping () -> Void) {
    sessionQueue.async { [weak self] in
      guard let self else {
        completion()
        return
      }
      self.teardown()
      completion()
    }
  }

  /// Absolute path of the directory that holds Body Progress images.
  static func directoryPath() throws -> String {
    try directoryURL().path
  }

  static func directoryURL() throws -> URL {
    guard let applicationSupport = FileManager.default.urls(
      for: .applicationSupportDirectory,
      in: .userDomainMask
    ).first else {
      throw MotionfitPoseNativeError(
        "photo_storage_failed",
        "The Application Support directory is unavailable."
      )
    }
    let directory = applicationSupport.appendingPathComponent(
      directoryName,
      isDirectory: true
    )
    try FileManager.default.createDirectory(
      at: directory,
      withIntermediateDirectories: true
    )
    var mutableURL = directory
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try? mutableURL.setResourceValues(values)
    return directory
  }

  private func configureSession(camera: MotionfitCamera) throws -> MotionfitStillCaptureStart {
    captureSession.beginConfiguration()
    // `.photo` is what separates this session from the workout pipeline: it
    // yields the sensor's still resolution instead of the VGA analysis frames.
    if captureSession.canSetSessionPreset(.photo) {
      captureSession.sessionPreset = .photo
    } else {
      captureSession.sessionPreset = .high
    }
    try attachCameraInput(camera)

    previewOutput.alwaysDiscardsLateVideoFrames = true
    previewOutput.videoSettings = [
      kCVPixelBufferPixelFormatTypeKey as String:
        Int(kCVPixelFormatType_32BGRA)
    ]
    previewOutput.setSampleBufferDelegate(self, queue: previewQueue)
    guard captureSession.canAddOutput(previewOutput) else {
      captureSession.commitConfiguration()
      throw MotionfitPoseNativeError(
        "camera_unavailable",
        "The camera preview output could not be attached."
      )
    }
    captureSession.addOutput(previewOutput)

    guard captureSession.canAddOutput(photoOutput) else {
      captureSession.commitConfiguration()
      throw MotionfitPoseNativeError(
        "camera_unavailable",
        "The camera photo output could not be attached."
      )
    }
    captureSession.addOutput(photoOutput)
    captureSession.commitConfiguration()
    configureConnections()
    return startPayload()
  }

  private func attachCameraInput(_ camera: MotionfitCamera) throws {
    let position: AVCaptureDevice.Position = camera == .front ? .front : .back
    guard let device = AVCaptureDevice.default(
      .builtInWideAngleCamera,
      for: .video,
      position: position
    ) else {
      throw MotionfitPoseNativeError(
        "camera_unavailable",
        "The requested camera is not available on this device."
      )
    }
    let input = try AVCaptureDeviceInput(device: device)
    guard captureSession.canAddInput(input) else {
      throw MotionfitPoseNativeError(
        "camera_unavailable",
        "The camera input could not be attached."
      )
    }
    captureSession.addInput(input)
    cameraInput = input
    self.camera = camera
  }

  /// Body Progress photos are portrait framing references, so both outputs are
  /// pinned to portrait and the front camera is mirrored to match the preview
  /// the user lined themselves up with.
  private func configureConnections() {
    let mirrored = camera == .front
    for output in [previewOutput as AVCaptureOutput, photoOutput] {
      guard let connection = output.connection(with: .video) else { continue }
      if #available(iOS 17.0, *) {
        if connection.isVideoRotationAngleSupported(90) {
          connection.videoRotationAngle = 90
        }
      } else if connection.isVideoOrientationSupported {
        connection.videoOrientation = .portrait
      }
      if connection.isVideoMirroringSupported {
        connection.automaticallyAdjustsVideoMirroring = false
        connection.isVideoMirrored = mirrored
      }
    }
  }

  private func startPayload() -> MotionfitStillCaptureStart {
    let dimensions = cameraInput.map { input -> CMVideoDimensions in
      CMVideoFormatDescriptionGetDimensions(
        input.device.activeFormat.formatDescription
      )
    }
    // Portrait connections swap the sensor's landscape dimensions.
    let width = Int(dimensions?.height ?? 0)
    let height = Int(dimensions?.width ?? 0)
    return MotionfitStillCaptureStart(
      previewWidth: width,
      previewHeight: height,
      mirrored: camera == .front
    )
  }

  private func teardown() {
    if captureSession.isRunning { captureSession.stopRunning() }
    previewOutput.setSampleBufferDelegate(nil, queue: nil)
    captureSession.beginConfiguration()
    for input in captureSession.inputs { captureSession.removeInput(input) }
    for output in captureSession.outputs { captureSession.removeOutput(output) }
    captureSession.commitConfiguration()
    cameraInput = nil
    running = false
    if let pending = pendingCapture {
      pendingCapture = nil
      pending(.failure(MotionfitPoseNativeError(
        "capture_cancelled",
        "Still capture stopped before the photo was written."
      )))
    }
  }

  private func requestCameraAuthorization(_ completion: @escaping (Bool) -> Void) {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      completion(true)
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { completion($0) }
    default:
      completion(false)
    }
  }
}

extension MotionfitStillCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(
    _ output: AVCaptureOutput,
    didOutput sampleBuffer: CMSampleBuffer,
    from connection: AVCaptureConnection
  ) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
      return
    }
    delegate?.stillCapture(self, didOutputPreview: pixelBuffer)
  }
}

extension MotionfitStillCapture: AVCapturePhotoCaptureDelegate {
  func photoOutput(
    _ output: AVCapturePhotoOutput,
    didFinishProcessingPhoto photo: AVCapturePhoto,
    error: Error?
  ) {
    sessionQueue.async { [weak self] in
      guard let self, let completion = self.pendingCapture else { return }
      self.pendingCapture = nil
      if let error {
        completion(.failure(MotionfitPoseNativeError(
          "capture_failed",
          error.localizedDescription
        )))
        return
      }
      guard let data = photo.fileDataRepresentation() else {
        completion(.failure(MotionfitPoseNativeError(
          "capture_failed",
          "The captured photo could not be encoded."
        )))
        return
      }
      do {
        let directory = try MotionfitStillCapture.directoryURL()
        let fileName = "body_\(Int64(Date().timeIntervalSince1970 * 1000)).jpg"
        let fileURL = directory.appendingPathComponent(fileName)
        try data.write(to: fileURL, options: .atomic)
        let image = UIImage(data: data)
        completion(.success(MotionfitStillPhoto(
          directory: directory.path,
          fileName: fileName,
          width: Int(image?.size.width ?? 0),
          height: Int(image?.size.height ?? 0)
        )))
      } catch {
        completion(.failure(MotionfitPoseNativeError(
          "photo_storage_failed",
          "The captured photo could not be written to disk."
        )))
      }
    }
  }
}
