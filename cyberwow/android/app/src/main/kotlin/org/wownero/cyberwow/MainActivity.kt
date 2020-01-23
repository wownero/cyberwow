package org.wownero.cyberwow

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.ActivityLifecycleListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

import android.content.Intent
import android.os.Bundle
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "send-intent"
    private var initialIntentText:String = ""
    private var initialIntentSet = false
    private var _channel: MethodChannel? = null;

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL);
        _channel = channel;

        channel.setMethodCallHandler{
            call, result ->
                if (call.method == "getInitialIntent") {
                    result.success(initialIntentText)
                } else {
                    result.notImplemented()
                }
        }


        val intent = getIntent()
        checkIntent(intent)
        initialIntentSet = true
    }

    internal fun handleSendText(intent:Intent) {
        val text:String = intent.getStringExtra(Intent.EXTRA_TEXT)
        if (initialIntentSet == false) {
            initialIntentText = text
        }
    }

    internal fun checkIntent(intent: Intent) {
        val _action = intent.getAction()
        // Log.i("Main", "action: " + action)

        if (Intent.ACTION_SEND.equals(_action)) {
            val _type = intent.getType()
            // Log.i("Main", "type: " + type)

            if (_type == "text/plain") {
                handleSendText(intent) // Handle text being sent
            }
        }
    }
}
