import java.util.Properties
import java.util.zip.ZipFile

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseKeystoreProperties = Properties()
val releaseKeystoreFile = rootProject.file("motionfit-release.properties")
val releaseBuildRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}
if (releaseKeystoreFile.exists()) {
    releaseKeystoreFile.inputStream().use(releaseKeystoreProperties::load)
} else if (releaseBuildRequested) {
    throw GradleException(
        "Android signing requires android/motionfit-release.properties.",
    )
}

android {
    namespace = "fit.motionfit.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "fit.motionfit.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseKeystoreFile.exists()) {
            create("release") {
                keyAlias = releaseKeystoreProperties.getProperty("keyAlias")
                keyPassword = releaseKeystoreProperties.getProperty("keyPassword")
                storeFile = file(releaseKeystoreProperties.getProperty("storeFile"))
                storePassword = releaseKeystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.findByName("release")
        }
        release {
            // MediaPipe 0.10.x is not safe under R8: optimization can inline
            // Flogger's caller lookup and crash Graph.<clinit> at runtime.
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.findByName("release")
        }
    }
}

afterEvaluate {
    val releaseBuildType = android.buildTypes.getByName("release")
    check(!releaseBuildType.isMinifyEnabled && !releaseBuildType.isShrinkResources) {
        "MediaPipe release builds must keep R8/resource shrinking disabled; " +
            "enabling them causes a production-only Graph initialization crash."
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

val mediaPipeReleaseBundle =
    layout.buildDirectory.file("outputs/bundle/release/app-release.aab")

// Model delivery is a second, independent release risk. Verify the final AAB,
// not only the Flutter asset manifest.
tasks.matching { it.name == "bundleRelease" }.configureEach {
    doLast {
        val bundleFile = mediaPipeReleaseBundle.get().asFile
        check(bundleFile.isFile) {
            "Release AAB is missing; MediaPipe model assets could not be verified."
        }
        val requiredModels =
            listOf(
                "base/assets/pose_landmarker_lite.task",
                "base/assets/pose_landmarker_full.task",
                "base/assets/pose_landmarker_heavy.task",
            )
        ZipFile(bundleFile).use { bundle ->
            val missingModels =
                requiredModels.filter { path ->
                    bundle.getEntry(path)?.takeIf { it.size > 0L } == null
                }
            check(missingModels.isEmpty()) {
                "Release AAB is missing MediaPipe models: ${missingModels.joinToString()}"
            }
        }
    }
}
