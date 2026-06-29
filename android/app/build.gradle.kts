plugins {
    id("com.android.application") version "8.1.0" apply false'
    id 'org.jetbrains.kotlin.android'
    id 'com.google.gms.google-services'
}

android {
    namespace 'com.wintrix'
    compileSdk = 34

    defaultConfig {
        applicationId "com.wintrix"
        minSdk = 24
        targetSdk = 34
        versionCode = 6
        versionName = "1.6"
        resConfigs "en", "hi"
        
        ndk {
            abiFilters "armeabi-v7a", "arm64-v8a"
        }
    }

    signingConfigs {
        release {
            storeFile file("../my-release-key.jks")
            storePassword "Mohd@arman0786"
            keyAlias "wintrix-alias"
            keyPassword "Mohd@arman0786"
        }
    }

    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            crunchPngs false 
            signingConfig signingConfigs.release
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        debug {
            minifyEnabled false
            shrinkResources false
            signingConfig signingConfigs.release
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = '11'
    }

    buildFeatures {
        viewBinding true
    }
}

dependencies {
    // 1. Firebase BOM (Single Source of Truth)
    implementation platform('com.google.firebase:firebase-bom:33.7.0')
    
    // Firebase Libraries
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'com.google.firebase:firebase-auth-ktx'
    implementation 'com.google.firebase:firebase-firestore-ktx'
    implementation 'com.google.firebase:firebase-database-ktx'
    implementation 'com.google.firebase:firebase-storage-ktx'
    implementation 'com.google.firebase:firebase-messaging-ktx'
    implementation 'com.google.firebase:firebase-appcheck-debug'

    // 2. Networking & WebRTC
    implementation 'com.squareup.okhttp3:okhttp:4.12.0'
    implementation 'com.infobip:google-webrtc:1.0.0035529'

    // 3. UI & Images
    implementation 'com.github.bumptech.glide:glide:4.16.0'
    implementation 'de.hdodenhof:circleimageview:3.1.0'
    implementation 'androidx.browser:browser:1.8.0'

    // 4. AndroidX Core & UI
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.cardview:cardview:1.0.0'
    implementation 'androidx.viewpager2:viewpager2:1.0.0'
    implementation 'androidx.recyclerview:recyclerview:1.3.0'

    // 5. Coroutines & Play Services
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3'
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-play-services:1.7.3'
    implementation 'com.google.android.gms:play-services-auth:20.7.0'

    // 6. CameraX
    implementation "androidx.camera:camera-core:1.3.1"
    implementation "androidx.camera:camera-camera2:1.3.1"
    implementation "androidx.camera:camera-lifecycle:1.3.1"
    implementation "androidx.camera:camera-view:1.3.1"

    // 7. Other
    implementation 'com.google.android.recaptcha:recaptcha:18.6.1'
    implementation 'com.facebook.android:facebook-login:16.2.0'
}
