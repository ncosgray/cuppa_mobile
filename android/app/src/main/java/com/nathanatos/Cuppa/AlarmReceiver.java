package com.nathanatos.Cuppa;

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
            notificationManager.createNotificationChannel(notificationChannel);

            // Build notification with channel
            builder = new Notification.Builder(context, CHANNEL);
        }
        else
        {
            // Build notification without channel for pre-O
            builder = new Notification.Builder(context);
        }

        // Create the notification
        Notification notification = builder.setContentTitle("Brewing complete")
                .setContentText("Your tea is now ready!")
                .setSmallIcon(R.drawable.ic_stat_name)
                .setPriority(Notification.PRIORITY_HIGH)
                .setContentIntent(pendingIntent).build();
        notification.flags |= Notification.FLAG_AUTO_CANCEL;
        notification.defaults |= Notification.DEFAULT_VIBRATE | Notification.DEFAULT_SOUND;
        notificationManager.notify(0, notification);
    }
}
