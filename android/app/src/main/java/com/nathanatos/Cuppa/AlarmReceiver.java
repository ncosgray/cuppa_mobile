package com.nathanatos.Cuppa;

import android.media.AudioAttributes;
import android.net.Uri;
import android.os.Build;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.NotificationChannel;
import android.app.PendingIntent;
import android.graphics.Color;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

// Android platform: handle alarm
public class AlarmReceiver extends BroadcastReceiver {
    private static final String CHANNEL = "Cuppa_timer_channel";

    @Override
    public void onReceive(Context context, Intent intent) {
        // Define the intent to return to main activity
        Intent resultIntent = new Intent(context, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, resultIntent, PendingIntent.FLAG_CANCEL_CURRENT);

        // Set up notification
        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        Notification.Builder builder = null;
        NotificationChannel notificationChannel = null;

        // Configure the notification channel (requirement when targeting Android O+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
        {
            notificationChannel = new NotificationChannel(CHANNEL,
                    "Timer notifications",
                    NotificationManager.IMPORTANCE_HIGH);
            notificationChannel.enableLights(true);
            notificationChannel.setLightColor(Color.GREEN);
            notificationChannel.enableVibration(true);
            notificationChannel.setShowBadge(true);
            notificationChannel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);

            // Set custom sound
            AudioAttributes audioAttributes = new AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION_EVENT)
                    .build();
            notificationChannel.setSound(Uri.parse("android.resource://" + context.getPackageName() + "/" + R.raw.spoon), audioAttributes);

            notificationManager.createNotificationChannel(notificationChannel);

            // Build notification with channel
            builder = new Notification.Builder(context, CHANNEL);
        }
        else
        {
            // Build notification without channel for pre-Oreo
            builder = new Notification.Builder(context);
        }

        // Create the notification
        String title = intent.getStringExtra("title");
        String text = intent.getStringExtra("text");
        Notification notification = builder.setContentTitle(title)
                .setContentText(text)
                .setSmallIcon(R.drawable.ic_stat_name)
                .setContentIntent(pendingIntent).build();
        notification.flags |= Notification.FLAG_AUTO_CANCEL;

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O)
        {
            // Set custom sound and other options directly on notification for pre-Oreo
            notification.sound = Uri.parse("android.resource://" + context.getPackageName() + "/" + R.raw.spoon);
            notification.priority = Notification.PRIORITY_HIGH;
            notification.defaults |= Notification.DEFAULT_VIBRATE;
        }

        notificationManager.notify(0, notification);
    }
}
