package com.example.remainder_app;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;

import androidx.core.app.NotificationCompat;

public class AlarmReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        Intent activityService = new Intent(context, AlarmActivity.class);
        Intent soundService = new Intent(context, AlarmSoundService.class);
        String desp = intent.getStringExtra("alarm_description");

        if (!"com.example.remainder_app.TRIGGER_ALARM".equals(intent.getAction())) {
            return;
        }

        if(desp == null){
            desp = "Reminder for you!";
        }
        try{
        //sound service for alarm
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(soundService);
        }else{
            context.startService(soundService);
        }
        //activity service for alarm
        activityService.addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK |
                Intent.FLAG_ACTIVITY_CLEAR_TOP |
                Intent.FLAG_ACTIVITY_SINGLE_TOP |
                Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        );
        }catch (Exception e){
            System.out.println(e.getMessage());
        }
        finally{
              //  context.startActivity(activityService);
                showFullScreenNotification(context,desp);
        }
     }

     public void showFullScreenNotification(Context context,String desp){
        String channelId = "alarm_fullScreen";
         NotificationManager nm = (NotificationManager) context.getSystemService(context.NOTIFICATION_SERVICE);

         if(Build.VERSION.SDK_INT >=  Build.VERSION_CODES.O){
             NotificationChannel notificationChannel = new NotificationChannel(
                     channelId,
                     "Alarm started",
                     NotificationManager.IMPORTANCE_HIGH
             );

             notificationChannel.setDescription(desp);
             notificationChannel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);
             nm.createNotificationChannel(notificationChannel);
         }

         Intent fullScreen = new Intent(context,AlarmActivity.class);
         fullScreen.setFlags(
                 Intent.FLAG_ACTIVITY_NEW_TASK |
                         Intent.FLAG_ACTIVITY_CLEAR_TOP |
                         Intent.FLAG_ACTIVITY_SINGLE_TOP
         );

         PendingIntent pendingIntent = PendingIntent.getActivity(
                 context,
                 101,
                 fullScreen,
                 PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT
         );

         NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(context,channelId).
                 setSmallIcon(R.mipmap.ic_launcher).setContentTitle(desp).
                 setContentText("Tap to open").setPriority(Notification.PRIORITY_HIGH).
                 setCategory(Notification.CATEGORY_ALARM).setFullScreenIntent(pendingIntent,true).
                 setAutoCancel(true);

         nm.notify(201,notificationBuilder.build());
     }
}
