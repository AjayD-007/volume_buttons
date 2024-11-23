// NotificationActionReceiver.kt
package com.example.checklist

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class NotificationActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            "SHOW" -> {
                // Send message to Flutter to show overlay
                sendMessageToFlutter("show_overlay")
            }
            "HIDE" -> {
                // Send message to Flutter to hide overlay
                sendMessageToFlutter("hide_overlay")
            }
        }
    }

    private fun sendMessageToFlutter(action: String) {
        // You'll need to implement a way to access the Flutter engine
        // This could be through a singleton or other method
        FlutterApplication.engineInstance?.let { engine ->
            MethodChannel(
                engine.dartExecutor.binaryMessenger,
                "overlay_channel"
            ).invokeMethod("notification_action", action)
        }
    }
}