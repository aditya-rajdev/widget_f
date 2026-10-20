package com.widget.widget

import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.zurl.app/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveLinks") {
                val data = call.argument<String>("data")
                if (data != null) {
                    val prefs = getSharedPreferences("widget_data", Context.MODE_PRIVATE)
                    prefs.edit().putString("links", data).apply()

                    // Broadcast widget update
                    val intent = Intent("android.appwidget.action.APPWIDGET_UPDATE")
                    sendBroadcast(intent)

                    result.success(true)
                } else {
                    result.error("INVALID_DATA", "Data is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
