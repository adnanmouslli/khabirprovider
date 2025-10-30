package com.khabirs.provider

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.media.RingtoneManager
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import androidx.core.app.NotificationManagerCompat

class MyFirebaseMessagingService : FirebaseMessagingService() {
    
    private val CALL_CHANNEL_ID = "incoming_calls"
    private val GENERAL_CHANNEL_ID = "general_notifications"
    private val CALL_NOTIFICATION_ID = 1001

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        Log.d("FCM", "Message received from: ${remoteMessage.from}")
        Log.d("FCM", "Message data: ${remoteMessage.data}")

        val data = remoteMessage.data
        val notification = remoteMessage.notification

        // التحقق من حالة التطبيق
        val isAppInForeground = isAppInForeground()
        Log.d("FCM", "App is in foreground: $isAppInForeground")

        // التحقق من نوع الرسالة
        val isCallMessage = isCallMessage(data)
        
        if (isCallMessage) {
            Log.d("FCM", "Call message detected")
            
            if (isAppInForeground) {
                Log.d("FCM", "App in foreground - NOT showing native notification")
                // لا تُظهر إشعار نايتف - دع Flutter يتولى الأمر
                return
            } else {
                Log.d("FCM", "App in background - showing native notification")
                showIncomingCallNotification(data)
            }
        } else {
            // رسالة عادية
            if (isAppInForeground) {
                Log.d("FCM", "General message - app in foreground, skipping native notification")
                return
            } else {
                Log.d("FCM", "General message - app in background, showing native notification")
                showGeneralNotification(notification?.title ?: "إشعار جديد", 
                                      notification?.body ?: "لديك رسالة جديدة")
            }
        }
    }

    private fun isCallMessage(data: Map<String, String>): Boolean {
        return data.containsKey("type") && data["type"] == "call" ||
               data.containsKey("call_type") ||
               data.containsKey("caller_name") ||
               data.containsKey("order_id")
    }

    private fun isAppInForeground(): Boolean {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val runningAppProcesses = activityManager.runningAppProcesses ?: return false
        
        for (processInfo in runningAppProcesses) {
            if (processInfo.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
                && processInfo.processName == packageName) {
                return true
            }
        }
        return false
    }

private fun showIncomingCallNotification(data: Map<String, String>) {
    createNotificationChannels()
    
    val orderId = data["order_id"] ?: data["orderId"] ?: ""
    val serviceType = data["service_type"] ?: data["serviceType"] ?: "خدمة عامة"

    // Intent لقبول الطلب
    val acceptIntent = Intent(this, CallActionReceiver::class.java).apply {
        action = "ACCEPT_CALL"
        putExtra("order_id", orderId)
        putExtra("service_type", serviceType)
    }
    val acceptPendingIntent = PendingIntent.getBroadcast(
        this, 1, acceptIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    // Intent لرفض الطلب
    val declineIntent = Intent(this, CallActionReceiver::class.java).apply {
        action = "DECLINE_CALL"
        putExtra("order_id", orderId)
    }
    val declinePendingIntent = PendingIntent.getBroadcast(
        this, 2, declineIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    // Intent لفتح التطبيق
    val openAppIntent = Intent(this, MainActivity::class.java).apply {
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        putExtra("action", "open_notifications")
        putExtra("order_id", orderId)
    }
    val openAppPendingIntent = PendingIntent.getActivity(
        this, 0, openAppIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    val notificationBuilder = NotificationCompat.Builder(this, CALL_CHANNEL_ID)
        .setSmallIcon(android.R.drawable.stat_sys_phone_call) // أيقونة مكالمة
        .setContentTitle("طلب خدمة جديد")
        .setContentText("لديك طلب خدمة جديد")
        .setSubText("$serviceType • رقم الطلب: $orderId")
        .setPriority(NotificationCompat.PRIORITY_MAX) // أولوية عالية
        .setCategory(NotificationCompat.CATEGORY_CALL)
        .setColor(Color.BLUE)
        .setAutoCancel(false)
        .setOngoing(true) // مستمر حتى يتم التفاعل معه
        .setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)) // رنين قوي
        .setVibrate(longArrayOf(0, 1000, 500, 1000, 500, 1000)) // اهتزاز قوي
        .setLights(Color.BLUE, 3000, 3000)
        .setFullScreenIntent(openAppPendingIntent, true) // فتح كامل للشاشة
        .setContentIntent(openAppPendingIntent)
        .addAction(android.R.drawable.ic_menu_close_clear_cancel, "رفض", declinePendingIntent)
        .addAction(android.R.drawable.ic_menu_call, "قبول", acceptPendingIntent)
        .setStyle(
            NotificationCompat.BigTextStyle()
                .bigText("لديك طلب خدمة جديد\nنوع الخدمة: $serviceType\nرقم الطلب: $orderId\n\nهل تريد قبول هذا الطلب؟")
                .setBigContentTitle("طلب خدمة جديد")
                .setSummaryText("اضغط قبول أو رفض")
        )

    val notification = notificationBuilder.build()
    notification.flags = notification.flags or Notification.FLAG_INSISTENT // رنين مستمر

    val notificationManager = NotificationManagerCompat.from(this)
    notificationManager.notify(CALL_NOTIFICATION_ID, notification)
    
    Log.d("FCM", "High priority service request notification displayed for order: $orderId")
}


    private fun showGeneralNotification(title: String, body: String) {
    createNotificationChannels()
    
    val openAppIntent = Intent(this, MainActivity::class.java).apply {
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        putExtra("action", "open_general")
    }
    val openAppPendingIntent = PendingIntent.getActivity(
        this, 0, openAppIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    val notificationBuilder = NotificationCompat.Builder(this, GENERAL_CHANNEL_ID)
        .setSmallIcon(android.R.drawable.ic_dialog_info)
        .setContentTitle(title)
        .setContentText(body)
        .setPriority(NotificationCompat.PRIORITY_HIGH)
        .setAutoCancel(true)
        .setContentIntent(openAppPendingIntent)
      

    val notificationManager = NotificationManagerCompat.from(this)
    notificationManager.notify(System.currentTimeMillis().toInt(), notificationBuilder.build())
    
    Log.d("FCM", "General native notification displayed: $title")
}



    private fun createNotificationChannels() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        val notificationManager = getSystemService(NotificationManager::class.java)
        
        // قناة طلبات الخدمة العاجلة (الوحيدة المطلوبة)
        val callChannel = NotificationChannel(
            CALL_CHANNEL_ID,
            "طلبات الخدمة العاجلة",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "إشعارات طلبات الخدمة العاجلة"
            enableLights(true)
            lightColor = Color.BLUE
            enableVibration(true)
            vibrationPattern = longArrayOf(0, 1000, 500, 1000, 500, 1000)
            setSound(
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE),
                Notification.AUDIO_ATTRIBUTES_DEFAULT
            )
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            setBypassDnd(true) // تجاوز وضع عدم الإزعاج
        }
        
        // قناة الإشعارات العامة
        val generalChannel = NotificationChannel(
            GENERAL_CHANNEL_ID,
            "الإشعارات العامة",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "إشعارات عامة للتطبيق"
            enableLights(true)
            lightColor = Color.GREEN
            enableVibration(true)
            vibrationPattern = longArrayOf(0, 500, 250, 500)
            setSound(
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION),
                Notification.AUDIO_ATTRIBUTES_DEFAULT
            )
        }

        notificationManager.createNotificationChannel(callChannel)
        notificationManager.createNotificationChannel(generalChannel)
    }
}


    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d("FCM", "New FCM token: $token")
    }
}