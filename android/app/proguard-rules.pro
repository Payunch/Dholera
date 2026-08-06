# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep public class com.google.android.gms.ads.MobileAds {
    public static void initialize(android.content.Context);
}

# Dart Platform Channels
-keepclassmembers class * {
    @io.flutter.plugin.common.PluginRegistry$PluginRegistrantCallback <methods>;
}

# General Android
-dontwarn android.support.**
-keep class android.support.** { *; }
