package com.namslab.motionfit_pose

import android.app.Activity
import android.content.Context
import android.graphics.BitmapFactory
import android.os.Handler
import android.util.Log
import android.view.Surface
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageCaptureException
import androidx.camera.core.Preview
import androidx.camera.core.SurfaceRequest
import androidx.camera.core.UseCase
import androidx.camera.core.resolutionselector.AspectRatioStrategy
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import io.flutter.view.TextureRegistry
import java.io.File
import java.util.concurrent.ExecutorService

internal enum class StillCamera(
    val channelValue: String,
    val selector: CameraSelector,
) {
    FRONT("front", CameraSelector.DEFAULT_FRONT_CAMERA),
    BACK("back", CameraSelector.DEFAULT_BACK_CAMERA),
    ;

    companion object {
        fun from(value: String?): StillCamera? =
            entries.firstOrNull { it.channelValue == (value ?: FRONT.channelValue) }
    }
}

/**
 * Full-resolution photo capture for Body Progress.
 *
 * The workout pipeline binds `Preview + ImageAnalysis (+ VideoCapture)` at a
 * VGA resolution chosen for MediaPipe latency, which is far too small for a
 * progress photo. This class owns an independent `Preview + ImageCapture`
 * binding and its own Flutter texture, so the counting path is untouched. The
 * plugin refuses to run both at once.
 *
 * Rotation is reported rather than applied. Flutter's `SurfaceProducer` does
 * not always honour CameraX orientation metadata, exactly as the pose preview
 * already has to handle, so the Dart layer rotates the texture using the values
 * returned here.
 */
internal class MotionfitStillCapture(
    private val applicationContext: Context,
    private val textureRegistry: TextureRegistry,
    private val mainHandler: Handler,
    private val captureExecutor: ExecutorService,
) {
    data class StartResult(
        val textureId: Long,
        val previewWidth: Int,
        val previewHeight: Int,
        val rotationDegrees: Int,
        val handlesCropAndRotation: Boolean,
        val mirrored: Boolean,
    )

    data class Photo(
        val directory: String,
        val fileName: String,
        val width: Int,
        val height: Int,
    )

    private var cameraProvider: ProcessCameraProvider? = null
    private var lifecycleOwner: LifecycleOwner? = null
    private var activity: Activity? = null
    private var surfaceProducer: TextureRegistry.SurfaceProducer? = null
    private var preview: Preview? = null
    private var imageCapture: ImageCapture? = null
    private var selectedCamera = StillCamera.FRONT
    private var previewWidth = 0
    private var previewHeight = 0
    private var rotationDegrees = 0
    private var handlesCropAndRotation = true
    private var pendingStart: ((StartResult) -> Unit)? = null
    private var pendingStartTimeout: Runnable? = null

    var isRunning = false
        private set

    fun start(
        owner: LifecycleOwner,
        hostActivity: Activity?,
        camera: StillCamera,
        onSuccess: (StartResult) -> Unit,
        onError: (String, String) -> Unit,
    ) {
        if (isRunning) {
            onError(ERROR_ALREADY_STARTED, "Still capture is already running.")
            return
        }
        lifecycleOwner = owner
        activity = hostActivity
        selectedCamera = camera
        val producer =
            try {
                textureRegistry.createSurfaceProducer()
            } catch (error: Exception) {
                Log.w(TAG, "Flutter could not allocate a photo preview surface.", error)
                onError(
                    ERROR_SURFACE_UNAVAILABLE,
                    "Flutter could not allocate a photo preview surface.",
                )
                return
            }
        surfaceProducer = producer
        handlesCropAndRotation = producer.handlesCropAndRotation()
        val future = ProcessCameraProvider.getInstance(applicationContext)
        future.addListener({
            try {
                val provider = future.get()
                cameraProvider = provider
                bind(provider, owner, producer)
                isRunning = true
                // The preview resolution only arrives with the surface request,
                // and Dart needs it to size and rotate the texture correctly.
                // Wait briefly for it rather than reporting a zero size.
                awaitPreviewSize(producer, onSuccess)
            } catch (error: Exception) {
                Log.w(TAG, "Still capture could not bind the camera.", error)
                release()
                onError(
                    ERROR_CAMERA_UNAVAILABLE,
                    error.message ?: "The camera could not be opened for photo capture.",
                )
            }
        }, ContextCompat.getMainExecutor(applicationContext))
    }

    fun switchCamera(
        camera: StillCamera,
        onSuccess: (StartResult) -> Unit,
        onError: (String, String) -> Unit,
    ) {
        val provider = cameraProvider
        val owner = lifecycleOwner
        val producer = surfaceProducer
        if (!isRunning || provider == null || owner == null || producer == null) {
            onError(ERROR_NOT_STARTED, "Still capture is not running.")
            return
        }
        val previous = selectedCamera
        selectedCamera = camera
        try {
            bind(provider, owner, producer)
            awaitPreviewSize(producer, onSuccess)
        } catch (error: Exception) {
            selectedCamera = previous
            try {
                bind(provider, owner, producer)
            } catch (restoreError: Exception) {
                Log.w(TAG, "Still capture could not restore the previous camera.", restoreError)
            }
            onError(
                ERROR_CAMERA_UNAVAILABLE,
                "The requested camera is not available for photo capture.",
            )
        }
    }

    fun capture(
        onSuccess: (Photo) -> Unit,
        onError: (String, String) -> Unit,
    ) {
        val capture = imageCapture
        if (!isRunning || capture == null) {
            onError(ERROR_NOT_STARTED, "Still capture is not running.")
            return
        }
        val directory =
            try {
                directory()
            } catch (error: Exception) {
                onError(ERROR_PHOTO_STORAGE, "The photo directory is unavailable.")
                return
            }
        // Match the display so the written JPEG is upright, and mirror the
        // front camera so the file matches the mirrored preview the user framed
        // themselves in.
        capture.targetRotation = displayRotation()
        val fileName = "body_${System.currentTimeMillis()}.jpg"
        val file = File(directory, fileName)
        val metadata =
            ImageCapture.Metadata().apply {
                isReversedHorizontal = selectedCamera == StillCamera.FRONT
            }
        val options =
            ImageCapture.OutputFileOptions
                .Builder(file)
                .setMetadata(metadata)
                .build()
        capture.takePicture(
            options,
            captureExecutor,
            object : ImageCapture.OnImageSavedCallback {
                override fun onImageSaved(output: ImageCapture.OutputFileResults) {
                    val bounds =
                        BitmapFactory.Options().apply { inJustDecodeBounds = true }
                    try {
                        BitmapFactory.decodeFile(file.absolutePath, bounds)
                    } catch (error: Exception) {
                        Log.w(TAG, "Captured photo dimensions could not be read.", error)
                    }
                    mainHandler.post {
                        onSuccess(
                            Photo(
                                directory = directory.absolutePath,
                                fileName = fileName,
                                width = bounds.outWidth.coerceAtLeast(0),
                                height = bounds.outHeight.coerceAtLeast(0),
                            ),
                        )
                    }
                }

                override fun onError(exception: ImageCaptureException) {
                    file.delete()
                    mainHandler.post {
                        onError(
                            ERROR_CAPTURE_FAILED,
                            exception.message ?: "The photo could not be captured.",
                        )
                    }
                }
            },
        )
    }

    fun release() {
        isRunning = false
        cancelPendingStart()
        val useCases = listOfNotNull<UseCase>(preview, imageCapture)
        if (useCases.isNotEmpty()) {
            try {
                cameraProvider?.unbind(*useCases.toTypedArray())
            } catch (error: Exception) {
                Log.w(TAG, "Still capture use cases could not be unbound cleanly.", error)
            }
        }
        preview = null
        imageCapture = null
        cameraProvider = null
        lifecycleOwner = null
        activity = null
        try {
            surfaceProducer?.release()
        } catch (error: Exception) {
            Log.w(TAG, "The photo preview surface could not be released.", error)
        }
        surfaceProducer = null
        previewWidth = 0
        previewHeight = 0
        rotationDegrees = 0
    }

    fun directory(): File {
        val directory = File(applicationContext.noBackupFilesDir, PHOTO_DIRECTORY_NAME)
        if ((!directory.exists() && !directory.mkdirs()) || !directory.isDirectory) {
            throw IllegalStateException("The private body progress directory is unavailable.")
        }
        return directory
    }

    private fun bind(
        provider: ProcessCameraProvider,
        owner: LifecycleOwner,
        producer: TextureRegistry.SurfaceProducer,
    ) {
        val selector = selectedCamera.selector
        if (!provider.hasCamera(selector)) {
            throw IllegalArgumentException("The requested camera is not available.")
        }
        listOfNotNull<UseCase>(preview, imageCapture).let { existing ->
            if (existing.isNotEmpty()) provider.unbind(*existing.toTypedArray())
        }
        previewWidth = 0
        previewHeight = 0
        val targetRotation = displayRotation()
        val resolutionSelector =
            ResolutionSelector
                .Builder()
                .setAspectRatioStrategy(AspectRatioStrategy.RATIO_4_3_FALLBACK_AUTO_STRATEGY)
                .build()
        val newPreview =
            Preview
                .Builder()
                .setTargetRotation(targetRotation)
                .setResolutionSelector(resolutionSelector)
                .build()
        newPreview.setSurfaceProvider(
            ContextCompat.getMainExecutor(applicationContext),
            createSurfaceProvider(producer),
        )
        val newCapture =
            ImageCapture
                .Builder()
                .setCaptureMode(ImageCapture.CAPTURE_MODE_MINIMIZE_LATENCY)
                .setTargetRotation(targetRotation)
                .setResolutionSelector(resolutionSelector)
                .build()
        val camera = provider.bindToLifecycle(owner, selector, newPreview, newCapture)
        // How far the preview buffer has to be turned to sit upright on the
        // display. Read from the camera rather than waited for, so the value is
        // ready as soon as the texture is.
        rotationDegrees =
            try {
                camera.cameraInfo.getSensorRotationDegrees(targetRotation)
            } catch (error: Exception) {
                Log.w(TAG, "Sensor rotation is unavailable; assuming upright.", error)
                0
            }
        preview = newPreview
        imageCapture = newCapture
    }

    private fun displayRotation(): Int =
        activity?.window?.decorView?.display?.rotation ?: Surface.ROTATION_0

    /**
     * Reports the start result once CameraX has told us the preview size.
     *
     * Falls back to reporting whatever is known after [START_SIZE_TIMEOUT_MS] so
     * a device that never delivers a surface request still opens the screen.
     */
    private fun awaitPreviewSize(
        producer: TextureRegistry.SurfaceProducer,
        onSuccess: (StartResult) -> Unit,
    ) {
        cancelPendingStart()
        if (previewWidth > 0 && previewHeight > 0) {
            onSuccess(startResult(producer))
            return
        }
        pendingStart = onSuccess
        val timeout =
            Runnable {
                val pending = pendingStart ?: return@Runnable
                pendingStart = null
                pendingStartTimeout = null
                pending(startResult(producer))
            }
        pendingStartTimeout = timeout
        mainHandler.postDelayed(timeout, START_SIZE_TIMEOUT_MS)
    }

    private fun completePendingStart(producer: TextureRegistry.SurfaceProducer) {
        val pending = pendingStart ?: return
        pendingStart = null
        pendingStartTimeout?.let(mainHandler::removeCallbacks)
        pendingStartTimeout = null
        pending(startResult(producer))
    }

    private fun cancelPendingStart() {
        pendingStartTimeout?.let(mainHandler::removeCallbacks)
        pendingStartTimeout = null
        pendingStart = null
    }

    private fun startResult(producer: TextureRegistry.SurfaceProducer) =
        StartResult(
            textureId = producer.id(),
            previewWidth = previewWidth,
            previewHeight = previewHeight,
            rotationDegrees = rotationDegrees,
            handlesCropAndRotation = handlesCropAndRotation,
            // CameraX does not mirror the preview stream, so Dart applies the
            // front-camera flip itself.
            mirrored = false,
        )

    private fun createSurfaceProvider(
        producer: TextureRegistry.SurfaceProducer,
    ): Preview.SurfaceProvider =
        Preview.SurfaceProvider { request ->
            producer.setCallback(
                object : TextureRegistry.SurfaceProducer.Callback {
                    override fun onSurfaceAvailable() = Unit

                    override fun onSurfaceCleanup() {
                        if (isRunning) request.invalidate()
                    }
                },
            )
            val resolution = request.resolution
            previewWidth = resolution.width
            previewHeight = resolution.height
            producer.setSize(resolution.width, resolution.height)
            request.setTransformationInfoListener(
                ContextCompat.getMainExecutor(applicationContext),
            ) { info ->
                if (!isRunning) return@setTransformationInfoListener
                rotationDegrees = info.rotationDegrees
            }
            val surface =
                try {
                    producer.getForcedNewSurface()
                } catch (error: Exception) {
                    request.willNotProvideSurface()
                    Log.w(TAG, "Flutter could not provide a photo preview surface.", error)
                    return@SurfaceProvider
                }
            request.provideSurface(
                surface,
                ContextCompat.getMainExecutor(applicationContext),
            ) { result ->
                surface.release()
                if (result.resultCode == SurfaceRequest.Result.RESULT_INVALID_SURFACE) {
                    Log.w(TAG, "CameraX rejected the photo preview surface.")
                }
            }
            completePendingStart(producer)
        }

    private companion object {
        const val TAG = "MotionfitStillCapture"
        const val PHOTO_DIRECTORY_NAME = "motionfit_body_progress"
        const val START_SIZE_TIMEOUT_MS = 2_000L
        const val ERROR_ALREADY_STARTED = "already_started"
        const val ERROR_NOT_STARTED = "not_started"
        const val ERROR_CAMERA_UNAVAILABLE = "camera_unavailable"
        const val ERROR_SURFACE_UNAVAILABLE = "surface_unavailable"
        const val ERROR_CAPTURE_FAILED = "capture_failed"
        const val ERROR_PHOTO_STORAGE = "photo_storage_failed"
    }
}
