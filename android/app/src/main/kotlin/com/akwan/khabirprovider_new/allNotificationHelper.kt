package com.akwan.khabirprovider_new

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

object CallNotificationHelper {
    private const val CALL_CHANNEL_ID = "incoming_calls"
    private const val GENERAL_CHANNEL_ID = "general_notifications"
    private const val CALL_NOTIFICATION_ID = 1001
    
    fun createNotificationChannels(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = context.getSystemService(NotificationManager::class.java)
            
            // قناة المكالمات
            val callChannel = NotificationChannel(
                CALL_CHANNEL_ID,
                "المكالمات الواردة",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "إشعارات المكالمات الواردة مع أزرار التحكم"
                enableLights(true)
                lightColor = Color.BLUE
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 1000, 500, 1000, 500, 1000)
                
                // صوت مخصص للمكالمات
                val soundUri = Uri.parse("android.resource://${context.packageName}/raw/call_ringtone")
                val audioAttributes = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                    .build()
                setSound(soundUri, audioAttributes)
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
                
                // صوت مخصص للإشعارات العادية
                val soundUri = Uri.parse("android.resource://${context.packageName}/raw/notification_sound")
                val audioAttributes = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build()
                setSound(soundUri, audioAttributes)
            }

            notificationManager.createNotificationChannel(callChannel)
            notificationManager.createNotificationChannel(generalChannel)
        }
    }

    fun showCallNotification(
        context: Context,
        callerName: String,
        callerPhone: String,
        callData: Map<String, Any?>
    ) {
        createNotificationChannels(context)

        // Intent لفتح التطبيق
        val openAppIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("action", "open_call")
            putExtra("caller_name", callerName)
            putExtra("caller_phone", callerPhone)
        }
        val openAppPendingIntent = PendingIntent.getActivity(
            context, 0, openAppIntent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Intent لقبول المكالمة
        val acceptIntent = Intent(context, CallActionReceiver::class.java).apply {
            action = "ACCEPT_CALL"
            putExtra("caller_name", callerName)
            putExtra("caller_phone", callerPhone)
        }
        val acceptPendingIntent = PendingIntent.getBroadcast(
            context, 1, acceptIntent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Intent لرفض المكالمة
        val declineIntent = Intent(context, CallActionReceiver::class.java).apply {
            action = "DECLINE_CALL"
            putExtra("caller_name", callerName)
        }
        val declinePendingIntent = PendingIntent.getBroadcast(
            context, 2, declineIntent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Intent لعرض التفاصيل
        val detailsIntent = Intent(context, CallActionReceiver::class.java).apply {
            action = "VIEW_DETAILS"
            putExtra("caller_name", callerName)
            putExtra("order_id", callData["order_id"]?.toString())
        }
        val detailsPendingIntent = PendingIntent.getBroadcast(
            context, 3, detailsIntent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // بناء الإشعار
        val notification = NotificationCompat.Builder(context, CALL_CHANNEL_ID)
            .setContentTitle("مكالمة واردة")
            .setContentText("مكالمة من $callerName")
            .setSubText(callerPhone)
            .setSmallIcon(R.drawable.ic_call)
            .setLargeIcon(android.graphics.BitmapFactory.decodeResource(
                context.resources, R.drawable.ic_person
            ))
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setAutoCancel(false)
            .setOngoing(true)
            .setFullScreenIntent(openAppPendingIntent, true)
            .setContentIntent(openAppPendingIntent)
            
            // الأزرار
            .addAction(
                R.drawable.ic_call_end, 
                "رفض", 
                declinePendingIntent
            )
            .addAction(
                R.drawable.ic_info, 
                "التفاصيل", 
                detailsPendingIntent
            )
            .addAction(
                R.drawable.ic_call, 
                "قبول", 
                acceptPendingIntent
            )
            
            // التصميم المتقدم
            .setStyle(NotificationCompat.BigTextStyle()
                .bigText("مكالمة واردة من $callerName\n$callerPhone\n${callData["service_type"] ?: ""}")
                .setBigContentTitle("مكالمة واردة")
                .setSummaryText("اضغط للرد")
            )
            
            // الصوت والاهتزاز
            .setSound(Uri.parse("android.resource://${context.packageName}/raw/call_ringtone"))
            .setVibrate(longArrayOf(0, 1000, 500, 1000, 500, 1000))
            .setLights(Color.BLUE, 3000, 3000)
            .setDefaults(0) // لا تستخدم الافتراضيات
            .build()

        // جعل الإشعار يستمر في الرنين
        notification.flags = notification.flags or Notification.FLAG_INSISTENT

        val notificationManager = NotificationManagerCompat.from(context)
        notificationManager.notify(CALL_NOTIFICATION_ID, notification)
    }

    fun showGeneralNotification(
        context: Context,
        title: String,
        body: String,
        data: Map<String, Any?>
    ) {
        createNotificationChannels(context)

        val openAppIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("action", "open_general")
            putExtra("notification_data", data.toString())
        }
        val openAppPendingIntent = PendingIntent.getActivity(
            context, 0, openAppIntent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, GENERAL_CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(R.drawable.ic_notification)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(openAppPendingIntent)
            .setSound(Uri.parse("android.resource://${context.packageName}/raw/notification_sound"))
            .setVibrate(longArrayOf(0, 500, 250, 500))
            .setLights(Color.GREEN, 1000, 1000)
            .build()

        val notificationManager = NotificationManagerCompat.from(context)
        notificationManager.notify(System.currentTimeMillis().toInt(), notification)
    }

    fun cancelCallNotification(context: Context) {
        val notificationManager = NotificationManagerCompat.from(context)
        notificationManager.cancel(CALL_NOTIFICATION_ID)
    }
}
