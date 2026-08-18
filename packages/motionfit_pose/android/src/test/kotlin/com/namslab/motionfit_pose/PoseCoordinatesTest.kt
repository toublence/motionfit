package com.namslab.motionfit_pose

import kotlin.test.Test
import kotlin.test.assertEquals

internal class PoseCoordinatesTest {
    @Test
    fun rotation270_mapsGalaxyLandscapeBufferToUprightPortrait() {
        val nose = PoseCoordinates.normalized(0.8f, 0.5f, 270)
        val leftShoulder = PoseCoordinates.normalized(0.68f, 0.65f, 270)
        val rightShoulder = PoseCoordinates.normalized(0.68f, 0.38f, 270)

        assertPoint(nose, 0.5f, 0.2f)
        assertPoint(leftShoulder, 0.65f, 0.32f)
        assertPoint(rightShoulder, 0.38f, 0.32f)
    }

    @Test
    fun allRightAngleRotationsUseUprightCoordinates() {
        assertEquals(Pair(0.2f, 0.3f), PoseCoordinates.normalized(0.2f, 0.3f, 0))
        assertEquals(Pair(0.7f, 0.2f), PoseCoordinates.normalized(0.2f, 0.3f, 90))
        assertEquals(Pair(0.3f, 0.8f), PoseCoordinates.normalized(0.2f, 0.3f, 270))
        assertEquals(Pair(0.8f, 0.7f), PoseCoordinates.normalized(0.2f, 0.3f, 180))
    }

    private fun assertPoint(
        actual: Pair<Float, Float>,
        expectedX: Float,
        expectedY: Float,
    ) {
        assertEquals(expectedX, actual.first, 0.0001f)
        assertEquals(expectedY, actual.second, 0.0001f)
    }
}
