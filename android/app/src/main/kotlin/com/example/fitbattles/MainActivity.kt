package com.example.fitbattles

import android.Manifest
import android.content.DialogInterface
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.appcompat.app.AlertDialog
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import android.util.Log

class MainActivity : FlutterActivity() {

    // Variable to keep track of the app exit state
    private var shouldExit = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Check for necessary permissions on creation
        checkPermissions()
    }

    // Override the onBackPressed function to intercept back button press
    override fun onBackPressed() {
        // Check if the user is on the main screen or if they already confirmed exit
        if (shouldExit) {
            // If shouldExit is true, proceed to exit the app
            super.onBackPressed()
        } else {
            // If not, show a confirmation dialog to ask the user if they want to exit
            showExitConfirmationDialog()
        }
    }

    // Function to show a confirmation dialog for exiting the app
    private fun showExitConfirmationDialog() {
        // Create an AlertDialog to ask for confirmation
        val builder = AlertDialog.Builder(this)
        builder.setTitle("Exit")
        builder.setMessage("Are you sure you want to exit the app?")

        // Positive button: user confirms they want to exit
        builder.setPositiveButton("Yes") { dialog: DialogInterface, _: Int ->
            shouldExit = true // Set the flag to true so the next back press will exit the app
            onBackPressed() // Call onBackPressed again to proceed with the exit
            dialog.dismiss() // Dismiss the dialog
        }

        // Negative button: user cancels exit
        builder.setNegativeButton("No") { dialog: DialogInterface, _: Int ->
            dialog.dismiss() // Close the dialog without exiting the app
        }

        // Display the dialog
        builder.create().show()
    }

    // Function to check and request necessary permissions
    private fun checkPermissions() {
        // Example permission request (update as needed)
        val permissionsNeeded = arrayOf(Manifest.permission.ACCESS_FINE_LOCATION)

        // Check if permissions are granted
        val permissionsDenied = permissionsNeeded.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }

        // Request permissions if any are denied
        if (permissionsDenied.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, permissionsDenied.toTypedArray(), 100)
        }
    }

    // Handle the result of the permission request
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when (requestCode) {
            100 -> {
                // Check if the permissions were granted
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    Log.d("MainActivity", "Permissions granted")
                } else {
                    Log.d("MainActivity", "Permissions denied")
                }
            }
        }
    }
}
