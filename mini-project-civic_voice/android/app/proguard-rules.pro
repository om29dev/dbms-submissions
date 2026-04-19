# ProGuard rules for CivicVoice

# Flutter and plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.example.civic_voice_interface.** { *; }

# Handle missing androidx.window classes
-dontwarn androidx.window.**
-keep class androidx.window.** { *; }

# Handle missing androidx.window.sidecar
-dontwarn androidx.window.sidecar.**
-keep class androidx.window.sidecar.** { *; }

# General AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# Google Maps and other plugins
-keep class com.google.android.gms.maps.** { *; }
-dontwarn com.google.android.gms.maps.**

# Ignore all missing reference warnings during R8
-ignorewarnings
