import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:remainder_app/constants/global_variables.dart';
import 'package:remainder_app/main.dart';
import 'package:remainder_app/services/alarm_service.dart';
import 'package:remainder_app/services/api_service.dart';
import 'package:remainder_app/services/unique_id_generator.dart';

class ReminderBody extends StatefulWidget {
  const ReminderBody({super.key});

  @override
  State<ReminderBody> createState() => _ReminderBodyState();
}

class _ReminderBodyState extends State<ReminderBody> {
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController textFieldController = TextEditingController();
  late DateTime? selectedTime;
  bool flagForReminder = false;
  //indha focus node vachu text field focus la iruka nu paaka use pandrom
  final _textFieldFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    selectedTime = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    _textFieldFocus.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GlobalVariables>(context);
    bool textFieldIsFocused = _textFieldFocus.hasFocus;
    return Container(
      height: double.maxFinite,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/white_reminder.webp'),
          fit: BoxFit.fill,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewInsets = MediaQuery.of(context).viewInsets.bottom;
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: viewInsets),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    height: 300,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: -30,
                              offset: Offset(0, 25),
                            ),
                          ],
                        ),
                        child: Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.withOpacity(0.3),
                                Colors.orangeAccent.withOpacity(0.4),
                                Colors.orange.withOpacity(0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              CupertinoDatePicker(
                                onDateTimeChanged: (DateTime value) {
                                  setState(() {
                                    selectedTime = value;
                                  });
                                },
                                initialDateTime: selectedTime,
                                use24hFormat: false,
                                mode: CupertinoDatePickerMode.dateAndTime,
                              ),
                              IgnorePointer(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    height: 36,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Form(
                      key: formKey,
                      child: TextFormField(
                        focusNode: _textFieldFocus,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please fill some reminder task';
                          } else if (value.length > 500) {
                            return "Only 500 characters are allowed!";
                          }
                          return null;
                        },
                        controller: textFieldController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: !textFieldIsFocused
                              ? Colors.amber.withOpacity(0.3)
                              : Colors.white.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text(
                            'What do you want to remind!',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.orange,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          //setting the alarm
                          DateTime alarmFromNow = DateTime.now();
                          DateTime settingAlarm = DateTime(
                            selectedTime!.year,
                            selectedTime!.month,
                            selectedTime!.day,
                            selectedTime!.hour,
                            selectedTime!.minute,
                          );
                          int id = settingAlarm.millisecondsSinceEpoch ~/ 1000;
                          String reminder = textFieldController.text;
                          if (settingAlarm.isBefore(alarmFromNow)) {
                            settingAlarm = settingAlarm.add(
                              const Duration(days: 1),
                            );
                          }
                          int convertedTime = 0;
                          final alarmUntill = settingAlarm.difference(
                            alarmFromNow,
                          );
                          int day = alarmUntill.inDays;
                          int hour = alarmUntill.inHours.remainder(24);
                          int min = alarmUntill.inMinutes.remainder(60);
                          if (settingAlarm.hour > 12) {
                            convertedTime = settingAlarm.hour - 12;
                          }
                          String time =
                              "${settingAlarm.year}-${settingAlarm.month}-${settingAlarm.day} ${(convertedTime > 0) ? convertedTime : settingAlarm.hour}:${settingAlarm.minute}";
                          String period = (settingAlarm.hour) >= 12
                              ? 'PM'
                              : 'AM';
                          String UID = await userId() ?? '';
                          flagForReminder = await ReminderAPI.insertReminders(
                            id: id,
                            reminder: reminder,
                            time: time,
                            period: period,
                            isActive: true,
                            userId: UID,
                          );
                          provider.alarmId(alarmId: id);
                          provider.userReminderUpdater(reminder: reminder);
                          await AlarmService.alarmScheduler(
                            settingAlarm,
                            reminder,
                            id,
                          );
                          textFieldController.clear();
                          if (flagForReminder) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                width: 150,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                content: Center(
                                  child: Text(
                                    (day >= 0 || hour >= 0 || min >= 0)
                                        ? '${day}d : ${hour}h : ${min + 1}m left'
                                        : 'Set an reminder!',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                elevation: 10,
                                backgroundColor: Colors.orange.shade200,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            await Future.delayed(const Duration(seconds: 2));
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return MyApp();
                                },
                              ),
                              (route) {
                                return false;
                              },
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[500],
                        foregroundColor: Colors.white,
                        elevation: 15,
                      ),
                      child: Text(
                        'Set Reminder',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
