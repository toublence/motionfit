import AVFoundation
import MediaPipeTasksVision
import UIKit

@main
class VideoValidationApp: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let window = UIWindow(frame: UIScreen.main.bounds)
    let controller = UIViewController()
    controller.view.backgroundColor = .systemBackground
    let label = UILabel(frame: CGRect(x: 20, y: 100, width: 600, height: 140))
    label.text = "MotionFit iOS video validation\nNo camera or workout data access"
    label.numberOfLines = 0
    controller.view.addSubview(label)
    window.rootViewController = controller
    window.makeKeyAndVisible()
    self.window = window
    UIApplication.shared.isIdleTimerDisabled = true
    DispatchQueue.global(qos: .userInitiated).async {
      self.runAll()
      DispatchQueue.main.async {
        label.text = "MotionFit video validation finished"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { exit(0) }
      }
    }
    return true
  }

  func runAll() {
    let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var summaries = [[String: Any]]()
    do {
      let cases = try JSONSerialization.jsonObject(with: Data(contentsOf:
        Bundle.main.url(forResource: "cases", withExtension: "json")!)) as! [[String: Any]]
      for item in cases {
        let name = item["id"] as! String
        print("VIDEO_BEGIN \(name)")
        do {
          let result = try runVideo(item)
          let frames = result.removeFrames()
          let output: [String: Any] = ["metadata": result.metadata, "frames": frames]
          try JSONSerialization.data(withJSONObject: output).write(
            to: documents.appendingPathComponent(name + ".json"), options: .atomic)
          summaries.append(result.metadata)
          print("VIDEO_DONE \(name) frames=\(frames.count)")
        } catch {
          summaries.append(["id": name, "error": String(describing: error)])
          print("VIDEO_ERROR \(name) \(error)")
        }
      }
    } catch { summaries.append(["fatal": String(describing: error)]) }
    let result: [String: Any] = ["device": UIDevice.current.model,
      "os": UIDevice.current.systemVersion, "mode": "video", "model": "lite",
      "cases": summaries]
    do {
      try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted).write(
        to: documents.appendingPathComponent("summary.json"), options: .atomic)
      print("VIDEO_ALL_DONE")
    } catch { print("VIDEO_SAVE_ERROR \(error)") }
  }

  func runVideo(_ item: [String: Any]) throws -> VideoResult {
    let name = item["id"] as! String
    let exercise = item["exercise"] as! String
    let asset = AVURLAsset(url: Bundle.main.url(forResource: name, withExtension: "mp4")!)
    let track = asset.tracks(withMediaType: .video).first!
    let reader = try AVAssetReader(asset: asset)
    // Apply the source display transform, including the rotated squat videos.
    let composition = AVMutableVideoComposition(propertiesOf: asset)
    let output = AVAssetReaderVideoCompositionOutput(videoTracks: [track],
      videoSettings: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA])
    output.videoComposition = composition
    output.alwaysCopiesSampleData = false
    reader.add(output)
    guard reader.startReading() else { throw reader.error! }
    let engine = DispatchQueue.main.sync { MotionfitPoseEngine() }
    let landmarker = try engine.benchmarkLandmarker(profile: MotionfitTrackingProfile(rawValue: exercise)!)
    let start = ProcessInfo.processInfo.systemUptime
    var frames = [[String: Any]]()
    var previousMs = -1
    var skipped = 0
    while let sample = output.copyNextSampleBuffer() {
      try autoreleasepool {
        let timestampMs = Int((CMSampleBufferGetPresentationTimeStamp(sample).seconds * 1000).rounded())
        if timestampMs <= previousMs { skipped += 1; return }
        previousMs = timestampMs
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sample) else { return }
        let inferenceStart = ProcessInfo.processInfo.systemUptime
        let image = try MPImage(pixelBuffer: pixelBuffer)
        let result = try landmarker.detect(videoFrame: image, timestampInMilliseconds: timestampMs)
        frames.append(engine.benchmarkPayload(result: result, landmarker: landmarker,
          timestampMs: timestampMs, started: inferenceStart,
          width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer)))
      }
    }
    guard reader.status == .completed else {
      throw reader.error ?? NSError(domain: "VideoValidation", code: 1)
    }
    return VideoResult(metadata: ["id": name, "exercise": exercise,
      "durationSeconds": asset.duration.seconds, "frames": frames.count,
      "skippedNonIncreasingTimestamps": skipped,
      "processingSeconds": ProcessInfo.processInfo.systemUptime - start,
      "sourceTransform": NSCoder.string(for: track.preferredTransform),
      "os": UIDevice.current.systemVersion], frames: frames)
  }
}

struct VideoResult {
  let metadata: [String: Any]
  let frames: [[String: Any]]
  func removeFrames() -> [[String: Any]] { frames }
}
