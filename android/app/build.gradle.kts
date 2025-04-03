android {
    namespace = "com.example.vetra_anaam_report"
    compileSdk = 34
    
    defaultConfig {
        applicationId = "com.example.vetra_anaam_report"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            hrinkResources = false
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("com.google.android.material:material:1.10.0")
    implementation(platform("org.jetbrains.kotlin:kotlin-bom:1.8.0"))
}