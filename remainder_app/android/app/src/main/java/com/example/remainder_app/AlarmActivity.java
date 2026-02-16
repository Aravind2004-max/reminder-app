package com.example.remainder_app;

import android.os.Bundle;
import android.view.WindowManager;
import android.content.Intent;   
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class AlarmActivity extends FlutterActivity {
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getWindow().addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED |
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON |
                        WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON | WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD);
    }

    @Override
    public String getInitialRoute() {
        return "/alarm_screen";
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                "alarm_channel"
        ).setMethodCallHandler((call, result) -> {
            switch (call.method){
                case "stopAlarm":
                    stopAlarm();
                    result.success(null);
                    break;
                case "snoozeAlarm":
                Integer id = call.argument("id");
                String desp = call.argument("desp");
                if (id == null) id = 0;
                if (desp == null) desp = "Your reminder";
                snoozeAlarm(id, desp);
                result.success(null);
                break;
                default:
                    result.notImplemented();
            }
        });
    }

    private void stopAlarm(){
        stopService(
                new android.content.Intent(
                        this,
                        AlarmSoundService.class
                )
        );
        Intent mainIntent = new Intent(this, MainActivity.class);
    mainIntent.addFlags(
        Intent.FLAG_ACTIVITY_NEW_TASK |
        Intent.FLAG_ACTIVITY_CLEAR_TOP |
        Intent.FLAG_ACTIVITY_SINGLE_TOP
    );
    startActivity(mainIntent);
        finish();
    }


    private void snoozeAlarm(int id, String desp) {
    stopAlarm();

    long snoozeTime = System.currentTimeMillis() + 5 * 60 * 1000;
    
    AlarmScheduler.scheduleAlarm(
            getApplicationContext(),
            snoozeTime,
            id,
            desp
    );
}

}
