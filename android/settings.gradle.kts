try {
    val unsafeClass = Class.forName("sun.misc.Unsafe")
    val unsafeField = unsafeClass.getDeclaredField("theUnsafe")
    unsafeField.isAccessible = true
    val unsafe = unsafeField.get(null)

    val peClass = Class.forName("java.lang.ProcessEnvironment")
    val staticFieldOffsetMethod = unsafeClass.getMethod("staticFieldOffset", java.lang.reflect.Field::class.java)
    val getObjectMethod = unsafeClass.getMethod("getObject", Any::class.java, Long::class.javaPrimitiveType)

    fun clearMap(fieldName: String) {
        try {
            val field = peClass.getDeclaredField(fieldName)
            val offset = staticFieldOffsetMethod.invoke(unsafe, field) as Long
            val map = getObjectMethod.invoke(unsafe, peClass, offset) as? MutableMap<*, *>
            if (map != null) {
                val keysToRemove = map.keys.filter { 
                    it.toString().equals("ANDROID_PREFS_ROOT", ignoreCase = true) ||
                    it.toString().equals("ANDROID_SDK_HOME", ignoreCase = true)
                }
                keysToRemove.forEach { map.remove(it) }
            }
        } catch (t: Throwable) {
        }
    }

    clearMap("theCaseInsensitiveEnvironment")
    clearMap("theUnmodifiableEnvironment")
    clearMap("theEnvironment")
} catch (e: Throwable) {
}

pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app")
