"""Build an isolated iOS video host using the current production Swift sources.

Only the temporary copy receives offline hooks. Live camera code is unchanged.
"""
import hashlib
import json
from pathlib import Path
import shutil
import sys

root = Path(__file__).resolve().parents[2]
out = Path(sys.argv[1] if len(sys.argv) > 1 else '/tmp/motionfit-ios-video-validation')
out.mkdir(parents=True, exist_ok=True)
classes = root / 'packages/motionfit_pose/ios/Classes'
engine = (classes / 'MotionfitPoseEngine.swift').read_text()
start = engine.index('  private func makePoseLandmarker(')
end = engine.index('\n  private func ', start + 10)
factory = engine[start:end].replace('makePoseLandmarker(', 'makeVideoLandmarker(')
factory = factory.replace('options.runningMode = .liveStream', 'options.runningMode = .video')
factory = factory.replace('    options.poseLandmarkerLiveStreamDelegate = self\n', '')
hook = '''
extension MotionfitPoseEngine {
  func benchmarkLandmarker(profile: MotionfitTrackingProfile) throws -> PoseLandmarker {
    activeTrackingProfile = profile
    targetFps = 30
    return try makeVideoLandmarker(
      modelURL: MotionfitModelLocator.url(for: .lite)!, trackingProfile: profile)
  }
  func benchmarkPayload(result: PoseLandmarkerResult, landmarker: PoseLandmarker,
                        timestampMs: Int, started: Double, width: Int, height: Int) -> [String: Any] {
    let context = InferenceContext(landmarkerID: ObjectIdentifier(landmarker), generation: 0,
      timestampMs: timestampMs, startedUptime: started, inputWidth: width,
      inputHeight: height, model: .lite, videoElapsedUs: Int64(timestampMs) * 1000)
    let frame = makeFramePayload(result: result, context: context)
    return ["frameId": frame.frameId, "timestampUs": frame.timestampUs,
      "videoElapsedUs": frame.timestampUs, "trackingState": frame.trackingState.rawValue,
      "personCount": frame.personCount, "normalizedLandmarks": frame.normalizedLandmarks,
      "worldLandmarks": frame.worldLandmarks, "inputWidth": width, "inputHeight": height,
      "mirrored": false, "rotationDegrees": 0,
      "inferenceLatencyMilliseconds": frame.inferenceLatencyMilliseconds,
      "previewHandlesCropAndRotation": true]
  }
FACTORY
}
'''.replace('FACTORY', factory)
(out / 'MotionfitPoseEngine.swift').write_text(engine + hook)
for name in ['MotionfitPoseTypes.swift', 'MotionfitStillCapture.swift']:
    shutil.copyfile(classes / name, out / name)
shutil.copyfile(root / 'benchmark/ios/VideoHost.swift', out / 'VideoHost.swift')
resources = out / 'Resources'
resources.mkdir(exist_ok=True)
shutil.copyfile(root / 'packages/motionfit_pose/ios/Assets/pose_landmarker_lite.task',
                resources / 'pose_landmarker_lite.task')
cases = [
    ('squat', 'squat_depth_after_5'), ('squat', 'squat_fast_10'),
    ('pushup', 'pushup_good_repeat_10'), ('pushup', 'pushup_shallow_10'),
    ('plank', 'plank_near_20s'), ('plank', 'plank_hip_high_20s'),
]
manifest = []
for exercise, name in cases:
    source = root / 'benchmark/videos' / exercise / f'{name}.mp4'
    shutil.copyfile(source, resources / source.name)
    manifest.append({'exercise': exercise, 'id': name,
                     'video_sha256': hashlib.sha256(source.read_bytes()).hexdigest()})
(resources / 'cases.json').write_text(json.dumps(manifest, indent=2))
frameworks = root / 'ios/Pods'
project = f'''name: MotionFitVideoValidation
options:
  deploymentTarget:
    iOS: "15.0"
settings:
  base:
    SWIFT_VERSION: "5.0"
    DEVELOPMENT_TEAM: 2CZQR7Q423
    CODE_SIGN_STYLE: Automatic
    PRODUCT_BUNDLE_IDENTIFIER: fit.motionfit.app.videovalidation
    GENERATE_INFOPLIST_FILE: YES
    INFOPLIST_KEY_UILaunchScreen_Generation: YES
    INFOPLIST_KEY_UIRequiresFullScreen: YES
    TARGETED_DEVICE_FAMILY: "1,2"
    OTHER_LDFLAGS: ["$(inherited)", "-ObjC", "-lc++", "-lz"]
    OTHER_LDFLAGS[sdk=iphoneos*]: ["$(inherited)", "-force_load", "{frameworks}/MediaPipeTasksCommon/frameworks/graph_libraries/libMediaPipeTasksCommon_device_graph.a"]
    OTHER_LDFLAGS[sdk=iphonesimulator*]: ["$(inherited)", "-force_load", "{frameworks}/MediaPipeTasksCommon/frameworks/graph_libraries/libMediaPipeTasksCommon_simulator_graph.a"]
targets:
  MotionFitVideoValidation:
    type: application
    platform: iOS
    sources:
      - path: .
        excludes: [Resources, project.yml, provenance.json]
      - path: Resources
        buildPhase: resources
    dependencies:
      - framework: {frameworks}/MediaPipeTasksVision/frameworks/MediaPipeTasksVision.xcframework
        embed: false
      - framework: {frameworks}/MediaPipeTasksCommon/frameworks/MediaPipeTasksCommon.xcframework
        embed: false
      - sdk: AVFoundation.framework
      - sdk: Accelerate.framework
      - sdk: AudioToolbox.framework
      - sdk: CoreMedia.framework
      - sdk: CoreVideo.framework
      - sdk: Metal.framework
      - sdk: MetalKit.framework
      - sdk: OpenGLES.framework
      - sdk: QuartzCore.framework
'''
(out / 'project.yml').write_text(project)
provenance = {'source_root': str(root), 'cases': manifest,
    'mode_difference': 'video instead of liveStream; no camera, frame drops or Flutter bridge',
    'production_sources_sha256': {
        name: hashlib.sha256((classes / name).read_bytes()).hexdigest()
        for name in ['MotionfitPoseEngine.swift', 'MotionfitPoseTypes.swift', 'MotionfitStillCapture.swift']}}
(out / 'provenance.json').write_text(json.dumps(provenance, indent=2))
print(out)
