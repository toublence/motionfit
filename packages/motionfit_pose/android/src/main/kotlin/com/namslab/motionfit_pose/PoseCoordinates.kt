package com.namslab.motionfit_pose

/** Converts CameraX buffer coordinates into the upright display coordinate system. */
internal object PoseCoordinates {
    fun normalized(
        x: Float,
        y: Float,
        rotationDegrees: Int,
    ): Pair<Float, Float> =
        when (normalizeRotation(rotationDegrees)) {
            90 -> Pair(1f - y, x)
            180 -> Pair(1f - x, 1f - y)
            270 -> Pair(y, 1f - x)
            else -> Pair(x, y)
        }

    fun world(
        x: Float,
        y: Float,
        rotationDegrees: Int,
    ): Pair<Float, Float> =
        when (normalizeRotation(rotationDegrees)) {
            90 -> Pair(-y, x)
            180 -> Pair(-x, -y)
            270 -> Pair(y, -x)
            else -> Pair(x, y)
        }

    private fun normalizeRotation(rotationDegrees: Int): Int =
        ((rotationDegrees % 360) + 360) % 360
}
