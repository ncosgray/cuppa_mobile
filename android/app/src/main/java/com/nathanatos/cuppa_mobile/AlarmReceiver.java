package com.nathanatos.Cuppa;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
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

        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

        // Configure the notification channel (requirement when targeting Android O+)
        //NotificationChannel notificationChannel = new NotificationChannel(CHANNEL,
        //        "Cuppa Timer",
        //        NotificationManager.IMPORTANCE_HIGH);
        //notificationChannel.setDescription("Notifications for brewing completion");
        //notificationChannel.enableLights(true);
        //notificationChannel.setLightColor(Color.GREEN);
        //notificationChannel.enableVibration(true);
        //notificationManager.createNotificationChannel(notificationChannel);

        // Create the notification
        Notification.Builder builder = new Notification.Builder(context);
        Notification notification = builder.setContentTitle("Brewing complete")
                .setContentText("Your tea is now ready!")
                .setSmallIcon(R.drawable.ic_stat_name)
                //.setChannel(CHANNEL)
                .setPriority(Notification.PRIORITY_HIGH)
                .setContentIntent(pendingIntent).build();
        notification.flags |= Notification.FLAG_AUTO_CANCEL;
        notification.defaults |= Notification.DEFAULT_VIBRATE | Notification.DEFAULT_SOUND;
        notificationManager.notify(0, notification);
    }
}
