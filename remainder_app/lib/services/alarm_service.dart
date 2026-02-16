import 'package:flutter/services.dart';

class AlarmService {
  static MethodChannel methodChannel = MethodChannel('alarm_channel');

  static Future<void> alarmScheduler(
    DateTime alarmTime,
    String desp,
    int id,
  ) async {
    try {
      print("new schedule called $alarmTime");
      await methodChannel.invokeMethod("scheduleNativeAlarm", {
        "timestamp": alarmTime.millisecondsSinceEpoch,
        "id": id,
        "desp": desp,
      });
    } catch (e) {
      print('Alarm error: ${e.toString()}');
    }
  }

  static Future<void> grantingPermission() async {
    try {
      await methodChannel.invokeMethod('requestPermissions');
    } catch (e) {
      print('Pedrmission error: $e');
    }
  }

  static Future<bool> batteryCheck() async {
    try {
      final bool result =
          await methodChannel.invokeMethod<bool>('checkBatteryOptimization') ??
          false;
      print(result);
      return result;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> checkExactAlarmPermission() async {
    try {
      final bool exactAlarm =
          await methodChannel.invokeMethod<bool>("canScheduleExactAlarms") ??
          false;
      return exactAlarm;
    } catch (e) {
      print('Exact alarm error: $e');
      return false;
    }
  }

  static Future<bool> cancelAlarm({required int id}) async {
    try {
      print('cancel called with id: $id');
      final bool result =
          await methodChannel.invokeMethod('cancelAlarm', {'id': id}) ?? false;
      print('cancelled iniside alarm service $result');
      return result;
    } catch (e) {
      return false;
    }
  }
}
