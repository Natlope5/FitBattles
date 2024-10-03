package com.example.fitbattles

import android.content.DialogInterface
import android.os.Bundle
import androidx.appcompat.app.AlertDialog
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    // Variable to keep track of the app exit state
    private var shouldExit = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun onBackPressed() {
        // Check if the user is on the main screen or the exit state
        if (shouldExit) {
            // If shouldExit is true, exit the app
            super.onBackPressed()
        } else {
            // Show confirmation dialog when back button is pressed
            showExitConfirmationDialog()
        }
    }

    private fun showExitConfirmationDialog() {
        // Create an AlertDialog for confirming exit
        val builder = AlertDialog.Builder(this)
        builder.setTitle("Exit")
        builder.setMessage("Are you sure you want to exit the app?")
        builder.setPositiveButton("Yes") { dialog: DialogInterface, _: Int ->
            shouldExit = true // Set shouldExit to true to allow exiting
            onBackPressed() // Call onBackPressed again to exit the app
            dialog.dismiss()
        }
        builder.setNegativeButton("No") { dialog: DialogInterface, _: Int ->
            dialog.dismiss() // Just dismiss the dialog
        }

        // Show the dialog
        builder.create().show()
    }
}
