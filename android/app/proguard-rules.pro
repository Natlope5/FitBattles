# Keep necessary classes and methods for Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# AndroidX Window extensions (handle foldables/multi-screen scenarios)
-keep class androidx.window.** { *; }
-keep class androidx.window.sidecar.** { *; }

# Add -dontwarn to prevent warnings about missing classes if necessary
-dontwarn androidx.window.**
-dontwarn androidx.window.sidecar.**

# Handle other potential issues:
# Keep enum methods for specific Android libraries (used by Android SDK)
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Handle potential issues with summary statistics classes (often encountered with Java collections)
-keepclassmembers class j$.util.**SummaryStatistics {
    long count;
    long sum;
    double min;
    double max;
}

# Suppress warnings for unsafe operations or deprecated APIs in your dependencies
-dontwarn j$.util.**
-dontwarn androidx.**
