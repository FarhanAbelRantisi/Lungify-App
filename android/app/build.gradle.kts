plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

    android {
        namespace = "com.example.healthbot_app" // Replace with your actual package name
    compileSdk = 35
    val ndkVer = checkNotNull(project.findProperty("flutter.ndkVersion") as String?) {
        "flutter.ndkVersion not set in gradle.properties"
    }
    ndkVersion = ndkVer

    compileOptions {
        // Enable desugaring
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.healthbot_app" // Replace with your actual package name
        minSdk = 21
        targetSdk = 35
        
        // If you're using Flutter's versioning
        val flutterVersionCode = project.findProperty("flutter.versionCode")?.toString()?.toInt() ?: 1
        val flutterVersionName = project.findProperty("flutter.versionName")?.toString() ?: "1.0"
        
        versionCode = flutterVersionCode
        versionName = flutterVersionName
    }

    buildTypes {
        release {
            // Signing configuration
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Add desugaring support
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
    
    // Add your other dependencies here
    implementation("androidx.annotation:annotation:1.7.0")
}