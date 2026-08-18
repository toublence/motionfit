import Foundation
import MediaPipeTasksVision

enum MotionfitCamera: String {
  case front
  case back
}

enum MotionfitPoseModel: String {
  case lite
  case full
  case heavy

  var resourceName: String {
    switch self {
    case .lite:
      return "pose_landmarker_lite"
    case .full:
      return "pose_landmarker_full"
    case .heavy:
      return "pose_landmarker_heavy"
    }
  }
}

enum MotionfitTrackingProfile: String {
  case squat
  case pushup
  case plank
}

enum MotionfitTrackingState: String {
  case tracking
  case noPerson
  case partialBody
  case multiplePeople
  case lost
  case cameraUnavailable
  case modelUnavailable
}

struct MotionfitPoseConfiguration {
  let camera: MotionfitCamera
  let model: MotionfitPoseModel
  let trackingProfile: MotionfitTrackingProfile
  let targetFps: Int
  let enableVideoRecording: Bool
}

struct MotionfitPoseFramePayload {
  let frameId: Int64
  let timestampUs: Int64
  let videoElapsedUs: Int64?
  let trackingState: MotionfitTrackingState
  let personCount: Int
  let normalizedLandmarks: [Float32]
  let worldLandmarks: [Float32]
  let inputWidth: Int
  let inputHeight: Int
  let inferenceLatencyMilliseconds: Int
  let model: MotionfitPoseModel
}

struct MotionfitVideoRecordingStart {
  let timelineOriginUs: Int64
}

struct MotionfitVideoRecordingResult {
  let path: String
  let durationMilliseconds: Int64
}

struct MotionfitPoseNativeError: Error {
  let code: String
  let message: String
  let details: [String: Any]?

  init(_ code: String, _ message: String, details: [String: Any]? = nil) {
    self.code = code
    self.message = message
    self.details = details
  }
}

enum MotionfitModelLocator {
  private static let resourceBundleName = "motionfit_pose_models"

  static func url(for model: MotionfitPoseModel) -> URL? {
    for bundle in candidateBundles() {
      if let modelURL = bundle.url(
        forResource: model.resourceName,
        withExtension: "task"
      ) {
        return modelURL
      }

      if let modelURL = bundle.url(
        forResource: model.resourceName,
        withExtension: "task",
        subdirectory: "Assets"
      ) {
        return modelURL
      }
    }
    return nil
  }

  private static func candidateBundles() -> [Bundle] {
    let hostBundles = [Bundle(for: MotionfitPoseEngine.self), Bundle.main]
      + Bundle.allFrameworks
    var bundles: [Bundle] = []
    var seenPaths = Set<String>()

    for hostBundle in hostBundles {
      append(hostBundle, to: &bundles, seenPaths: &seenPaths)

      if let bundleURL = hostBundle.url(
        forResource: resourceBundleName,
        withExtension: "bundle"
      ), let resourceBundle = Bundle(url: bundleURL) {
        append(resourceBundle, to: &bundles, seenPaths: &seenPaths)
      }

      if let resourcesURL = hostBundle.resourceURL {
        let nestedURL = resourcesURL
          .appendingPathComponent(resourceBundleName)
          .appendingPathExtension("bundle")
        if let resourceBundle = Bundle(url: nestedURL) {
          append(resourceBundle, to: &bundles, seenPaths: &seenPaths)
        }
      }
    }

    return bundles
  }

  private static func append(
    _ bundle: Bundle,
    to bundles: inout [Bundle],
    seenPaths: inout Set<String>
  ) {
    guard seenPaths.insert(bundle.bundlePath).inserted else { return }
    bundles.append(bundle)
  }
}

extension PoseLandmarkerResult {
  func motionfitPrimaryPoseIndex() -> Int? {
    guard !landmarks.isEmpty else { return nil }

    return landmarks.indices.max { lhs, rhs in
      motionfitPoseScore(landmarks[lhs]) < motionfitPoseScore(landmarks[rhs])
    }
  }

  private func motionfitPoseScore(_ pose: [NormalizedLandmark]) -> Float {
    let valid = pose.filter {
      $0.x.isFinite && $0.y.isFinite && $0.x >= 0 && $0.x <= 1 &&
        $0.y >= 0 && $0.y <= 1
    }
    guard !valid.isEmpty else { return 0 }

    let minX = valid.map(\.x).min() ?? 0
    let maxX = valid.map(\.x).max() ?? 0
    let minY = valid.map(\.y).min() ?? 0
    let maxY = valid.map(\.y).max() ?? 0
    let area = max(0, maxX - minX) * max(0, maxY - minY)
    var confidenceTotal: Float = 0
    for landmark in valid {
      let visibilityValue = landmark.visibility?.floatValue
      let presenceValue = landmark.presence?.floatValue
      let visibility: Float = visibilityValue ?? presenceValue ?? 0
      let presence: Float = presenceValue ?? visibilityValue ?? 0
      confidenceTotal += (visibility + presence) / 2
    }
    let confidence = confidenceTotal / Float(valid.count)
    return area * 0.8 + confidence * 0.2
  }
}
