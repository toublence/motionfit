package com.namslab.motionfit_pose

/** Immutable preview metadata shared between CameraX's main thread and pose analysis. */
internal data class PreviewGeometry(
    val mirrored: Boolean,
    val handlesCropAndRotation: Boolean,
    val canonicalToTexture: DoubleArray,
) {
    companion object {
        fun initial(
            mirrored: Boolean,
            handlesCropAndRotation: Boolean = true,
        ): PreviewGeometry =
            from(
                rotationDegrees = 0,
                mirrored = mirrored,
                handlesCropAndRotation = handlesCropAndRotation,
            )

        @Suppress("UNUSED_PARAMETER")
        fun from(
            rotationDegrees: Int,
            mirrored: Boolean,
            handlesCropAndRotation: Boolean,
        ): PreviewGeometry {
            val mirror =
                if (mirrored) {
                    doubleArrayOf(
                        -1.0, 0.0, 1.0,
                        0.0, 1.0, 0.0,
                        0.0, 0.0, 1.0,
                    )
                } else {
                    identity()
                }
            // MediaPipe landmarks are already returned in the upright orientation.
            // When SurfaceProducer cannot apply CameraX metadata, Flutter rotates the
            // Texture widget itself; only the front-camera mirror remains here.
            val transform = mirror
            return PreviewGeometry(
                mirrored = mirrored,
                handlesCropAndRotation = handlesCropAndRotation,
                canonicalToTexture = transform,
            )
        }

        private fun identity(): DoubleArray =
            doubleArrayOf(
                1.0, 0.0, 0.0,
                0.0, 1.0, 0.0,
                0.0, 0.0, 1.0,
            )

    }

    override fun equals(other: Any?): Boolean =
        other is PreviewGeometry &&
            mirrored == other.mirrored &&
            handlesCropAndRotation == other.handlesCropAndRotation &&
            canonicalToTexture.contentEquals(other.canonicalToTexture)

    override fun hashCode(): Int {
        var result = mirrored.hashCode()
        result = 31 * result + handlesCropAndRotation.hashCode()
        result = 31 * result + canonicalToTexture.contentHashCode()
        return result
    }
}
