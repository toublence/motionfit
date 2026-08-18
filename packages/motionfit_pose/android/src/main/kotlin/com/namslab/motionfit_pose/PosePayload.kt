package com.namslab.motionfit_pose

import com.google.mediapipe.tasks.components.containers.Landmark
import com.google.mediapipe.tasks.components.containers.NormalizedLandmark
import java.util.Optional

internal enum class PoseTrackingProfile(val channelValue: String) {
    SQUAT("squat"),
    PUSHUP("pushup"),
    PLANK("plank"),
    ;

    companion object {
        fun from(value: String?): PoseTrackingProfile? =
            entries.firstOrNull { it.channelValue == (value ?: SQUAT.channelValue) }
    }
}

/** Converts MediaPipe containers into the fixed-width StandardMessageCodec payload. */
internal object PosePayload {
    private const val LANDMARK_COUNT = 33
    private const val VALUES_PER_LANDMARK = 5
    private const val MIN_KEY_POINT_CONFIDENCE = 0.25f
    private const val FRAME_EDGE_MARGIN = 0.02f

    // A squat remains measurable when one shoulder-hip-knee chain is visible.
    // Ankles and feet improve form analysis but must never gate the workout.
    private val squatSides =
        arrayOf(
            intArrayOf(11, 23, 25),
            intArrayOf(12, 24, 26),
        )

    // Push-ups and planks need one complete arm and body line to be visible.
    private val fullBodySides =
        arrayOf(
            intArrayOf(11, 13, 15, 23, 27),
            intArrayOf(12, 14, 16, 24, 28),
        )

    fun flattenNormalized(
        landmarks: List<NormalizedLandmark>,
        rotationDegrees: Int,
    ): FloatArray {
        return FloatArray(LANDMARK_COUNT * VALUES_PER_LANDMARK).also { output ->
            for (index in 0 until minOf(landmarks.size, LANDMARK_COUNT)) {
                val point = landmarks[index]
                val offset = index * VALUES_PER_LANDMARK
                val upright =
                    PoseCoordinates.normalized(
                        finiteOrZero(point.x()),
                        finiteOrZero(point.y()),
                        rotationDegrees,
                    )
                output[offset] = upright.first
                output[offset + 1] = upright.second
                output[offset + 2] = finiteOrZero(point.z())
                val confidence = confidenceValues(point.visibility(), point.presence())
                output[offset + 3] = confidence.first
                output[offset + 4] = confidence.second
            }
        }
    }

    fun flattenWorld(
        landmarks: List<Landmark>,
        rotationDegrees: Int,
    ): FloatArray {
        return FloatArray(LANDMARK_COUNT * VALUES_PER_LANDMARK).also { output ->
            for (index in 0 until minOf(landmarks.size, LANDMARK_COUNT)) {
                val point = landmarks[index]
                val offset = index * VALUES_PER_LANDMARK
                val upright =
                    PoseCoordinates.world(
                        finiteOrZero(point.x()),
                        finiteOrZero(point.y()),
                        rotationDegrees,
                    )
                output[offset] = upright.first
                output[offset + 1] = upright.second
                output[offset + 2] = finiteOrZero(point.z())
                val confidence = confidenceValues(point.visibility(), point.presence())
                output[offset + 3] = confidence.first
                output[offset + 4] = confidence.second
            }
        }
    }

    fun zeroLandmarks(): FloatArray = FloatArray(LANDMARK_COUNT * VALUES_PER_LANDMARK)

    fun hasRequiredBody(
        landmarks: List<NormalizedLandmark>,
        trackingProfile: PoseTrackingProfile,
    ): Boolean {
        if (landmarks.size < LANDMARK_COUNT) return false
        val requiredSides =
            when (trackingProfile) {
                PoseTrackingProfile.SQUAT -> squatSides
                PoseTrackingProfile.PUSHUP,
                PoseTrackingProfile.PLANK,
                -> fullBodySides
            }
        return requiredSides.any { side -> side.all { isUsable(landmarks[it]) } }
    }

    private fun isUsable(point: NormalizedLandmark): Boolean {
        val x = point.x()
        val y = point.y()
        if (!x.isFinite() || !y.isFinite()) return false
        if (x !in -FRAME_EDGE_MARGIN..(1f + FRAME_EDGE_MARGIN) ||
            y !in -FRAME_EDGE_MARGIN..(1f + FRAME_EDGE_MARGIN)
        ) {
            return false
        }
        val confidence = confidenceValues(point.visibility(), point.presence())
        return minOf(confidence.first, confidence.second) >= MIN_KEY_POINT_CONFIDENCE
    }

    private fun confidenceValues(
        visibility: Optional<Float>,
        presence: Optional<Float>,
    ): Pair<Float, Float> {
        val visibilityValue = if (visibility.isPresent) visibility.get() else null
        val presenceValue = if (presence.isPresent) presence.get() else null
        return Pair(
            finiteOrZero(visibilityValue ?: presenceValue ?: 0f),
            finiteOrZero(presenceValue ?: visibilityValue ?: 0f),
        )
    }

    private fun finiteOrZero(value: Float): Float = if (value.isFinite()) value else 0f
}
