import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Keystore properties logic
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.dholera_admin_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.dholeraplatform.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Default manifest placeholder removed in favor of productFlavors below.
    }

    // Define product flavors for different environments so each build can inject its own AdMob App ID.
    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            manifestPlaceholders["com.google.android.gms.ads.APPLICATION_ID"] =
                (project.findProperty("ADMOB_APP_ID_DEV") as String?)
                    ?: "ca-app-pub-3940256099942544~3347511713" // test id fallback
        }
        create("staging") {
            dimension = "environment"
            manifestPlaceholders["com.google.android.gms.ads.APPLICATION_ID"] =
                (project.findProperty("ADMOB_APP_ID_STAGING") as String?)
                    ?: "ca-app-pub-3940256099942544~3347511713"
        }
        create("prod") {
            dimension = "environment"
            manifestPlaceholders["com.google.android.gms.ads.APPLICATION_ID"] =
                (project.findProperty("ADMOB_APP_ID_PROD") as String?)
                    ?: "ca-app-pub-3940256099942544~3347511713" // Use test ID to prevent crash
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String? ?: ""
            keyPassword = keystoreProperties["keyPassword"] as String? ?: ""
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String? ?: ""
        }
    }

    buildTypes {
        release {
            // Proper release signing config
            signingConfig = if (keystorePropertiesFile.exists()) signingConfigs.getByName("release") else signingConfigs.getByName("debug")
            
            // Enable ProGuard obfuscation
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
