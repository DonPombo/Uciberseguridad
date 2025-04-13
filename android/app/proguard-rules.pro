# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep your application classes that will be used by ObjectBox
-keep class com.example.uciberseguridad_app.** { *; }

# Keep permission_handler
-keep class com.baseflow.permissionhandler.** { *; }

# Keep youtube_explode_dart
-keep class com.github.youtube.** { *; }

# Keep supabase
-keep class io.supabase.** { *; }

# Keep isar
-keep class com.isar.** { *; }

# General rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes Exceptions

# Don't warn about missing classes
-dontwarn ** 