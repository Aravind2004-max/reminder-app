import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalVariables extends ChangeNotifier {
  String reminder = "yor tasks!";

  void userReminderUpdater({required String reminder}) async {
    this.reminder = reminder;
    final reminderStorage = await SharedPreferences.getInstance();
    reminderStorage.setString('reminder', this.reminder);
    notifyListeners();
  }

  void alarmId({required int alarmId}) async {
    final reminderStorage = await SharedPreferences.getInstance();
    reminderStorage.setInt('alarm_id', alarmId);
    notifyListeners();
  }
}
