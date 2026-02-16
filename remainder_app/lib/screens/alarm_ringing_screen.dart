import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remainder_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmRingingScreen extends StatefulWidget {
  final int? alarmId;
  final Future<void> Function()? refresher;
  const AlarmRingingScreen({super.key, this.alarmId, this.refresher});

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen> {
  final alarmController = MethodChannel('alarm_channel');

  Future<void> stopAlarm() async {
    await alarmController.invokeMethod('stopAlarm');
  }

  Future<void> snoozeAlarm() async {
    final localStorage = await SharedPreferences.getInstance();
    await alarmController.invokeMethod('snoozeAlarm', {
      'id': localStorage.getInt('alarm_id'),
      'desp': localStorage.getString('reminder'),
    });
  }

  String userReminder = "Your tasks!";
  int alarmId = 0;

  @override
  void initState() {
    super.initState();
    loadReminder();
  }

  void loadReminder() async {
    final localReminderStorage = await SharedPreferences.getInstance();
    String prefs = localReminderStorage.getString('reminder') ?? 'your tasks!';

    setState(() {
      userReminder = prefs;
      alarmId = localReminderStorage.getInt('alarm_id') ?? 0;
    });
    print('Value from prefs $prefs');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder', style: TextStyle(letterSpacing: 1.5)),
        centerTitle: true,
        backgroundColor: Colors.orange[400],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Stack(
          children: [
            Image(
              height: double.infinity,
              image: AssetImage('assets/images/white_reminder.webp'),
              fit: BoxFit.fill,
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.5),
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentGeometry.topLeft,
                    colors: [
                      Colors.orange.withOpacity(0.6),
                      Colors.orangeAccent.withOpacity(0.7),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Reminder',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Your reminder for $userReminder',
                  style: TextStyle(letterSpacing: 1.5, color: Colors.black),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      child: ElevatedButton(
                        onPressed: snoozeAlarm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent[400],
                        ),
                        child: Text(
                          'Soonze',
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      child: ElevatedButton(
                        onPressed: () async {
                          await ReminderAPI.alarmUpdate(
                            id: alarmId,
                            isActive: false,
                          );
                          await stopAlarm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                        ),
                        child: Text(
                          'Stop',
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
