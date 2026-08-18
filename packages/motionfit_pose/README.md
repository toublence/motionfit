# motionfit_pose

Private native pose engine used by MotionFit - Squat. Camera frames stay inside
the native Android/iOS pipeline; Dart receives only texture metadata, tracking
state, and numeric pose landmarks.

Install the pinned Lite, Full, and Heavy MediaPipe task bundles from the repository
root before building:

```sh
./tool/download_pose_models.sh
```

The public Dart API exposes `start`, `pause`, `resume`, camera/model switching,
FPS control, a texture ID, and a broadcast frame stream. Landmark coordinates
are canonical and unmirrored; `previewTransform` maps them to texture space.
