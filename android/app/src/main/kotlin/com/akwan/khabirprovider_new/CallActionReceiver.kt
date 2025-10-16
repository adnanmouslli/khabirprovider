package com.akwan.khabirprovider_new

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationManagerCompat

class CallActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        val callerName = intent.getStringExtra("caller_name") ?: "Unknown"
        val callerPhone = intent.getStringExtra("caller_phone") ?: ""
        val orderId = intent.getStringExtra("order_id") ?: ""
        val serviceType = intent.getStringExtra("service_type") ?: ""
        
        Log.d("CallActionReceiver", "Action received: $action for caller: $callerName, orderId: $orderId")
        
        when (action) {
            "ACCEPT_CALL" -> {
                // إلغاء الإشعار فوراً
                cancelCallNotification(context)
                
                // إيقاظ الشاشة إذا كانت مغلقة
                wakeUpScreen(context)
                
                // فتح التطبيق بطرق متعددة لضمان العمل
                openAppForAcceptedCall(context, callerName, callerPhone, orderId, serviceType)
                
                Log.d("CallActionReceiver", "Call accepted - Opening app for orderId: $orderId")
            }
            
            "DECLINE_CALL" -> {
                // إلغاء الإشعار فقط بدون فتح التطبيق
                cancelCallNotification(context)
                
                Log.d("CallActionReceiver", "Call declined from: $callerName, orderId: $orderId")
                
                // إرسال broadcast للتطبيق إذا كان مفتوحاً لتسجيل الرفض
                val declineIntent = Intent("com.akwan.khabirprovider_new.CALL_DECLINED").apply {
                    putExtra("order_id", orderId)
                    putExtra("caller_name", callerName)
                }
                context.sendBroadcast(declineIntent)
            }
            
            "VIEW_DETAILS" -> {
                // إلغاء الإشعار
                cancelCallNotification(context)
                
                // إيقاظ الشاشة
                wakeUpScreen(context)
                
                // فتح التطبيق مع صفحة التفاصيل
                openAppForDetails(context, callerName, orderId, serviceType)
                
                Log.d("CallActionReceiver", "View details for: $callerName, orderId: $orderId")
            }
        }
    }
    
    private fun openAppForAcceptedCall(
        context: Context, 
        callerName: String, 
        callerPhone: String, 
        orderId: String, 
        serviceType: String
    ) {
        try {
            // الطريقة الأولى: Intent عادي
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                       Intent.FLAG_ACTIVITY_CLEAR_TOP or
                       Intent.FLAG_ACTIVITY_SINGLE_TOP or
                       Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT
                putExtra("action", "call_accepted")
                putExtra("caller_name", callerName)
                putExtra("caller_phone", callerPhone)
                putExtra("order_id", orderId)
                putExtra("service_type", serviceType)
                putExtra("from_background", true)
                putExtra("timestamp", System.currentTimeMillis())
            }
            
            context.startActivity(launchIntent)
            
            // الطريقة الثانية: إرسال broadcast للتطبيق إذا كان مفتوحاً
            val broadcastIntent = Intent("com.akwan.khabirprovider_new.CALL_ACCEPTED").apply {
                putExtra("order_id", orderId)
                putExtra("caller_name", callerName)
                putExtra("caller_phone", callerPhone)
                putExtra("service_type", serviceType)
            }
            context.sendBroadcast(broadcastIntent)
            
            Log.d("CallActionReceiver", "App launch attempted for accepted call")
            
        } catch (e: Exception) {
            Log.e("CallActionReceiver", "Error opening app for accepted call: ${e.message}")
            
            // محاولة بديلة: فتح التطبيق بـ launcher intent
            try {
                val packageManager = context.packageManager
                val launcherIntent = packageManager.getLaunchIntentForPackage(context.packageName)
                launcherIntent?.apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra("action", "call_accepted")
                    putExtra("order_id", orderId)
                }
                context.startActivity(launcherIntent)
            } catch (fallbackError: Exception) {
                Log.e("CallActionReceiver", "Fallback app launch also failed: ${fallbackError.message}")
            }
        }
    }
    
    private fun openAppForDetails(
        context: Context, 
        callerName: String, 
        orderId: String, 
        serviceType: String
    ) {
        try {
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                       Intent.FLAG_ACTIVITY_CLEAR_TOP or
                       Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra("action", "view_details")
                putExtra("caller_name", callerName)
                putExtra("order_id", orderId)
                putExtra("service_type", serviceType)
            }
            context.startActivity(launchIntent)
        } catch (e: Exception) {
            Log.e("CallActionReceiver", "Error opening app for details: ${e.message}")
        }
    }
    
    private fun wakeUpScreen(context: Context) {
        try {
            val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            if (!powerManager.isInteractive) {
                val wakeLock = powerManager.newWakeLock(
                    PowerManager.SCREEN_BRIGHT_WAKE_LOCK or 
                    PowerManager.ACQUIRE_CAUSES_WAKEUP or 
                    PowerManager.ON_AFTER_RELEASE,
                    "KhabirApp:CallAccepted"
                )
                wakeLock.acquire(3000) // 3 ثواني
                
                // تحرير الـ wake lock بعد تأخير قصير
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                    try {
                        if (wakeLock.isHeld) {
                            wakeLock.release()
                        }
                    } catch (e: Exception) {
                        Log.e("CallActionReceiver", "Error releasing wake lock: ${e.message}")
                    }
                }, 2000)
            }
        } catch (e: Exception) {
            Log.e("CallActionReceiver", "Error waking up screen: ${e.message}")
        }
    }
    
    private fun cancelCallNotification(context: Context) {
        try {
            val notificationManager = NotificationManagerCompat.from(context)
            notificationManager.cancel(1001) // CALL_NOTIFICATION_ID
            Log.d("CallActionReceiver", "Call notification cancelled")
        } catch (e: Exception) {
            Log.e("CallActionReceiver", "Error cancelling notification: ${e.message}")
        }
    }
}