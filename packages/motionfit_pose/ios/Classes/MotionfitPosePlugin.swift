import CoreVideo
import Flutter
import Foundation

public final class MotionfitPosePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private static let methodChannelName = "motionfit_pose/methods"
  private static let eventChannelName = "motionfit_pose/events"

  private let textureRegistry: FlutterTextureRegistry
  private let texture = MotionfitPoseTexture()
  private let engine = MotionfitPoseEngine()
  private var textureId: Int64?
  private var eventSink: FlutterEventSink?
  private var eventChannel: FlutterEventChannel?
  private var isDetached = false

  private let frameNotificationLock = NSLock()
  private var isFrameNotificationScheduled = false

  private init(textureRegistry: FlutterTextureRegistry) {
    self.textureRegistry = textureRegistry
    super.init()
    engine.delegate = self
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = MotionfitPosePlugin(textureRegistry: registrar.textures())
    let methodChannel = FlutterMethodChannel(
      name: methodChannelName,
      binaryMessenger: registrar.messenger()
    )
    let eventChannel = FlutterEventChannel(
      name: eventChannelName,
      binaryMessenger: registrar.messenger()
    )
    instance.eventChannel = eventChannel
    eventChannel.setStreamHandler(instance)
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if Thread.isMainThread {
      handleOnMain(call, result: result)
    } else {
      DispatchQueue.main.async { [weak self] in
        self?.handleOnMain(call, result: result)
      }
    }
  }

  public func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    dispatchPrecondition(condition: .onQueue(.main))
    isDetached = true
    eventSink = nil
    eventChannel?.setStreamHandler(nil)
    eventChannel = nil
    engine.dispose { [weak self] in
      self?.unregisterTexture()
    }
  }

  private func handleOnMain(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    dispatchPrecondition(condition: .onQueue(.main))
    guard !isDetached else {
      result(flutterError(MotionfitPoseNativeError(
        "disposed",
        "The Flutter engine has detached from the pose plugin."
      )))
      return
    }

    switch call.method {
    case "start":
      handleStart(arguments: call.arguments, result: result)
    case "pause":
      engine.pause { result(self.flutterResult($0)) }
    case "resume":
      engine.resume { result(self.flutterResult($0)) }
    case "switchCamera":
      guard let camera = cameraArgument(from: call.arguments) else {
        result(invalidArgumentError("camera must be either 'front' or 'back'."))
        return
      }
      engine.switchCamera(to: camera) { result(self.flutterResult($0)) }
    case "setModel":
      guard let model = modelArgument(from: call.arguments) else {
        result(invalidArgumentError("model must be 'lite', 'full', or 'heavy'."))
        return
      }
      engine.setModel(model) { result(self.flutterResult($0)) }
    case "setTargetFps":
      guard let fps = integerArgument("targetFps", from: call.arguments),
            (15...30).contains(fps) else {
        result(invalidArgumentError("targetFps must be between 15 and 30."))
        return
      }
      engine.setTargetFps(fps) { result(self.flutterResult($0)) }
    case "startVideoRecording":
      guard let sessionId = dictionary(call.arguments)["sessionId"] as? String,
            !sessionId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        result(invalidArgumentError("sessionId must not be empty."))
        return
      }
      engine.startVideoRecording(sessionId: sessionId) { recordingResult in
        switch recordingResult {
        case .success(let start):
          result(["timelineOriginUs": start.timelineOriginUs])
        case .failure(let error):
          result(self.flutterError(error))
        }
      }
    case "stopVideoRecording":
      engine.stopVideoRecording { recordingResult in
        switch recordingResult {
        case .success(let recording):
          result([
            "path": recording.path,
            "durationMilliseconds": recording.durationMilliseconds
          ])
        case .failure(let error):
          result(self.flutterError(error))
        }
      }
    case "cancelVideoRecording":
      engine.cancelVideoRecording { result(self.flutterResult($0)) }
    case "dispose":
      engine.dispose { [weak self] in
        self?.unregisterTexture()
        result(nil)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleStart(arguments: Any?, result: @escaping FlutterResult) {
    guard textureId == nil else {
      result(flutterError(MotionfitPoseNativeError(
        "already_started",
        "The pose engine is already running. Dispose it before starting again."
      )))
      return
    }
    guard let camera = cameraArgument(from: arguments) else {
      result(invalidArgumentError("camera must be either 'front' or 'back'."))
      return
    }
    guard let model = modelArgument(from: arguments) else {
      result(invalidArgumentError("model must be 'lite', 'full', or 'heavy'."))
      return
    }
    guard let trackingProfile = trackingProfileArgument(from: arguments) else {
      result(invalidArgumentError(
        "trackingProfile must be 'squat', 'pushup', or 'plank'."
      ))
      return
    }
    guard let fps = integerArgument("targetFps", from: arguments),
          (15...30).contains(fps) else {
      result(invalidArgumentError("targetFps must be between 15 and 30."))
      return
    }

    let registeredTextureId = textureRegistry.register(texture)
    textureId = registeredTextureId
    let configuration = MotionfitPoseConfiguration(
      camera: camera,
      model: model,
      trackingProfile: trackingProfile,
      targetFps: fps,
      enableVideoRecording:
        dictionary(arguments)["enableVideoRecording"] as? Bool ?? false
    )
    engine.start(configuration: configuration) { [weak self] startResult in
      guard let self else { return }
      switch startResult {
      case .success:
        result([
          "textureId": registeredTextureId,
          "recordingSupported": configuration.enableVideoRecording
        ])
      case .failure(let error):
        if self.textureId == registeredTextureId {
          self.unregisterTexture()
        }
        result(self.flutterError(error))
      }
    }
  }

  private func cameraArgument(from arguments: Any?) -> MotionfitCamera? {
    guard let rawValue = dictionary(arguments)["camera"] as? String else { return nil }
    return MotionfitCamera(rawValue: rawValue)
  }

  private func modelArgument(from arguments: Any?) -> MotionfitPoseModel? {
    guard let rawValue = dictionary(arguments)["model"] as? String else { return nil }
    return MotionfitPoseModel(rawValue: rawValue)
  }

  private func trackingProfileArgument(from arguments: Any?) -> MotionfitTrackingProfile? {
    guard let value = dictionary(arguments)["trackingProfile"] else { return .squat }
    guard let rawValue = value as? String else { return nil }
    return MotionfitTrackingProfile(rawValue: rawValue)
  }

  private func integerArgument(_ key: String, from arguments: Any?) -> Int? {
    (dictionary(arguments)[key] as? NSNumber)?.intValue
  }

  private func dictionary(_ arguments: Any?) -> [String: Any] {
    arguments as? [String: Any] ?? [:]
  }

  private func flutterResult(
    _ result: Result<Void, MotionfitPoseNativeError>
  ) -> Any? {
    switch result {
    case .success:
      return nil
    case .failure(let error):
      return flutterError(error)
    }
  }

  private func invalidArgumentError(_ message: String) -> FlutterError {
    flutterError(MotionfitPoseNativeError("invalid_arguments", message))
  }

  private func flutterError(_ error: MotionfitPoseNativeError) -> FlutterError {
    FlutterError(code: error.code, message: error.message, details: error.details)
  }

  private func unregisterTexture() {
    dispatchPrecondition(condition: .onQueue(.main))
    guard let textureId else {
      texture.clear()
      return
    }
    textureRegistry.unregisterTexture(textureId)
    self.textureId = nil
    texture.clear()
  }

  private func scheduleTextureFrameAvailable() {
    frameNotificationLock.lock()
    guard !isFrameNotificationScheduled else {
      frameNotificationLock.unlock()
      return
    }
    isFrameNotificationScheduled = true
    frameNotificationLock.unlock()

    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      if let textureId = self.textureId, !self.isDetached {
        self.textureRegistry.textureFrameAvailable(textureId)
      }
      self.frameNotificationLock.lock()
      self.isFrameNotificationScheduled = false
      self.frameNotificationLock.unlock()
    }
  }

  private func typedFloat32Data(_ values: [Float32]) -> FlutterStandardTypedData {
    values.withUnsafeBufferPointer { buffer in
      FlutterStandardTypedData(float32: Data(buffer: buffer))
    }
  }

  private func eventMap(from frame: MotionfitPoseFramePayload) -> [String: Any] {
    var event: [String: Any] = [
      "frameId": frame.frameId,
      "timestampUs": frame.timestampUs,
      "trackingState": frame.trackingState.rawValue,
      "personCount": frame.personCount,
      "normalizedLandmarks": typedFloat32Data(frame.normalizedLandmarks),
      "worldLandmarks": typedFloat32Data(frame.worldLandmarks),
      "previewTransform": typedFloat32Data([
        1, 0, 0,
        0, 1, 0,
        0, 0, 1
      ]),
      "previewHandlesCropAndRotation": true,
      "mirrored": false,
      "rotationDegrees": 0,
      "inputWidth": frame.inputWidth,
      "inputHeight": frame.inputHeight,
      "inferenceLatencyMilliseconds": frame.inferenceLatencyMilliseconds,
      "model": frame.model.rawValue
    ]
    if let videoElapsedUs = frame.videoElapsedUs {
      event["videoElapsedUs"] = videoElapsedUs
    }
    return event
  }
}

extension MotionfitPosePlugin: MotionfitPoseEngineDelegate {
  func poseEngine(
    _ engine: MotionfitPoseEngine,
    didOutputPreview pixelBuffer: CVPixelBuffer
  ) {
    texture.update(with: pixelBuffer)
    scheduleTextureFrameAvailable()
  }

  func poseEngine(
    _ engine: MotionfitPoseEngine,
    didOutput frame: MotionfitPoseFramePayload
  ) {
    let event = eventMap(from: frame)
    DispatchQueue.main.async { [weak self] in
      guard let self, !self.isDetached, self.textureId != nil else { return }
      self.eventSink?(event)
    }
  }

  func poseEngine(
    _ engine: MotionfitPoseEngine,
    didFail error: MotionfitPoseNativeError
  ) {
    let flutterError = flutterError(error)
    DispatchQueue.main.async { [weak self] in
      guard let self, !self.isDetached, self.textureId != nil else { return }
      self.eventSink?(flutterError)
    }
  }
}
