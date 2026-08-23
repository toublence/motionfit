# MediaPipe's generated lite messages are inspected by field name at runtime.
# Publish this rule with the plugin so every consuming release keeps the
# reflective fields even when R8 is enabled by Flutter.
-keepclassmembers class com.google.mediapipe.** extends com.google.protobuf.GeneratedMessageLite {
    <fields>;
}

# MediaPipe Graph initializes a FluentLogger with stack-based caller lookup.
# R8 inlining that API throws ExceptionInInitializerError at runtime.
-keep class com.google.common.flogger.** { *; }
