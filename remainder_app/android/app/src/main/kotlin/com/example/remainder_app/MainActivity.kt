package com.example.remainder_app

// idhu android kaana imports
// settings imports pandrom
import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager // For PowerManager
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "alarm_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call,
                result ->
            when (call.method) {
                "scheduleNativeAlarm" -> {
                    val time = call.argument<Long>("timestamp")!!
                    val id = call.argument<Int>("id") ?: 0
                    val desp = call.argument<String>("desp") ?: "Remainder notification"
                    AlarmScheduler.scheduleAlarm(applicationContext, time, id, desp)
                    result.success(null)
                }
                "stopAlarm" -> {
                    stopAlarm()
                    result.success(null)
                }
                "snoozeAlarm" -> {
                    val id = call.argument<Int>("id") ?: 0
                    val desp = call.argument<String>("desp") ?: "Your reminder"
                    snoozeAlarm(id, desp)
                    result.success(null)
                }
                "checkBatteryOptimization" -> {
                    val pm =
                            applicationContext.getSystemService(Context.POWER_SERVICE) as
                                    android.os.PowerManager
                    val pkg = applicationContext.packageName
                    val isIgnoring = pm.isIgnoringBatteryOptimizations(pkg)
                    result.success(isIgnoring)
                }
                "canScheduleExactAlarms" -> {
                    val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                    result.success(am.canScheduleExactAlarms())
                }
                "requestPermissions" -> {
                    requestAllPermissions()
                    result.success(true)
                }
                "cancelAlarm" -> {
                    val id = call.argument<Int>("id") ?: 0
                    AlarmScheduler.cancelAlarm(applicationContext, id)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun stopAlarm() {
        val intent = Intent(this, AlarmSoundService::class.java)
        stopService(intent)
    }

    private fun snoozeAlarm(id: Int, desp: String) {
        stopAlarm()
        val snoozeTime = System.currentTimeMillis() + (5 * 60 * 1000)
        AlarmScheduler.scheduleAlarm(applicationContext, snoozeTime, id, desp)
    }

    private fun requestAllPermissions() {
        requestBatteryOptimization()
        requestExactAlarms()
        requestLockInRecents()
        print("permissions enabled")

        when {
            isMIUI() || isOppo() || isOnePlus() -> {
                requestMIUIPermissions()
                requestOppoPermissions()
            }
            isSamsung() -> requestSamsungPermissions()
            isHuawei() -> requestHuaweiPermissions()
            else -> requestGenericPermissions()
        }
    }

    private fun requestLockInRecents() {
        when {
            isMIUI() -> requestMIUILockInRecents()
            isSamsung() -> requestSamsungLockInRecents()
            isOnePlus() -> requestOnePlusLockInRecents()
            isOppo() -> requestOppoLockInRecents()
            else -> requestGenericAppLock()
        }
    }

    private fun requestMIUILockInRecents() {
        val lockIntent =
                Intent().apply {
                    setClassName("com.miui.home", "com.miui.home.launcher.LockAppDialogActivity")
                    putExtra("package_name", packageName)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
        try {
            if (packageManager.resolveActivity(lockIntent, 0) != null) {
                startActivity(lockIntent)
            } else {
                openAppInfo()
            }
        } catch (e: Exception) {
            openAppInfo()
        }
    }

    private fun requestSamsungLockInRecents() {
        val intent =
                Intent("android.settings.APPLICATION_DETAILS_SETTINGS").apply {
                    data = Uri.parse("package:$packageName")
                }
        startActivity(intent)
    }

    private fun requestOnePlusLockInRecents() {
        val intent =
                Intent().apply {
                    setClassName(
                            "com.oneplus.security",
                            "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity"
                    )
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
        if (packageManager.resolveActivity(intent, 0) != null) {
            startActivity(intent)
        } else {
            openAppInfo()
        }
    }

    private fun requestOppoLockInRecents() {
        val intent =
                Intent().apply {
                    setClassName(
                            "com.coloros.safecenter",
                            "com.coloros.safecenter.permission.startup.AppAutoStartManagerActivity"
                    )
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
        if (packageManager.resolveActivity(intent, 0) != null) {
            startActivity(intent)
        } else {
            openAppInfo()
        }
    }

    private fun requestGenericAppLock() {
        openAppInfo()
    }

    private fun openAppInfo() {
        val intent =
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                    data = Uri.parse("package:$packageName")
                }
        startActivity(intent)
    }

    private fun isOnePlus(): Boolean =
            android.os.Build.MANUFACTURER.equals("OnePlus", ignoreCase = true)
    private fun isOppo(): Boolean =
            android.os.Build.MANUFACTURER.equals("OPPO", ignoreCase = true) ||
                    android.os.Build.MANUFACTURER.equals("Realme", ignoreCase = true)

    private fun requestBatteryOptimization() {
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        if (!pm.isIgnoringBatteryOptimizations(packageName)) {
            val intent =
                    Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                        data = Uri.parse("package:$packageName")
                    }
            startActivity(intent)
        }
    }

    private fun requestExactAlarms() {
        val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        if (!am.canScheduleExactAlarms()) {
            val intent =
                    Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                        data = Uri.parse("package:$packageName")
                    }
            startActivity(intent)
        }
    }

    private fun isMIUI(): Boolean =
            Build.MANUFACTURER.equals("Xiaomi", ignoreCase = true) ||
                    Build.MANUFACTURER.equals("Redmi", ignoreCase = true) ||
                    Build.MANUFACTURER.equals("POCO", ignoreCase = true)

    private fun isSamsung(): Boolean = Build.MANUFACTURER.equals("samsung", ignoreCase = true)
    private fun isHuawei(): Boolean = Build.MANUFACTURER.equals("HUAWEI", ignoreCase = true)

    private fun requestMIUIPermissions() {
        val autostartIntent =
                Intent().apply {
                    setClassName(
                            "com.miui.securitycenter",
                            "com.miui.permcenter.autostart.AutoStartManagementActivity"
                    )
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
        if (packageManager.resolveActivity(autostartIntent, 0) != null) {
            startActivity(autostartIntent)
        }
    }

    private fun requestSamsungPermissions() {
        val intent =
                Intent("com.samsung.android.sm.devicesecurity.AppStartupActivity").apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
        startActivity(intent)
    }

    private fun requestHuaweiPermissions() {
        val intent =
                Intent().apply {
                    setClassName(
                            "com.huawei.systemmanager",
                            "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"
                    )
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
        startActivity(intent)
    }

    private fun requestGenericPermissions() {
        openAppInfo()
    }

    private fun requestOppoPermissions() {
        // OPPO Autostart
        val autostartIntent =
                Intent().apply {
                    setClassName(
                            "com.coloros.safecenter",
                            "com.coloros.safecenter.permission.startup.AppAutoStartManagerActivity"
                    )
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
        if (packageManager.resolveActivity(autostartIntent, 0) != null) {
            startActivity(autostartIntent)
        }

        // OPPO Power Keeper (Battery optimization)
        val powerIntent =
                Intent().apply {
                    setClassName(
                            "com.coloros.oppoguardelf",
                            "com.coloros.powermanager.fuelgaue.PowerUsageModelActivity"
                    )
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
        if (packageManager.resolveActivity(powerIntent, 0) != null) {
            startActivity(powerIntent)
        }
    }
}
