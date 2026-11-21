group = "com.example.raw_gnss"
version = "1.0"

// Versions come from the host app's settings.gradle.kts (apply false).
plugins {
    id("com.android.library")
    id("kotlin-android")
}

android {
    namespace = "com.example.raw_gnss"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
    }
}
