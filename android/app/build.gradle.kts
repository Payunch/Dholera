plugins {
    id("com.android.application")
    id("kotlin-android")
    // id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.dholera_admin_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.dholera_admin_flutter"
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
                    ?: "REPLACE_WITH_REAL_ADMOB_APP_ID"
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
