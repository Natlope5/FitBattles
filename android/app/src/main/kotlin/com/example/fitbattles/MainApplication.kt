package com.example.fitbattles // Ensure this matches your package name

import androidx.multidex.MultiDexApplication
import com.google.firebase.FirebaseApp
import android.util.Log

class MainApplication : MultiDexApplication() { // Correctly extend MultiDexApplication

    override fun onCreate() { // Correctly override the onCreate method
        super.onCreate()

        // Initialize Firebase
        try {
            FirebaseApp.initializeApp(this)
            Log.d("MainApplication", "Firebase initialized successfully")
        } catch (e: Exception) {
            Log.e("MainApplication", "Firebase initialization failed: ${e.message}")
        }

        // Initialize any other services or settings here
        initializeOtherServices()
    }

    // Example function for initializing other services
    private fun initializeOtherServices() {
        // Initialize additional SDKs or services here
        Log.d("MainApplication", "Other services initialized")
    }
}
