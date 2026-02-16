package com.example.remainder_app;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.media.MediaPlayer;
import android.os.Build;
import android.os.IBinder;
import android.content.pm.ServiceInfo;


import androidx.annotation.Nullable;

import com.example.remainder_app.R;

public class AlarmSoundService extends Service {

    private MediaPlayer mediaPlayer;

    @Override
    public void onCreate() {
        super.onCreate();
        String channelId = "reminder_alarm";

        NotificationManager notificationManager = getSystemService(NotificationManager.class);
            
        if(notificationManager == null) return;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            NotificationChannel channel = new NotificationChannel(

                    channelId,
                    "Alarm",
                    NotificationManager.IMPORTANCE_MIN
            );
            channel.setShowBadge(false);
            notificationManager.createNotificationChannel(channel);
        }
        Notification notification;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            
            notification = new Notification.Builder(this,channelId)
                    .setContentTitle("").setSmallIcon(
                            R.mipmap.ic_launcher
                    ).setOngoing(true)
            .setCategory(Notification.CATEGORY_ALARM).build();
        }else{
            notification = new Notification.Builder(this).setContentTitle("").setSmallIcon(
                            R.mipmap.ic_launcher
                    ).setOngoing(true)
            .setPriority(Notification.PRIORITY_HIGH)
            .setCategory(Notification.CATEGORY_ALARM).build();
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
        startForeground(
                1,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
        );
    } else {
        startForeground(1, notification);
    }

        int soundId = getResources().getIdentifier("bird_alarm","raw",getPackageName());

        if(soundId != 0){
        mediaPlayer = MediaPlayer.create(this,soundId);
        mediaPlayer.setLooping(true);
        mediaPlayer.start();
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if(mediaPlayer != null){
            mediaPlayer.stop();
            mediaPlayer.release();
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
