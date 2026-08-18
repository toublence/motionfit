package com.namslab.motionfit_pose

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import android.util.Size
import android.view.Surface
import androidx.annotation.OptIn
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.CameraState
import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ExperimentalMirrorMode
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.MirrorMode
import androidx.camera.core.Preview
import androidx.camera.core.SurfaceRequest
import androidx.camera.core.UseCase
import androidx.camera.core.resolutionselector.AspectRatioStrategy
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.core.resolutionselector.ResolutionStrategy
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.video.FallbackStrategy
import androidx.camera.video.FileOutputOptions
import androidx.camera.video.Quality
import androidx.camera.video.QualitySelector
import androidx.camera.video.Recorder
import androidx.camera.video.Recording
import androidx.camera.video.VideoCapture
import androidx.camera.video.VideoRecordEvent
import androidx.core.content.ContextCompat
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LiveData
import androidx.lifecycle.Observer
import com.google.mediapipe.framework.image.MediaImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.core.Delegate
import com.google.mediapipe.tasks.vision.core.ImageProcessingOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry
import java.io.File
import java.util.concurrent.ExecutorService
import java.util.concurrent.ExecutionException
import java.util.concurrent.Executors
import java.util.concurrent.RejectedExecutionException
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicLong
import kotlin.math.abs
import kotlin.math.max

/** On-device CameraX and MediaPipe pose engine for MotionFit. */
@OptIn(markerClass = [ExperimentalGetImage::class, ExperimentalMirrorMode::class])
class MotionfitPosePlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler,
    ActivityAware,
    DefaultLifecycleObserver {
    private lateinit var applicationContext: Context
    private lateinit var textureRegistry: TextureRegistry
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var mainHandler: Handler
    private lateinit var analysisExecutor: ExecutorService

    private var activity: Activity? = null
    private var lifecycleOwner: LifecycleOwner? = null
    private var cameraProvider: ProcessCameraProvider? = null
    private var preview: Preview? = null
    private var imageAnalysis: ImageAnalysis? = null
    private var videoCapture: VideoCapture<Recorder>? = null
    private var recording: Recording? = null
    private var surfaceProducer: TextureRegistry.SurfaceProducer? = null
    private var observedCameraState: LiveData<CameraState>? = null
    private var cameraStateObserver: Observer<CameraState>? = null
    private var eventSink: EventChannel.EventSink? = null
    private var engineAttached = false
    @Volatile private var sessionActive = false
    @Volatile private var userPaused = true
    @Volatile private var lifecycleSuspended = false
    private var resumeAfterConfigurationChange = false
    private var resumeWhenLifecycleStarts = false
    private var operationInProgress = false
    private var pendingOperationResult: MethodChannel.Result? = null
    private var lastCameraErrorCode: Int? = null
    private var lastCameraErrorAtNs = 0L
    private var videoRecordingRequested = false
    private var recordingSupported = false
    private var videoCapabilityProbed = false
    private var recordingCommand = RecordingCommand.NONE
    private var recordingCancelRequested = false
    private var recordingPartialFile: File? = null
    private var recordingFinalFile: File? = null
    private val videoTimelineLock = Any()
    private var videoTimelineActive = false
    private var videoTimelineRunning = false
    private var videoTimelineOriginUs: Long? = null
    private var videoAnchorRealtimeNs = 0L
    private var videoAnchorRecordedNs = 0L
    private var lastVideoElapsedUs = 0L

    @Volatile private var analysisEnabled = false
    @Volatile private var poseLandmarker: PoseLandmarker? = null
    @Volatile private var selectedCamera = CameraSelection.FRONT
    @Volatile private var selectedModel = PoseModel.LITE
    @Volatile private var selectedTrackingProfile = PoseTrackingProfile.SQUAT
    @Volatile private var targetFps = DEFAULT_TARGET_FPS
    @Volatile private var previewGeometry = PreviewGeometry.initial(mirrored = false)
    @Volatile private var lastInputWidth = 0
    @Volatile private var lastInputHeight = 0
    @Volatile private var lastRotationDegrees = 0

    private val generation = AtomicLong(0L)
    private val frameId = AtomicLong(0L)
    private val inferenceInFlight = AtomicBoolean(false)
    private val nextEligibleFrameNs = AtomicLong(0L)
    private val lastInferenceErrorAtNs = AtomicLong(0L)
    private var lastMediaPipeTimestampMs = -1L

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        textureRegistry = binding.textureRegistry
        mainHandler = Handler(Looper.getMainLooper())
        analysisExecutor =
            Executors.newSingleThreadExecutor { runnable ->
                Thread(runnable, ANALYSIS_THREAD_NAME).apply { isDaemon = false }
            }
        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL_NAME)
        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL_NAME)
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
        engineAttached = true
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> start(call, result)
            "pause" -> pause(result)
            "resume" -> resume(result)
            "switchCamera" -> switchCamera(call, result)
            "setModel" -> setModel(call, result)
            "setTargetFps" -> setTargetFps(call, result)
            "startVideoRecording" -> startVideoRecording(call, result)
            "stopVideoRecording" -> stopVideoRecording(result)
            "cancelVideoRecording" -> cancelVideoRecording(result)
            "dispose" -> dispose(result)
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        attachActivity(binding.activity)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        attachActivity(binding.activity)
        if (!resumeAfterConfigurationChange || userPaused || !sessionActive) return

        val owner = lifecycleOwner
        if (owner != null && owner.lifecycle.currentState.isAtLeast(Lifecycle.State.STARTED)) {
            resumeAfterConfigurationChange = false
            lifecycleSuspended = false
            try {
                bindCameraUseCases()
            } catch (error: Exception) {
                lifecycleSuspended = true
                emitRuntimeError(
                    code = ERROR_CAMERA_INITIALIZATION_FAILED,
                    message = "Camera could not be rebound after the activity changed.",
                    trackingState = TrackingState.CAMERA_UNAVAILABLE,
                    cause = error,
                )
            }
        } else {
            resumeWhenLifecycleStarts = true
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        resumeAfterConfigurationChange = sessionActive && !userPaused
        detachActivity()
    }

    override fun onDetachedFromActivity() {
        resumeAfterConfigurationChange = false
        detachActivity()
    }

    override fun onStart(owner: LifecycleOwner) {
        if (owner !== lifecycleOwner || !resumeWhenLifecycleStarts) return
        resumeWhenLifecycleStarts = false
        resumeAfterConfigurationChange = false
        if (!sessionActive || userPaused) return

        lifecycleSuspended = false
        try {
            bindCameraUseCases()
        } catch (error: Exception) {
            lifecycleSuspended = true
            emitRuntimeError(
                code = ERROR_CAMERA_INITIALIZATION_FAILED,
                message = "Camera could not resume after the activity changed.",
                trackingState = TrackingState.CAMERA_UNAVAILABLE,
                cause = error,
            )
        }
    }

    override fun onStop(owner: LifecycleOwner) {
        if (owner !== lifecycleOwner || !sessionActive) return
        if (userPaused && recording == null) return
        lifecycleSuspended = true
        analysisEnabled = false
        abandonVideoRecording()
        unbindCameraUseCases()
        releaseVideoCaptureForReprobe()
        emitStatusFrame(TrackingState.LOST)
    }

    private fun attachActivity(newActivity: Activity) {
        lifecycleOwner?.lifecycle?.removeObserver(this)
        activity = newActivity
        lifecycleOwner = newActivity as? LifecycleOwner
        lifecycleOwner?.lifecycle?.addObserver(this)
    }

    private fun detachActivity() {
        analysisEnabled = false
        abandonVideoRecording()
        unbindCameraUseCases()
        releaseVideoCaptureForReprobe()
        lifecycleSuspended = sessionActive
        lifecycleOwner?.lifecycle?.removeObserver(this)
        lifecycleOwner = null
        activity = null
    }

    private fun start(call: MethodCall, result: MethodChannel.Result) {
        if (!beginOperation(result)) return
        if (sessionActive) {
            finishOperationError(ERROR_ALREADY_STARTED, "The pose engine is already running.")
            return
        }

        val camera = CameraSelection.from(call.argument<String>("camera"))
        val model = PoseModel.from(call.argument<String>("model"))
        val trackingProfile =
            PoseTrackingProfile.from(call.argument<String>("trackingProfile"))
        val fps = parseTargetFps(call.argument<Number>("targetFps"))
        val enableVideoRecording = call.argument<Boolean>("enableVideoRecording") ?: false
        if (camera == null || model == null || trackingProfile == null || fps == null) {
            finishOperationError(
                ERROR_INVALID_ARGUMENTS,
                "camera must be front/back, model must be lite/full/heavy, " +
                    "trackingProfile must be squat/pushup/plank, and targetFps must be 15..30.",
            )
            return
        }
        if (!hasCameraPermission()) {
            finishOperationError(
                ERROR_PERMISSION_DENIED,
                "Camera permission must be granted before starting pose detection.",
            )
            return
        }
        val owner = lifecycleOwner
        if (activity == null || owner == null) {
            finishOperationError(
                ERROR_ACTIVITY_UNAVAILABLE,
                "A LifecycleOwner activity is required to start the camera.",
            )
            return
        }
        if (!owner.lifecycle.currentState.isAtLeast(Lifecycle.State.STARTED)) {
            finishOperationError(
                ERROR_LIFECYCLE_INACTIVE,
                "The activity must be visible before starting the camera.",
            )
            return
        }

        selectedCamera = camera
        selectedModel = model
        selectedTrackingProfile = trackingProfile
        targetFps = fps
        videoRecordingRequested = enableVideoRecording
        recordingSupported = false
        videoCapabilityProbed = false
        recordingCommand = RecordingCommand.NONE
        recordingCancelRequested = false
        recordingPartialFile = null
        recordingFinalFile = null
        resetVideoTimeline()
        if (enableVideoRecording) cleanupPartialRecordings()
        userPaused = false
        lifecycleSuspended = false
        sessionActive = true
        analysisEnabled = false
        frameId.set(0L)
        nextEligibleFrameNs.set(0L)
        lastInferenceErrorAtNs.set(0L)
        lastCameraErrorCode = null
        lastCameraErrorAtNs = 0L
        lastInputWidth = 0
        lastInputHeight = 0
        lastRotationDegrees = 0
        val token = generation.incrementAndGet()

        try {
            surfaceProducer = textureRegistry.createSurfaceProducer()
            previewGeometry =
                PreviewGeometry.initial(
                    mirrored = false,
                    handlesCropAndRotation = surfaceProducer?.handlesCropAndRotation() == true,
                )
        } catch (error: Exception) {
            sessionActive = false
            userPaused = true
            finishOperationError(
                ERROR_SURFACE_UNAVAILABLE,
                "Flutter could not allocate a preview surface.",
                errorDetails(error),
            )
            return
        }

        analysisExecutor.execute {
            val landmarker =
                try {
                    createPoseLandmarker(model)
                } catch (error: Exception) {
                    mainHandler.post {
                        if (generation.get() != token || !sessionActive) return@post
                        cleanupSessionOnMain()?.let(::closeLandmarkerAsync)
                        finishOperationError(
                            ERROR_MODEL_UNAVAILABLE,
                            "The ${model.channelValue} pose model could not be loaded.",
                            mapOf(
                                "assetPath" to model.assetPath,
                                "cause" to (error.message ?: error.javaClass.simpleName),
                            ),
                        )
                    }
                    return@execute
                }

            mainHandler.post {
                if (!engineAttached || generation.get() != token || !sessionActive) {
                    closeLandmarkerAsync(landmarker)
                    return@post
                }
                poseLandmarker = landmarker
                requestCameraProviderAndBind(token)
            }
        }
    }

    private fun requestCameraProviderAndBind(token: Long) {
        val future = ProcessCameraProvider.getInstance(applicationContext)
        future.addListener(
            {
                if (!engineAttached || generation.get() != token || !sessionActive) return@addListener
                try {
                    cameraProvider = future.get()
                    bindCameraUseCases()
                    val textureId = surfaceProducer?.id()
                        ?: throw IllegalStateException("Preview texture was released before binding.")
                    finishOperationSuccess(
                        mapOf(
                            "textureId" to textureId,
                            "recordingSupported" to recordingSupported,
                        ),
                    )
                } catch (error: Exception) {
                    val rootCause =
                        if (error is ExecutionException) error.cause ?: error else error
                    val (code, message) =
                        when {
                            rootCause is SecurityException ->
                                ERROR_PERMISSION_DENIED to
                                    "Camera permission was revoked while the camera was starting."
                            rootCause is IllegalArgumentException &&
                                rootCause.message == CAMERA_NOT_AVAILABLE_MESSAGE ->
                                ERROR_CAMERA_UNAVAILABLE to
                                    "The requested camera is not available on this device."
                            else ->
                                ERROR_CAMERA_INITIALIZATION_FAILED to
                                    "CameraX could not initialize the camera."
                        }
                    cleanupSessionOnMain()?.let(::closeLandmarkerAsync)
                    finishOperationError(
                        code,
                        message,
                        errorDetails(rootCause),
                    )
                }
            },
            ContextCompat.getMainExecutor(applicationContext),
        )
    }

    private fun pause(result: MethodChannel.Result) {
        if (!ensureReadyForMethod(result)) return
        userPaused = true
        analysisEnabled = false
        unbindCameraUseCases()
        result.success(null)
    }

    private fun resume(result: MethodChannel.Result) {
        if (!ensureReadyForMethod(result)) return
        if (!hasCameraPermission()) {
            result.error(
                ERROR_PERMISSION_DENIED,
                "Camera permission was revoked while pose detection was paused.",
                null,
            )
            return
        }
        val owner = lifecycleOwner
        if (activity == null || owner == null) {
            result.error(
                ERROR_ACTIVITY_UNAVAILABLE,
                "A LifecycleOwner activity is required to resume the camera.",
                null,
            )
            return
        }
        if (!owner.lifecycle.currentState.isAtLeast(Lifecycle.State.STARTED)) {
            result.error(
                ERROR_LIFECYCLE_INACTIVE,
                "The activity must be visible before resuming the camera.",
                null,
            )
            return
        }
        if (!userPaused && !lifecycleSuspended) {
            result.success(null)
            return
        }

        userPaused = false
        lifecycleSuspended = false
        try {
            bindCameraUseCases()
            result.success(null)
        } catch (error: Exception) {
            userPaused = true
            lifecycleSuspended = true
            result.error(
                ERROR_CAMERA_INITIALIZATION_FAILED,
                "CameraX could not resume the camera.",
                errorDetails(error),
            )
        }
    }

    private fun switchCamera(call: MethodCall, result: MethodChannel.Result) {
        if (!ensureReadyForMethod(result)) return
        val camera = CameraSelection.from(call.argument<String>("camera"))
        if (camera == null) {
            result.error(ERROR_INVALID_ARGUMENTS, "camera must be front or back.", null)
            return
        }
        if (camera == selectedCamera) {
            result.success(null)
            return
        }
        if (recording != null) {
            result.error(
                ERROR_VIDEO_RECORDING_IN_PROGRESS,
                "Stop or cancel the workout video before switching cameras.",
                null,
            )
            return
        }

        val provider = cameraProvider
        val cameraAvailable =
            try {
                provider?.hasCamera(camera.selector) == true
            } catch (error: Exception) {
                result.error(
                    ERROR_CAMERA_UNAVAILABLE,
                    "Camera availability could not be determined.",
                    errorDetails(error),
                )
                return
            }
        if (!cameraAvailable) {
            result.error(
                ERROR_CAMERA_UNAVAILABLE,
                "The requested camera is not available on this device.",
                mapOf("camera" to camera.channelValue),
            )
            return
        }

        val previousCamera = selectedCamera
        val wasBound = !userPaused && !lifecycleSuspended
        analysisEnabled = false
        unbindCameraUseCases()
        releaseVideoCaptureForReprobe()
        selectedCamera = camera
        generation.incrementAndGet()
        previewGeometry =
            PreviewGeometry.initial(
                mirrored = false,
                handlesCropAndRotation = surfaceProducer?.handlesCropAndRotation() == true,
            )
        nextEligibleFrameNs.set(0L)

        try {
            if (wasBound) bindCameraUseCases()
            result.success(null)
        } catch (error: Exception) {
            selectedCamera = previousCamera
            generation.incrementAndGet()
            previewGeometry =
                PreviewGeometry.initial(
                    mirrored = false,
                    handlesCropAndRotation = surfaceProducer?.handlesCropAndRotation() == true,
                )
            try {
                if (wasBound) bindCameraUseCases()
            } catch (rollbackError: Exception) {
                userPaused = true
                lifecycleSuspended = true
                Log.e(TAG, "Failed to restore the previous camera.", rollbackError)
            }
            result.error(
                ERROR_CAMERA_INITIALIZATION_FAILED,
                "CameraX could not switch cameras.",
                errorDetails(error),
            )
        }
    }

    private fun setModel(call: MethodCall, result: MethodChannel.Result) {
        if (!ensureReadyForMethod(result)) return
        val model = PoseModel.from(call.argument<String>("model"))
        if (model == null) {
            result.error(ERROR_INVALID_ARGUMENTS, "model must be lite, full, or heavy.", null)
            return
        }
        if (model == selectedModel) {
            result.success(null)
            return
        }
        if (!beginOperation(result)) return

        analysisEnabled = false
        val token = generation.incrementAndGet()
        analysisExecutor.execute {
            val replacement =
                try {
                    createPoseLandmarker(model)
                } catch (error: Exception) {
                    mainHandler.post {
                        if (generation.get() == token && sessionActive) {
                            analysisEnabled = !userPaused && !lifecycleSuspended
                            finishOperationError(
                                ERROR_MODEL_UNAVAILABLE,
                                "The ${model.channelValue} pose model could not be loaded.",
                                mapOf(
                                    "assetPath" to model.assetPath,
                                    "cause" to (error.message ?: error.javaClass.simpleName),
                                ),
                            )
                        }
                    }
                    return@execute
                }

            if (generation.get() != token || !sessionActive) {
                replacement.close()
                return@execute
            }
            val previous = poseLandmarker
            poseLandmarker = replacement
            selectedModel = model
            lastMediaPipeTimestampMs = -1L
            previous?.close()
            nextEligibleFrameNs.set(0L)

            mainHandler.post {
                if (generation.get() != token || !sessionActive) return@post
                analysisEnabled = !userPaused && !lifecycleSuspended
                finishOperationSuccess(null)
            }
        }
    }

    private fun setTargetFps(call: MethodCall, result: MethodChannel.Result) {
        if (!ensureReadyForMethod(result)) return
        val fps = parseTargetFps(call.argument<Number>("targetFps"))
        if (fps == null) {
            result.error(ERROR_INVALID_ARGUMENTS, "targetFps must be between 15 and 30.", null)
            return
        }
        targetFps = fps
        nextEligibleFrameNs.set(0L)
        result.success(null)
    }

    private fun startVideoRecording(call: MethodCall, result: MethodChannel.Result) {
        if (!ensureReadyForMethod(result)) return
        if (!videoRecordingRequested || !recordingSupported || videoCapture == null) {
            result.error(
                ERROR_VIDEO_NOT_SUPPORTED,
                "Video recording is disabled or unsupported for this camera configuration.",
                null,
            )
            return
        }
        if (recording != null) {
            result.error(
                ERROR_VIDEO_RECORDING_IN_PROGRESS,
                "A workout video recording is already in progress.",
                null,
            )
            return
        }
        val rawSessionId = call.argument<String>("sessionId")?.trim().orEmpty()
        if (rawSessionId.isEmpty()) {
            result.error(ERROR_INVALID_ARGUMENTS, "sessionId must not be empty.", null)
            return
        }
        if (!beginOperation(result)) return

        try {
            val directory = recordingDirectory()
            cleanupPartialRecordings(directory)
            val basename = "workout_${sanitizeSessionId(rawSessionId)}"
            val partialFile = File(directory, "$basename.partial.mp4")
            val finalFile = File(directory, "$basename.mp4")
            pruneCompletedRecordings(directory, protectedFile = finalFile)
            if (partialFile.exists() && !partialFile.delete()) {
                throw IllegalStateException("The previous partial recording could not be removed.")
            }

            recordingPartialFile = partialFile
            recordingFinalFile = finalFile
            recordingCancelRequested = false
            recordingCommand = RecordingCommand.START
            resetVideoTimeline()
            val outputOptions = FileOutputOptions.Builder(partialFile).build()
            recording =
                videoCapture!!
                    .output
                    .prepareRecording(applicationContext, outputOptions)
                    .start(ContextCompat.getMainExecutor(applicationContext), ::handleVideoRecordEvent)
        } catch (error: Exception) {
            recordingPartialFile?.delete()
            recordingPartialFile = null
            recordingFinalFile = null
            recordingCommand = RecordingCommand.NONE
            resetVideoTimeline()
            finishOperationError(
                ERROR_VIDEO_STORAGE_FAILED,
                "The workout video recording could not be started.",
                errorDetails(error),
            )
        }
    }

    private fun stopVideoRecording(result: MethodChannel.Result) {
        if (!ensureReadyForMethod(result)) return
        val activeRecording = recording
        if (activeRecording == null) {
            result.error(ERROR_VIDEO_NOT_RECORDING, "No workout video is being recorded.", null)
            return
        }
        if (!beginOperation(result)) return
        recordingCommand = RecordingCommand.STOP
        activeRecording.stop()
    }

    private fun cancelVideoRecording(result: MethodChannel.Result) {
        if (!ensureReadyForMethod(result)) return
        val activeRecording = recording
        if (activeRecording == null) {
            recordingPartialFile?.delete()
            recordingPartialFile = null
            recordingFinalFile = null
            resetVideoTimeline()
            result.success(null)
            return
        }
        if (!beginOperation(result)) return
        recordingCommand = RecordingCommand.CANCEL
        recordingCancelRequested = true
        activeRecording.stop()
    }

    private fun handleVideoRecordEvent(event: VideoRecordEvent) {
        checkMainThread()
        when (event) {
            is VideoRecordEvent.Start -> {
                val nowNs = SystemClock.elapsedRealtimeNanos()
                val originUs = nowNs / NANOS_PER_MICROSECOND
                synchronized(videoTimelineLock) {
                    videoTimelineActive = true
                    videoTimelineRunning = true
                    videoTimelineOriginUs = originUs
                    videoAnchorRealtimeNs = nowNs
                    videoAnchorRecordedNs = event.recordingStats.recordedDurationNanos
                    lastVideoElapsedUs = 0L
                }
                if (recordingCommand == RecordingCommand.START) {
                    recordingCommand = RecordingCommand.NONE
                    finishOperationSuccess(mapOf("timelineOriginUs" to originUs))
                }
            }
            is VideoRecordEvent.Status -> updateVideoTimeline(event, running = true)
            is VideoRecordEvent.Pause -> updateVideoTimeline(event, running = false)
            is VideoRecordEvent.Resume -> updateVideoTimeline(event, running = true)
            is VideoRecordEvent.Finalize -> finalizeVideoRecording(event)
        }
    }

    private fun updateVideoTimeline(event: VideoRecordEvent, running: Boolean) {
        synchronized(videoTimelineLock) {
            if (!videoTimelineActive) return
            videoAnchorRealtimeNs = SystemClock.elapsedRealtimeNanos()
            videoAnchorRecordedNs = event.recordingStats.recordedDurationNanos
            videoTimelineRunning = running
            lastVideoElapsedUs =
                max(lastVideoElapsedUs, videoAnchorRecordedNs / NANOS_PER_MICROSECOND)
        }
    }

    private fun finalizeVideoRecording(event: VideoRecordEvent.Finalize) {
        val command = recordingCommand
        val wasCancelled = recordingCancelRequested || command == RecordingCommand.ABORT
        val partialFile = recordingPartialFile
        val finalFile = recordingFinalFile
        recording = null
        recordingPartialFile = null
        recordingFinalFile = null
        recordingCommand = RecordingCommand.NONE
        recordingCancelRequested = false
        resetVideoTimeline()

        if (wasCancelled || command == RecordingCommand.CANCEL) {
            partialFile?.delete()
            if (command == RecordingCommand.CANCEL) finishOperationSuccess(null)
            return
        }

        if (event.error != VideoRecordEvent.Finalize.ERROR_NONE) {
            partialFile?.delete()
            val details =
                buildMap<String, Any> {
                    put("cameraXError", event.error)
                    event.cause?.let { put("cause", it.message ?: it.javaClass.simpleName) }
                }
            if (command == RecordingCommand.START || command == RecordingCommand.STOP) {
                finishOperationError(
                    ERROR_VIDEO_RECORDING_FAILED,
                    "CameraX could not finalize the workout video.",
                    details,
                )
            } else {
                Log.e(TAG, "CameraX finalized the workout video with an error: $details")
            }
            return
        }

        if (command != RecordingCommand.STOP || partialFile == null || finalFile == null) return
        try {
            if (finalFile.exists() && !finalFile.delete()) {
                throw IllegalStateException("The previous workout video could not be replaced.")
            }
            if (!partialFile.renameTo(finalFile)) {
                throw IllegalStateException("The finalized workout video could not be renamed.")
            }
            pruneCompletedRecordings(finalFile.parentFile ?: recordingDirectory(), finalFile)
            finishOperationSuccess(
                mapOf(
                    "path" to finalFile.absolutePath,
                    "durationMilliseconds" to
                        event.recordingStats.recordedDurationNanos / NANOS_PER_MILLISECOND,
                ),
            )
        } catch (error: Exception) {
            partialFile.delete()
            finishOperationError(
                ERROR_VIDEO_STORAGE_FAILED,
                "The finalized workout video could not be stored.",
                errorDetails(error),
            )
        }
    }

    private fun abandonVideoRecording() {
        val activeRecording = recording ?: run {
            recordingPartialFile?.delete()
            recordingPartialFile = null
            recordingFinalFile = null
            resetVideoTimeline()
            return
        }
        recordingCancelRequested = true
        if (recordingCommand == RecordingCommand.START) {
            finishOperationError(
                ERROR_VIDEO_RECORDING_FAILED,
                "The workout video recording was interrupted before it started.",
            )
        }
        recordingCommand = RecordingCommand.ABORT
        activeRecording.stop()
    }

    private fun recordingDirectory(): File {
        val directory = File(applicationContext.noBackupFilesDir, VIDEO_DIRECTORY_NAME)
        if ((!directory.exists() && !directory.mkdirs()) || !directory.isDirectory) {
            throw IllegalStateException("The private workout video directory is unavailable.")
        }
        return directory
    }

    private fun cleanupPartialRecordings(directory: File? = null) {
        val target = directory ?: File(applicationContext.noBackupFilesDir, VIDEO_DIRECTORY_NAME)
        target.listFiles()?.forEach { file ->
            if (file.isFile && file.name.endsWith(PARTIAL_VIDEO_SUFFIX)) file.delete()
        }
    }

    private fun pruneCompletedRecordings(directory: File, protectedFile: File? = null) {
        val completed =
            directory
                .listFiles()
                .orEmpty()
                .filter { file ->
                    file.isFile &&
                        file.extension.equals("mp4", ignoreCase = true) &&
                        !file.name.endsWith(PARTIAL_VIDEO_SUFFIX) &&
                        file != protectedFile
                }.sortedBy(File::lastModified)
        var totalBytes =
            completed.sumOf(File::length) +
                (protectedFile?.takeIf(File::isFile)?.length() ?: 0L)
        for (file in completed) {
            if (totalBytes <= VIDEO_DIRECTORY_LIMIT_BYTES) break
            val length = file.length()
            if (file.delete()) totalBytes -= length
        }
        if (totalBytes > VIDEO_DIRECTORY_LIMIT_BYTES) {
            Log.w(TAG, "Workout video storage exceeds the 2 GiB retention limit.")
        }
    }

    private fun sanitizeSessionId(sessionId: String): String {
        val sanitized =
            sessionId
                .map { character ->
                    if (character.isLetterOrDigit() || character == '-' || character == '_') {
                        character
                    } else {
                        '_'
                    }
                }.joinToString("")
                .take(MAX_SESSION_ID_LENGTH)
        return sanitized.ifEmpty { "session" }
    }

    private fun resetVideoTimeline() {
        synchronized(videoTimelineLock) {
            videoTimelineActive = false
            videoTimelineRunning = false
            videoTimelineOriginUs = null
            videoAnchorRealtimeNs = 0L
            videoAnchorRecordedNs = 0L
            lastVideoElapsedUs = 0L
        }
    }

    private fun videoElapsedUsForFrame(imageTimestampNs: Long): Long? {
        synchronized(videoTimelineLock) {
            if (!videoTimelineActive || videoTimelineOriginUs == null) return null
            val nowNs = SystemClock.elapsedRealtimeNanos()
            val frameRealtimeNs =
                if (imageTimestampNs > 0L &&
                    abs(imageTimestampNs - nowNs) <= CAMERA_TIMESTAMP_TOLERANCE_NS
                ) {
                    imageTimestampNs
                } else {
                    nowNs
                }
            val elapsedNs =
                if (videoTimelineRunning) {
                    videoAnchorRecordedNs + max(0L, frameRealtimeNs - videoAnchorRealtimeNs)
                } else {
                    videoAnchorRecordedNs
                }
            val elapsedUs = max(lastVideoElapsedUs, elapsedNs / NANOS_PER_MICROSECOND)
            lastVideoElapsedUs = elapsedUs
            return elapsedUs
        }
    }

    private fun dispose(result: MethodChannel.Result) {
        if (operationInProgress) {
            result.error(ERROR_BUSY, "Another pose engine operation is still running.", null)
            return
        }
        if (!sessionActive) {
            result.success(null)
            return
        }
        if (!beginOperation(result)) return
        val landmarker = cleanupSessionOnMain()
        analysisExecutor.execute {
            try {
                landmarker?.close()
            } catch (error: Exception) {
                Log.w(TAG, "Pose landmarker close failed.", error)
            } finally {
                mainHandler.post { finishOperationSuccess(null) }
            }
        }
    }

    private fun bindCameraUseCases() {
        checkMainThread()
        if (!sessionActive || userPaused || lifecycleSuspended) return
        if (!hasCameraPermission()) throw SecurityException("Camera permission is not granted.")
        val provider = cameraProvider ?: throw IllegalStateException("Camera provider is unavailable.")
        val owner = lifecycleOwner ?: throw IllegalStateException("Lifecycle owner is unavailable.")
        val producer = surfaceProducer ?: throw IllegalStateException("Preview surface is unavailable.")
        if (!provider.hasCamera(selectedCamera.selector)) {
            throw IllegalArgumentException(CAMERA_NOT_AVAILABLE_MESSAGE)
        }

        analysisEnabled = false
        unbindCameraUseCases()
        val targetRotation = activity?.window?.decorView?.display?.rotation ?: Surface.ROTATION_0
        val resolutionSelector =
            ResolutionSelector.Builder()
                .setAspectRatioStrategy(AspectRatioStrategy.RATIO_4_3_FALLBACK_AUTO_STRATEGY)
                .setResolutionStrategy(
                    ResolutionStrategy(
                        PREFERRED_CAMERA_RESOLUTION,
                        ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER_THEN_LOWER,
                    ),
                ).build()
        val token = generation.get()

        val newPreview =
            Preview.Builder()
                .setTargetRotation(targetRotation)
                .setMirrorMode(MirrorMode.MIRROR_MODE_OFF)
                .setResolutionSelector(resolutionSelector)
                .build()
        newPreview.setSurfaceProvider(
            ContextCompat.getMainExecutor(applicationContext),
            createSurfaceProvider(producer, token),
        )

        val newAnalysis =
            ImageAnalysis.Builder()
                .setTargetRotation(targetRotation)
                .setResolutionSelector(resolutionSelector)
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)
                .build()
        newAnalysis.setAnalyzer(analysisExecutor, ::analyzeImage)

        try {
            val camera =
                when {
                    videoCapture != null ->
                        provider.bindToLifecycle(
                            owner,
                            selectedCamera.selector,
                            newPreview,
                            newAnalysis,
                        )
                    videoRecordingRequested && !videoCapabilityProbed -> {
                        videoCapabilityProbed = true
                        val newVideoCapture = createVideoCapture()
                        try {
                            val boundCamera =
                                provider.bindToLifecycle(
                                    owner,
                                    selectedCamera.selector,
                                    newPreview,
                                    newAnalysis,
                                    newVideoCapture,
                                )
                            videoCapture = newVideoCapture
                            recordingSupported = true
                            boundCamera
                        } catch (videoError: Exception) {
                            provider.unbind(newPreview, newAnalysis, newVideoCapture)
                            videoCapture = null
                            recordingSupported = false
                            Log.w(
                                TAG,
                                "Preview + analysis + video is unsupported; continuing without recording.",
                                videoError,
                            )
                            provider.bindToLifecycle(
                                owner,
                                selectedCamera.selector,
                                newPreview,
                                newAnalysis,
                            )
                        }
                    }
                    else ->
                        provider.bindToLifecycle(
                            owner,
                            selectedCamera.selector,
                            newPreview,
                            newAnalysis,
                        )
                }
            preview = newPreview
            imageAnalysis = newAnalysis
            observeCameraState(camera)
            analysisEnabled = true
        } catch (error: Exception) {
            newAnalysis.clearAnalyzer()
            provider.unbind(newPreview, newAnalysis)
            throw error
        }
    }

    private fun createVideoCapture(): VideoCapture<Recorder> {
        val qualitySelector =
            QualitySelector.from(
                Quality.SD,
                FallbackStrategy.lowerQualityOrHigherThan(Quality.SD),
            )
        val recorder =
            Recorder.Builder()
                .setQualitySelector(qualitySelector)
                .setTargetVideoEncodingBitRate(VIDEO_BIT_RATE)
                .build()
        return VideoCapture.withOutput(recorder)
    }

    private fun unbindCameraUseCases() {
        checkMainThread()
        analysisEnabled = false
        imageAnalysis?.clearAnalyzer()
        removeCameraStateObserver()
        val useCases = listOfNotNull<UseCase>(preview, imageAnalysis)
        if (useCases.isNotEmpty()) {
            try {
                cameraProvider?.unbind(*useCases.toTypedArray())
            } catch (error: Exception) {
                Log.w(TAG, "Camera use cases could not be unbound cleanly.", error)
            }
        }
        preview = null
        imageAnalysis = null
    }

    private fun releaseVideoCaptureForReprobe() {
        checkMainThread()
        val activeVideoCapture = videoCapture ?: return
        try {
            cameraProvider?.unbind(activeVideoCapture)
        } catch (error: Exception) {
            Log.w(TAG, "Video capture could not be unbound cleanly.", error)
        }
        videoCapture = null
        recordingSupported = false
        videoCapabilityProbed = false
    }

    private fun createSurfaceProvider(
        producer: TextureRegistry.SurfaceProducer,
        token: Long,
    ): Preview.SurfaceProvider = Preview.SurfaceProvider { request ->
        producer.setCallback(
            object : TextureRegistry.SurfaceProducer.Callback {
                override fun onSurfaceAvailable() = Unit

                override fun onSurfaceCleanup() {
                    if (engineAttached &&
                        sessionActive &&
                        !userPaused &&
                        !lifecycleSuspended &&
                        generation.get() == token
                    ) {
                        request.invalidate()
                    }
                }
            },
        )

        val resolution = request.resolution
        producer.setSize(resolution.width, resolution.height)
        request.setTransformationInfoListener(
            ContextCompat.getMainExecutor(applicationContext),
        ) { info ->
            if (engineAttached && sessionActive && generation.get() == token) {
                previewGeometry =
                    PreviewGeometry.from(
                        rotationDegrees = info.rotationDegrees,
                        mirrored = false,
                        handlesCropAndRotation = producer.handlesCropAndRotation(),
                    )
            }
        }

        val flutterSurface =
            try {
                producer.getForcedNewSurface()
            } catch (error: Exception) {
                request.willNotProvideSurface()
                emitRuntimeError(
                    code = ERROR_SURFACE_UNAVAILABLE,
                    message = "Flutter could not provide a camera preview surface.",
                    trackingState = TrackingState.CAMERA_UNAVAILABLE,
                    cause = error,
                    token = token,
                )
                return@SurfaceProvider
            }

        request.provideSurface(
            flutterSurface,
            ContextCompat.getMainExecutor(applicationContext),
        ) { surfaceResult ->
            flutterSurface.release()
            if (surfaceResult.resultCode == SurfaceRequest.Result.RESULT_INVALID_SURFACE) {
                emitRuntimeError(
                    code = ERROR_SURFACE_UNAVAILABLE,
                    message = "CameraX rejected the preview surface.",
                    trackingState = TrackingState.CAMERA_UNAVAILABLE,
                    token = token,
                )
            }
        }
    }

    private fun observeCameraState(camera: Camera) {
        removeCameraStateObserver()
        val owner = lifecycleOwner ?: return
        val liveData = camera.cameraInfo.cameraState
        val observer =
            Observer<CameraState> { state ->
                val error = state.error ?: return@Observer
                val nowNs = SystemClock.elapsedRealtimeNanos()
                if (lastCameraErrorCode == error.code &&
                    nowNs - lastCameraErrorAtNs < RUNTIME_ERROR_THROTTLE_NS
                ) {
                    return@Observer
                }
                lastCameraErrorCode = error.code
                lastCameraErrorAtNs = nowNs
                val (code, message) = cameraErrorDescription(error.code)
                emitRuntimeError(
                    code = code,
                    message = message,
                    trackingState = TrackingState.CAMERA_UNAVAILABLE,
                    cause = error.cause,
                )
            }
        liveData.observe(owner, observer)
        observedCameraState = liveData
        cameraStateObserver = observer
    }

    private fun removeCameraStateObserver() {
        val observer = cameraStateObserver
        if (observer != null) observedCameraState?.removeObserver(observer)
        observedCameraState = null
        cameraStateObserver = null
    }

    private fun analyzeImage(image: ImageProxy) {
        if (!analysisEnabled || !sessionActive) {
            image.close()
            return
        }

        val nowNs = SystemClock.elapsedRealtimeNanos()
        if (nowNs < nextEligibleFrameNs.get()) {
            image.close()
            return
        }
        if (!inferenceInFlight.compareAndSet(false, true)) {
            image.close()
            return
        }
        nextEligibleFrameNs.set(nowNs + NANOS_PER_SECOND / targetFps.coerceIn(MIN_FPS, MAX_FPS))

        val token = generation.get()
        val timestampNs = image.imageInfo.timestamp.coerceAtLeast(0L)
        val timestampUs = timestampNs / NANOS_PER_MICROSECOND
        val videoElapsedUs = videoElapsedUsForFrame(timestampNs)
        var mediaPipeTimestampMs = timestampNs / NANOS_PER_MILLISECOND
        if (mediaPipeTimestampMs <= lastMediaPipeTimestampMs) {
            mediaPipeTimestampMs = lastMediaPipeTimestampMs + 1L
        }
        lastMediaPipeTimestampMs = mediaPipeTimestampMs
        val rotationDegrees = image.imageInfo.rotationDegrees
        val outputWidth = if (rotationDegrees % 180 == 0) image.width else image.height
        val outputHeight = if (rotationDegrees % 180 == 0) image.height else image.width
        lastInputWidth = outputWidth
        lastInputHeight = outputHeight
        lastRotationDegrees = rotationDegrees
        val startedNs = SystemClock.elapsedRealtimeNanos()

        try {
            val mediaImage = image.image
                ?: throw IllegalStateException("CameraX did not expose an android.media.Image.")
            val mpImage = MediaImageBuilder(mediaImage).build()
            val processingOptions =
                ImageProcessingOptions.builder().setRotationDegrees(rotationDegrees).build()
            val landmarker = poseLandmarker
                ?: throw IllegalStateException("Pose landmarker is not initialized.")
            val poseResult =
                landmarker.detectForVideo(mpImage, processingOptions, mediaPipeTimestampMs)
            val latencyMs =
                ((SystemClock.elapsedRealtimeNanos() - startedNs) / NANOS_PER_MILLISECOND).toInt()

            if (analysisEnabled && generation.get() == token) {
                dispatchFrame(
                    buildFrameMap(
                        result = poseResult,
                        timestampUs = timestampUs,
                        videoElapsedUs = videoElapsedUs,
                        rotationDegrees = rotationDegrees,
                        inputWidth = outputWidth,
                        inputHeight = outputHeight,
                        inferenceLatencyMs = latencyMs,
                    ),
                    token,
                )
            }
            // ImageProxy owns mediaImage. Closing it below returns the buffer to CameraX;
            // closing MPImage as well would close the same android.media.Image twice.
        } catch (error: Exception) {
            val previousErrorNs = lastInferenceErrorAtNs.get()
            if (nowNs - previousErrorNs >= RUNTIME_ERROR_THROTTLE_NS &&
                lastInferenceErrorAtNs.compareAndSet(previousErrorNs, nowNs)
            ) {
                Log.w(TAG, "MediaPipe skipped a failed pose frame and will retry.", error)
                emitStatusFrame(TrackingState.LOST)
            }
        } finally {
            image.close()
            inferenceInFlight.set(false)
        }
    }

    private fun buildFrameMap(
        result: PoseLandmarkerResult,
        timestampUs: Long,
        videoElapsedUs: Long?,
        rotationDegrees: Int,
        inputWidth: Int,
        inputHeight: Int,
        inferenceLatencyMs: Int,
    ): Map<String, Any> {
        val poses = result.landmarks()
        val worlds = result.worldLandmarks()
        val personCount = poses.size
        val primary = poses.firstOrNull()
        val primaryWorld = worlds.firstOrNull()
        // MediaPipe keeps landmark coordinates in the CameraX buffer space
        // even when ImageProcessingOptions rotates the inference input.
        // Rotate the payload once into the same upright space as the preview.
        val normalizedLandmarks =
            primary?.let { PosePayload.flattenNormalized(it, rotationDegrees) } ?: FloatArray(0)
        val worldLandmarks =
            primaryWorld?.let { PosePayload.flattenWorld(it, rotationDegrees) }
                ?: if (primary == null) FloatArray(0) else PosePayload.zeroLandmarks()
        val trackingState =
            when {
                personCount == 0 -> TrackingState.NO_PERSON
                personCount > 1 -> TrackingState.MULTIPLE_PEOPLE
                primary == null ||
                    !PosePayload.hasRequiredBody(primary, selectedTrackingProfile) ->
                    TrackingState.PARTIAL_BODY
                else -> TrackingState.TRACKING
            }
        val geometry = previewGeometry
        val nextFrameId = frameId.incrementAndGet()

        return buildMap {
            put("frameId", nextFrameId)
            put("timestampUs", timestampUs)
            videoElapsedUs?.let { put("videoElapsedUs", it) }
            put("trackingState", trackingState.channelValue)
            put("personCount", personCount)
            put("normalizedLandmarks", normalizedLandmarks)
            put("worldLandmarks", worldLandmarks)
            // Coordinates stay canonical and unmirrored. This flag describes the preview.
            put("mirrored", geometry.mirrored)
            put("rotationDegrees", rotationDegrees)
            put("inputWidth", inputWidth)
            put("inputHeight", inputHeight)
            put("inferenceLatencyMilliseconds", inferenceLatencyMs)
            put("model", selectedModel.channelValue)
            // Row-major homogeneous transform from canonical normalized landmarks to the
            // normalized coordinates currently rendered by the Flutter texture.
            put("previewTransform", geometry.canonicalToTexture)
            put("previewHandlesCropAndRotation", geometry.handlesCropAndRotation)
        }
    }

    private fun dispatchFrame(frame: Map<String, Any>, token: Long) {
        mainHandler.post {
            if (engineAttached && sessionActive && generation.get() == token) {
                eventSink?.success(frame)
            }
        }
    }

    private fun emitStatusFrame(trackingState: TrackingState) {
        if (!sessionActive) return
        val token = generation.get()
        val geometry = previewGeometry
        val timestampNs = SystemClock.elapsedRealtimeNanos()
        val frame =
            buildMap<String, Any> {
                put("frameId", frameId.incrementAndGet())
                put("timestampUs", timestampNs / NANOS_PER_MICROSECOND)
                videoElapsedUsForFrame(timestampNs)?.let { put("videoElapsedUs", it) }
                put("trackingState", trackingState.channelValue)
                put("personCount", 0)
                put("normalizedLandmarks", FloatArray(0))
                put("worldLandmarks", FloatArray(0))
                put("mirrored", geometry.mirrored)
                put("rotationDegrees", lastRotationDegrees)
                put("inputWidth", lastInputWidth)
                put("inputHeight", lastInputHeight)
                put("inferenceLatencyMilliseconds", 0)
                put("model", selectedModel.channelValue)
                put("previewTransform", geometry.canonicalToTexture)
                put("previewHandlesCropAndRotation", geometry.handlesCropAndRotation)
            }
        dispatchFrame(frame, token)
    }

    private fun emitRuntimeError(
        code: String,
        message: String,
        trackingState: TrackingState,
        cause: Throwable? = null,
        token: Long = generation.get(),
    ) {
        Log.e(TAG, message, cause)
        val geometry = previewGeometry
        val timestampNs = SystemClock.elapsedRealtimeNanos()
        val statusFrame =
            buildMap<String, Any> {
                put("frameId", frameId.incrementAndGet())
                put("timestampUs", timestampNs / NANOS_PER_MICROSECOND)
                videoElapsedUsForFrame(timestampNs)?.let { put("videoElapsedUs", it) }
                put("trackingState", trackingState.channelValue)
                put("personCount", 0)
                put("normalizedLandmarks", FloatArray(0))
                put("worldLandmarks", FloatArray(0))
                put("mirrored", geometry.mirrored)
                put("rotationDegrees", lastRotationDegrees)
                put("inputWidth", lastInputWidth)
                put("inputHeight", lastInputHeight)
                put("inferenceLatencyMilliseconds", 0)
                put("model", selectedModel.channelValue)
                put("previewTransform", geometry.canonicalToTexture)
                put("previewHandlesCropAndRotation", geometry.handlesCropAndRotation)
            }
        val details =
            buildMap<String, Any> {
                put("trackingState", trackingState.channelValue)
                cause?.let {
                    put("cause", it.message ?: it.javaClass.simpleName)
                    put("exception", it.javaClass.simpleName)
                }
            }
        mainHandler.post {
            if (!engineAttached || !sessionActive || generation.get() != token) return@post
            eventSink?.success(statusFrame)
            eventSink?.error(code, message, details)
        }
    }

    private fun createPoseLandmarker(model: PoseModel): PoseLandmarker {
        applicationContext.assets.open(model.assetPath).use { stream ->
            if (stream.read() < 0) throw IllegalStateException("Model asset is empty.")
        }
        val baseOptions =
            BaseOptions.builder()
                .setModelAssetPath(model.assetPath)
                .setDelegate(Delegate.CPU)
                .build()
        val options =
            PoseLandmarker.PoseLandmarkerOptions.builder()
                .setBaseOptions(baseOptions)
                .setRunningMode(RunningMode.VIDEO)
                .setNumPoses(MAX_POSES)
                .setMinPoseDetectionConfidence(MIN_POSE_DETECTION_CONFIDENCE)
                .setMinPosePresenceConfidence(MIN_POSE_PRESENCE_CONFIDENCE)
                .setMinTrackingConfidence(MIN_TRACKING_CONFIDENCE)
                .setOutputSegmentationMasks(false)
                .build()
        lastMediaPipeTimestampMs = -1L
        return PoseLandmarker.createFromOptions(applicationContext, options)
    }

    private fun cleanupSessionOnMain(): PoseLandmarker? {
        checkMainThread()
        abandonVideoRecording()
        analysisEnabled = false
        sessionActive = false
        userPaused = true
        lifecycleSuspended = false
        resumeAfterConfigurationChange = false
        resumeWhenLifecycleStarts = false
        generation.incrementAndGet()
        unbindCameraUseCases()
        releaseVideoCaptureForReprobe()
        try {
            surfaceProducer?.release()
        } catch (error: Exception) {
            Log.w(TAG, "Preview surface release failed.", error)
        }
        surfaceProducer = null
        val landmarker = poseLandmarker
        poseLandmarker = null
        nextEligibleFrameNs.set(0L)
        inferenceInFlight.set(false)
        videoRecordingRequested = false
        recordingSupported = false
        videoCapabilityProbed = false
        return landmarker
    }

    private fun closeLandmarkerAsync(landmarker: PoseLandmarker) {
        try {
            analysisExecutor.execute {
                try {
                    landmarker.close()
                } catch (error: Exception) {
                    Log.w(TAG, "Pose landmarker close failed.", error)
                }
            }
        } catch (_: RejectedExecutionException) {
            // The engine is already detaching, so no camera frame can race this close.
            try {
                landmarker.close()
            } catch (error: Exception) {
                Log.w(TAG, "Pose landmarker close failed after executor shutdown.", error)
            }
        }
    }

    private fun ensureReadyForMethod(result: MethodChannel.Result): Boolean {
        if (operationInProgress) {
            result.error(ERROR_BUSY, "Another pose engine operation is still running.", null)
            return false
        }
        if (!sessionActive) {
            result.error(ERROR_NOT_STARTED, "The pose engine has not been started.", null)
            return false
        }
        return true
    }

    private fun beginOperation(result: MethodChannel.Result): Boolean {
        if (operationInProgress) {
            result.error(ERROR_BUSY, "Another pose engine operation is still running.", null)
            return false
        }
        operationInProgress = true
        pendingOperationResult = result
        return true
    }

    private fun finishOperationSuccess(value: Any?) {
        val result = pendingOperationResult
        pendingOperationResult = null
        operationInProgress = false
        result?.success(value)
    }

    private fun finishOperationError(code: String, message: String, details: Any? = null) {
        val result = pendingOperationResult
        pendingOperationResult = null
        operationInProgress = false
        result?.error(code, message, details)
    }

    private fun hasCameraPermission(): Boolean =
        ContextCompat.checkSelfPermission(applicationContext, Manifest.permission.CAMERA) ==
            PackageManager.PERMISSION_GRANTED

    private fun parseTargetFps(value: Number?): Int? {
        val fps = value?.toInt() ?: DEFAULT_TARGET_FPS
        return fps.takeIf { it in MIN_FPS..MAX_FPS }
    }

    private fun checkMainThread() {
        check(Looper.myLooper() == Looper.getMainLooper()) {
            "Camera lifecycle operations must run on the Android main thread."
        }
    }

    private fun errorDetails(error: Throwable): Map<String, String> =
        mapOf(
            "cause" to (error.message ?: error.javaClass.simpleName),
            "exception" to error.javaClass.simpleName,
        )

    private fun cameraErrorDescription(code: Int): Pair<String, String> =
        when (code) {
            CameraState.ERROR_CAMERA_IN_USE,
            CameraState.ERROR_MAX_CAMERAS_IN_USE,
            -> ERROR_CAMERA_IN_USE to "The camera is currently in use by another app or camera client."
            CameraState.ERROR_CAMERA_DISABLED ->
                ERROR_CAMERA_DISABLED to "Camera access is disabled by the system or device policy."
            CameraState.ERROR_DO_NOT_DISTURB_MODE_ENABLED ->
                ERROR_CAMERA_DISABLED to "Camera access is blocked while Do Not Disturb mode is active."
            CameraState.ERROR_STREAM_CONFIG ->
                ERROR_CAMERA_INITIALIZATION_FAILED to "The camera stream configuration is unsupported."
            CameraState.ERROR_CAMERA_FATAL_ERROR ->
                ERROR_CAMERA_UNAVAILABLE to "The camera reported a fatal device error."
            else -> ERROR_CAMERA_UNAVAILABLE to "The camera is temporarily unavailable."
        }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        pendingOperationResult?.error(
            ERROR_PLUGIN_DETACHED,
            "The Flutter engine detached before the native operation completed.",
            null,
        )
        pendingOperationResult = null
        operationInProgress = false
        engineAttached = false
        eventSink = null
        lifecycleOwner?.lifecycle?.removeObserver(this)
        lifecycleOwner = null
        activity = null

        val landmarker = if (sessionActive) cleanupSessionOnMain() else poseLandmarker.also {
            poseLandmarker = null
        }
        analysisExecutor.execute {
            try {
                landmarker?.close()
            } catch (error: Exception) {
                Log.w(TAG, "Pose landmarker close failed during engine detach.", error)
            }
        }
        analysisExecutor.shutdown()
        cameraProvider = null
    }

    private enum class CameraSelection(
        val channelValue: String,
        val selector: CameraSelector,
    ) {
        FRONT("front", CameraSelector.DEFAULT_FRONT_CAMERA),
        BACK("back", CameraSelector.DEFAULT_BACK_CAMERA),
        ;

        companion object {
            fun from(value: String?): CameraSelection? =
                entries.firstOrNull { it.channelValue == (value ?: FRONT.channelValue) }
        }
    }

    private enum class PoseModel(
        val channelValue: String,
        val assetPath: String,
    ) {
        LITE("lite", "pose_landmarker_lite.task"),
        FULL("full", "pose_landmarker_full.task"),
        HEAVY("heavy", "pose_landmarker_heavy.task"),
        ;

        companion object {
            fun from(value: String?): PoseModel? =
                entries.firstOrNull { it.channelValue == (value ?: LITE.channelValue) }
        }
    }

    private enum class TrackingState(val channelValue: String) {
        TRACKING("tracking"),
        NO_PERSON("noPerson"),
        PARTIAL_BODY("partialBody"),
        MULTIPLE_PEOPLE("multiplePeople"),
        LOST("lost"),
        CAMERA_UNAVAILABLE("cameraUnavailable"),
    }

    private enum class RecordingCommand {
        NONE,
        START,
        STOP,
        CANCEL,
        ABORT,
    }

    private companion object {
        const val TAG = "MotionfitPose"
        const val METHOD_CHANNEL_NAME = "motionfit_pose/methods"
        const val EVENT_CHANNEL_NAME = "motionfit_pose/events"
        const val ANALYSIS_THREAD_NAME = "motionfit-pose-analysis"
        const val CAMERA_NOT_AVAILABLE_MESSAGE = "requested_camera_not_available"
        const val DEFAULT_TARGET_FPS = 30
        const val MIN_FPS = 15
        const val MAX_FPS = 30
        // Keep the real-time detector identical to motion-fit3's mobile worker.
        const val MAX_POSES = 1
        const val MIN_POSE_DETECTION_CONFIDENCE = 0.4f
        const val MIN_POSE_PRESENCE_CONFIDENCE = 0.4f
        const val MIN_TRACKING_CONFIDENCE = 0.5f
        const val NANOS_PER_SECOND = 1_000_000_000L
        const val NANOS_PER_MILLISECOND = 1_000_000L
        const val NANOS_PER_MICROSECOND = 1_000L
        const val RUNTIME_ERROR_THROTTLE_NS = 2L * NANOS_PER_SECOND
        const val CAMERA_TIMESTAMP_TOLERANCE_NS = 5L * NANOS_PER_SECOND
        const val VIDEO_BIT_RATE = 1_500_000
        const val VIDEO_DIRECTORY_NAME = "motionfit_workout_videos"
        const val PARTIAL_VIDEO_SUFFIX = ".partial.mp4"
        const val MAX_SESSION_ID_LENGTH = 80
        const val VIDEO_DIRECTORY_LIMIT_BYTES = 2L * 1024L * 1024L * 1024L
        val PREFERRED_CAMERA_RESOLUTION = Size(640, 480)

        const val ERROR_INVALID_ARGUMENTS = "invalid_arguments"
        const val ERROR_PERMISSION_DENIED = "permission_denied"
        const val ERROR_ACTIVITY_UNAVAILABLE = "activity_unavailable"
        const val ERROR_LIFECYCLE_INACTIVE = "lifecycle_inactive"
        const val ERROR_ALREADY_STARTED = "already_started"
        const val ERROR_NOT_STARTED = "not_started"
        const val ERROR_BUSY = "busy"
        const val ERROR_CAMERA_UNAVAILABLE = "camera_unavailable"
        const val ERROR_CAMERA_IN_USE = "camera_in_use"
        const val ERROR_CAMERA_DISABLED = "camera_disabled"
        const val ERROR_CAMERA_INITIALIZATION_FAILED = "camera_initialization_failed"
        const val ERROR_MODEL_UNAVAILABLE = "model_unavailable"
        const val ERROR_INFERENCE_FAILED = "inference_failed"
        const val ERROR_SURFACE_UNAVAILABLE = "surface_unavailable"
        const val ERROR_PLUGIN_DETACHED = "plugin_detached"
        const val ERROR_VIDEO_NOT_SUPPORTED = "video_not_supported"
        const val ERROR_VIDEO_RECORDING_IN_PROGRESS = "video_recording_in_progress"
        const val ERROR_VIDEO_NOT_RECORDING = "video_not_recording"
        const val ERROR_VIDEO_RECORDING_FAILED = "video_recording_failed"
        const val ERROR_VIDEO_STORAGE_FAILED = "video_storage_failed"
    }
}
