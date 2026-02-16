package com.example.remainder_app;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build; 

public class AlarmScheduler {
   public static void scheduleAlarm(Context context, long timeInMillis, int id, String desp) {
    AlarmManager alarmManager = (AlarmManager) context.getSystemService(context.ALARM_SERVICE);
    Intent intent = new Intent(context, AlarmReceiver.class);
    intent.setAction("com.example.remainder_app.TRIGGER_ALARM");
    intent.putExtra("alarm_description", desp);

    PendingIntent pi = PendingIntent.getBroadcast(
        context, id, intent, 
        PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT
    );

    try {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (alarmManager.canScheduleExactAlarms()) {
                alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP, timeInMillis, pi
                );
            } else {
                alarmManager.set(AlarmManager.RTC_WAKEUP, timeInMillis, pi);
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP, timeInMillis, pi
            );
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, timeInMillis, pi);
        }
    } catch (Exception e) {
        System.out.println("Alarm schedule error: " + e.toString());
        alarmManager.set(AlarmManager.RTC_WAKEUP, timeInMillis, pi);
    }
}

public static void cancelAlarm(Context context, int id) {
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);

        Intent intent = new Intent(context, AlarmReceiver.class);
        intent.setAction("com.example.remainder_app.TRIGGER_ALARM");

        PendingIntent pi = PendingIntent.getBroadcast(
                context,
                id,
                intent,
                PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT
        );

        alarmManager.cancel(pi);
    }
}

