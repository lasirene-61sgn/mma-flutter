# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Preserve annotations
-keepattributes *Annotation*

# Preserve line numbers for debugging
-keepattributes SourceFile,LineNumberTable

# Keep model classes (if needed)
-keep class com.iyaofficial.info.** { *; }
