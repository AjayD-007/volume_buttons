// NotificationService.kt
package com.example.checklist

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

class NotificationService(private val context: Context) {
    private val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    private val channelId = "overlay_controls"
    private val notificationId = 1001

    init {
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Overlay Controls",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Controls for the floating overlay"
                setSound(null, null)
                enableVibration(false)
            }
            notificationManager.createNotificationChannel(channel)
        }
    }

    fun showNotification(isOverlayVisible: Boolean) {
        // Create intents for actions
        val showIntent = Intent(context, NotificationActionReceiver::class.java).apply {
            action = "SHOW"
        }
        val hideIntent = Intent(context, NotificationActionReceiver::class.java).apply {
            action = "HIDE"
        }

        val showPendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            showIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val hidePendingIntent = PendingIntent.getBroadcast(
            context,
            1,
            hideIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.drawable.ic_notification) // Make sure to create this icon
            .setContentTitle("Volume Controls")
            .setContentText("Control your floating volume")
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setOngoing(true)
            .setSound(null)
            .setVibrate(null)
            .addAction(
                R.drawable.ic_show, // Create this icon
                "Show",
                showPendingIntent
            )
            .addAction(
                R.drawable.ic_hide, // Create this icon
                "Hide",
                hidePendingIntent
            )
            .build()

        notificationManager.notify(notificationId, notification)
    }

    fun cancelNotification() {
        notificationManager.cancel(notificationId)
    }
}