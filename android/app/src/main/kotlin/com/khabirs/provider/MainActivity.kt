package com.khabirs.provider

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.WindowManager
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.khabirs.provider/notifications"
    private val CALL_NOTIFICATION_ID = 1001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "cancelCallNotification" -> {
                        cancelCallNotification()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // تحسين فتح التطبيق من الخلفية
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
        
        // معالجة Intent عند فتح التطبيق من الإشعار
        handleIntentData(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntentData(intent)
    }

    override fun onResume() {
        super.onResume()
        Log.d("MainActivity", "App resumed")
        
        // إلغاء أي إشعارات native عند العودة للمقدمة
        cancelCallNotification()
        
        // معالجة الـ intent مرة أخرى
        handleIntentData(intent)
    }

    private fun handleIntentData(intent: Intent?) {
    intent?.let {
        val action = it.getStringExtra("action")
        val orderId = it.getStringExtra("order_id")
        val fromBackground = it.getBooleanExtra("from_background", false)
        
        Log.d("MainActivity", "handleIntentData - Action: $action, OrderID: $orderId")
        
        // إلغاء الإشعار عند فتح التطبيق
        cancelCallNotification()
        
        when (action) {
            "call_accepted" -> {
                Log.d("MainActivity", "Processing call_accepted action")
                
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                    flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                        MethodChannel(messenger, CHANNEL).invokeMethod(
                            "onCallAccepted", 
                            mapOf(
                                "order_id" to orderId,
                                "from_background" to true
                            )
                        )
                    }
                }, 1000)
            }
            
            "call_declined" -> {
                Log.d("MainActivity", "Processing call_declined action")
                
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                    flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                        MethodChannel(messenger, CHANNEL).invokeMethod(
                            "onCallDeclined", 
                            mapOf("order_id" to orderId)
                        )
                    }
                }, 1000)
            }
            
            "view_details" -> {
                Log.d("MainActivity", "Processing view_details action")
                
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                    flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                        MethodChannel(messenger, CHANNEL).invokeMethod(
                            "navigateToOrderDetails", 
                            mapOf("order_id" to orderId)
                        )
                    }
                }, 500)
            }
            
            "open_notifications" -> {
                Log.d("MainActivity", "Processing open_notifications action")
                
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                    flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                        MethodChannel(messenger, CHANNEL).invokeMethod(
                            "navigateToNotifications", 
                            mapOf("order_id" to orderId)
                        )
                    }
                }, 500)
            }
            
            else -> {
                Log.d("MainActivity", "No special action, normal app launch")
            }
        }
        
        // مسح الـ action لتجنب التنفيذ المتكرر
        it.removeExtra("action")
    }
}

    private fun cancelCallNotification() {
        try {
            val notificationManager = NotificationManagerCompat.from(this)
            notificationManager.cancel(CALL_NOTIFICATION_ID)
            Log.d("MainActivity", "Call notification cancelled")
        } catch (e: Exception) {
            Log.e("MainActivity", "Error cancelling notification: ${e.message}")
        }
    }
}