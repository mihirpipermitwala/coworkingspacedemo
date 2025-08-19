import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
     // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.reader().use { reader ->
        localProperties.load(reader)
    }
}

val flutterRoot = localProperties.getProperty("flutter.sdk")
    ?: error("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")

val flutterVersionCode = localProperties.getProperty("flutter.versionCode")
val flutterVersionName = localProperties.getProperty("flutter.versionName")
val flutterMinSdkVersion = localProperties.getProperty("flutter.minSdkVersion")
val flutterTargetSdkVersion = localProperties.getProperty("flutter.targetSdkVersion")

android {
    namespace = "com.coworkingspace.app"
    compileSdk = (localProperties.getProperty("flutter.compileSdkVersion") as String).toInt()
    ndkVersion = localProperties.getProperty("flutter.ndkVersion")

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.coworkingspace.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = (flutterMinSdkVersion as String).toInt()
        targetSdk = (flutterTargetSdkVersion as String).toInt()
        versionCode = (flutterVersionCode as String).toInt()
        versionName = flutterVersionName
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            isShrinkResources = true
            isMinifyEnabled = true
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation(platform("com.google.firebase:firebase-bom:34.1.0"))
}

flutter {
    source = "../.."
}
