import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.docneighbor.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.docneighbor.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            // signingConfig = signingConfigs.getByName("debug")
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

// 添加自动配置namespace的代码
rootProject.subprojects {
    project.afterEvaluate {
        if (project.plugins.hasPlugin("com.android.library")) {
            val libraryExtension = project.extensions.getByType<com.android.build.gradle.LibraryExtension>()
            if (libraryExtension.namespace == null) {
                println("自动配置namespace为插件: ${project.name}")
                // 使用packageName或项目组ID生成命名空间
                val packageName = try {
                    val manifestFile = project.file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        val manifest = groovy.xml.XmlParser().parse(manifestFile)
                        manifest.attribute("package") ?: "io.flutter.plugins.${project.name}"
                    } else {
                        "io.flutter.plugins.${project.name}"
                    }
                } catch (e: Exception) {
                    println("无法解析AndroidManifest.xml，使用默认namespace: ${e.message}")
                    "io.flutter.plugins.${project.name}"
                }

                // 设置命名空间
                libraryExtension.namespace = packageName.toString()
                println("为 ${project.name} 设置namespace: ${packageName}")
            }
        }
    }
}
