package com.example.fitbattles // Make sure this matches your app's package name

import io.flutter.app.FlutterApplication
import com.google.firebase.FirebaseApp

class MainApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()

        // Initialize Firebase
        FirebaseApp.initializeApp(this)

        // Initialize any other services or settings here
        // For example, if you use any other SDKs, initialize them here
    }
}
