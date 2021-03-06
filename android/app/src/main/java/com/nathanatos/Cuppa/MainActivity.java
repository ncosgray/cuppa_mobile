package com.nathanatos.Cuppa;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import java.util.Calendar;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.nathanatos.Cuppa/notification";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("setupNotification")) {
                                int secs = call.argument("secs");
                                String title = call.argument("title");
                                String text = call.argument("text");
                                sendNotification(secs, title, text);
                            } else if (call.method.equals("cancelNotification")) {
                                cancelNotification();
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

    // Android platform: handle send notification via alarm
    private void sendNotification(int secs, String title, String text)
    {
        // Set up alarm
        AlarmManager alarmManager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
        Intent notificationIntent = new Intent("android.media.action.DISPLAY_NOTIFICATION");
        notificationIntent.addCategory("android.intent.category.DEFAULT");
        notificationIntent.setClass(this, AlarmReceiver.class);
        notificationIntent.putExtra("title", title);
        notificationIntent.putExtra("text", text);
        PendingIntent broadcast = PendingIntent.getBroadcast(this, 0, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT);

        // Create alarm
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.SECOND, secs);
        alarmManager.setExact(AlarmManager.RTC_WAKEUP, cal.getTimeInMillis(), broadcast);
    }

    // Android platform: handle cancel notification
    private void cancelNotification()
    {
        // Set up alarm
        AlarmManager alarmManager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
        Intent notificationIntent = new Intent("android.media.action.DISPLAY_NOTIFICATION");
        notificationIntent.addCategory("android.intent.category.DEFAULT");
        notificationIntent.setClass(this, AlarmReceiver.class);
        PendingIntent broadcast = PendingIntent.getBroadcast(this, 0, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT);

        // Delete alarm
        alarmManager.cancel(broadcast);
    }
}
