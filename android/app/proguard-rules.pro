# MediaPipe's generated lite messages are inspected by field name at runtime.
# Flutter release builds enable R8, so those fields must not be renamed or
# removed. Keep only the reflective fields; unused MediaPipe APIs can still be
# optimized away.
-keepclassmembers class com.google.mediapipe.** extends com.google.protobuf.GeneratedMessageLite {
    <fields>;
}

# Flogger discovers its caller from the Java stack. If shrinking is ever
# enabled outside this app's guarded release build, its call boundary must not
# be renamed, removed, or inlined into MediaPipe Graph.<clinit>.
-keep class com.google.common.flogger.** { *; }
