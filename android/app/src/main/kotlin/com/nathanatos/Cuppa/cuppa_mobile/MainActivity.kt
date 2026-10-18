package com.nathanatos.Cuppa

import android.media.AudioManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Alarm volume access, since timer notifications play on the alarm stream
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "cuppa_audio")
            .setMethodCallHandler { call, result ->
                val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
                when (call.method) {
                    "getAlarmVolume" -> result.success(
                        mapOf(
                            "current" to audioManager.getStreamVolume(AudioManager.STREAM_ALARM),
                            "min" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                                audioManager.getStreamMinVolume(AudioManager.STREAM_ALARM)
                            } else {
                                0
                            },
                        )
                    )
                    "showAlarmVolume" -> {
                        audioManager.adjustStreamVolume(
                            AudioManager.STREAM_ALARM,
                            AudioManager.ADJUST_SAME,
                            AudioManager.FLAG_SHOW_UI,
                        )
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
