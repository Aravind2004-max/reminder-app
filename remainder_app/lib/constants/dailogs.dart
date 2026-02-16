import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remainder_app/constants/global_variables.dart';
import 'package:remainder_app/constants/user_permissions.dart';
import 'package:remainder_app/services/alarm_service.dart';
import 'package:remainder_app/services/api_service.dart';

class PermissionDailog extends StatelessWidget {
  const PermissionDailog({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('Required Permissions!'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.label_important, size: 10),
              SizedBox(width: 5),
              Text(
                'Lock in "Recent Tab"',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.settings, size: 12),
              SizedBox(width: 5),
              Text('Battery Usage  ->'),
            ],
          ),
          SizedBox(),
          Row(
            children: [
              Icon(Icons.navigate_next, size: 10),
              Text(
                'Background Activity, Set to "Allow Access"',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.navigate_next, size: 10),
              Text(
                'Toggle ON "Auto-start"',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Later'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await AlarmService.grantingPermission();
            await OEMPermissionCheck.markAsInstalled();
          },
          child: Text('Grant access'),
        ),
      ],
    );
  }
}

class DateEditor extends StatelessWidget {
  final int id;
  final String desp;
  final Future<void> Function() refresher;
  const DateEditor({
    super.key,
    required this.id,
    required this.desp,
    required this.refresher,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime? newDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          confirmText: 'Save changes',
          helpText: 'Date editor',
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.orange,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
                datePickerTheme: DatePickerThemeData(
                  backgroundColor: Colors.orange[200],
                  headerBackgroundColor: Colors.orange,
                  cancelButtonStyle: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  confirmButtonStyle: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (newDate == null) return;

        final TimeOfDay? newTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          confirmText: 'Save changes',
          helpText: 'Time editor',
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.orange,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
                timePickerTheme: TimePickerThemeData(
                  dialBackgroundColor: Colors.orange[300],
                  dialHandColor: Colors.black,
                  backgroundColor: Colors.orange[200],
                  hourMinuteColor: Colors.black.withOpacity(0.6),
                  hourMinuteTextColor: Colors.white,
                  dayPeriodColor: Colors.amber,
                  timeSelectorSeparatorColor: WidgetStateProperty.all(
                    Colors.black,
                  ),
                  cancelButtonStyle: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  confirmButtonStyle: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (newTime == null) return;
        bool canceled = await AlarmService.cancelAlarm(id: id);
        if (canceled) {
          DateTime newAlarm = DateTime(
            newDate.year,
            newDate.month,
            newDate.day,
            newTime.hour,
            newTime.minute,
          );
          if (newAlarm.isBefore(DateTime.now())) {
            newAlarm = newAlarm.add(const Duration(days: 1));
          }
          await AlarmService.alarmScheduler(newAlarm, desp, id);
          await ReminderAPI.alarmTimeUpdate(
            id: id,
            alarmTime: newAlarm.toString(),
          );
          refresher();
        }
      },
      child: Icon(Icons.edit_calendar, size: 13, color: Colors.black),
    );
  }
}

class ReminderEditor {
  static final textController = TextEditingController();
  static late final Future<void> Function() refresher;
  static void descriptionEditor({
    required BuildContext context,
    required String desp,
    required int id,
    required Function refresh,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 10,
      builder: (context) {
        return Container(
          width: 400,
          height: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: AlignmentGeometry.topLeft,
              colors: [
                Colors.orange.withOpacity(0.3),
                Colors.orange.withOpacity(0.5),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Do you want to edit reminder ?'),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: desp,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black, width: 5),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        String editedReminder = textController.text.trim();
                        if (editedReminder.isEmpty) {
                          return;
                        }
                        bool hasChanged = await ReminderAPI.reminderUpdate(
                          desp: editedReminder,
                          id: id,
                        );
                        if (hasChanged) {
                          final provider = Provider.of<GlobalVariables>(
                            context,
                            listen: false,
                          );
                          provider.userReminderUpdater(
                            reminder: editedReminder,
                          );
                          Navigator.pop(context);
                          refresh();
                        }
                      },
                      child: Text(
                        'Save changes',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
