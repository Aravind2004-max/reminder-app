import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:remainder_app/constants/dailogs.dart';
import 'package:remainder_app/constants/stateless_icons.dart';
import 'package:remainder_app/constants/user_permissions.dart';
import 'package:remainder_app/screens/alarm_ringing_screen.dart';
import 'package:remainder_app/services/alarm_service.dart';
import 'package:remainder_app/services/api_service.dart';
import 'package:remainder_app/services/unique_id_generator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> datas = [];
  List<bool> switchController = [];
  bool isLoading = true;
  bool isError = false;
  late String? UID;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _permissionCheck();
    getOrCreateUID();
    AlarmRingingScreen(refresher: fetchingHomeData);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _permissionCheck();
      getOrCreateUID();
    }
  }

  Future<void> _permissionCheck() async {
    bool isInstalled = await OEMPermissionCheck.installationCheck();
    if (isInstalled) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return PermissionDailog();
        },
      );
    }
  }

  Future<void> fetchingHomeData() async {
    setState(() {
      isLoading = true;
    });
    try {
      if (UID == null || UID!.isEmpty) {
        await getOrCreateUID();
      }
      final results = await ReminderAPI.fetchReminders(id: UID!);
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        datas = results;
        isLoading = false;
        switchController = datas.map<bool>((e) {
          final value = e['isActive'];
          if (value is bool) return value;
          if (value is int) return value == 1;
          if (value is String) return value == '1' || false;
          return false;
        }).toList();
      });
    } catch (err) {
      isLoading = false;
      isError = true;
      switchController = [];
      setState(() {});
      print("Fetch error: ${err.toString()}");
    }
  }

  Future<void> getOrCreateUID() async {
    try {
      UID = await userId() ?? '';
      fetchingHomeData();
      if (UID == '') {
        return;
      }
    } catch (err) {
      print('object');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[400],
        title: Text('Reminder', style: TextStyle(letterSpacing: 1.5)),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 20),
            child: RefreshIcon(anyFunction: fetchingHomeData),
          ),
        ],
        leading: Container(
          padding: EdgeInsets.only(left: 20),
          child: SizedBox(
            height: 32,
            width: 32,
            child: Lottie.asset(
              'assets/animations/tittle_animation.json',
              repeat: true,
              animate: true,
              frameRate: FrameRate.max,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: SizedBox(
                height: 150,
                child: Lottie.asset(
                  'assets/animations/reminder_loading.json',
                  repeat: true,
                  animate: true,
                  frameRate: FrameRate.max,
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/white_reminder.webp'),
                  fit: BoxFit.fill,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2),
                child: (datas.length > 0)
                    ? ListView.separated(
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 0.5,
                            thickness: 0.9,
                            color: Colors.black.withOpacity(0.4),
                          );
                        },
                        itemBuilder: (context, index) {
                          String desp = datas[index]['description'].toString();
                          String time = datas[index]['alarm_time'].toString();
                          print(time);
                          String period = datas[index]['period'].toString();
                          desp = desp.replaceRange(
                            0,
                            1,
                            desp.substring(0, 1).toUpperCase(),
                          );
                          time = (time.substring(11, 13) == '00')
                              ? time.replaceRange(11, 13, '12')
                              : time;
                          String date = time.substring(0, 10);
                          int hour = int.parse(time.substring(11, 13));
                          String minute = time.substring(14, 16);
                          return Dismissible(
                            key: ValueKey(datas[index]['id']),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20),
                              color: Colors.black.withOpacity(0.8),
                              child: Icon(Icons.delete, color: Colors.red[900]),
                            ),
                            onDismissed: (direction) async {
                              int id = datas[index]['id'];
                              bool alarmSetted = switchController[index];
                              setState(() {
                                datas.removeAt(index);
                                switchController.removeAt(index);
                              });
                              if (alarmSetted) {
                                await AlarmService.cancelAlarm(id: id);
                              }
                              await ReminderAPI.deleteScheduler(id: id);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.withOpacity(0.4),
                                    Colors.orange.withOpacity(0.5),
                                    Colors.black.withOpacity(0.6),
                                  ],
                                ),
                              ),
                              child: ListTile(
                                leading: RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: [
                                      TextSpan(
                                        text: '   $date',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      const TextSpan(text: '\n'),
                                      TextSpan(
                                        text:
                                            '${(hour > 12) ? "${hour - 12}" : hour}:$minute $period',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: DateEditor(
                                            id: datas[index]['id'],
                                            desp: desp,
                                            refresher: fetchingHomeData,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                title: Container(
                                  margin: EdgeInsets.only(left: 40),
                                  child: GestureDetector(
                                    onDoubleTap: () {
                                      ReminderEditor.descriptionEditor(
                                        context: context,
                                        desp: desp,
                                        id: datas[index]['id'],
                                        refresh: fetchingHomeData,
                                      );
                                    },
                                    child: Text(
                                      desp,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                trailing: Switch(
                                  value: switchController[index],
                                  onChanged: (value) async {
                                    setState(() {
                                      switchController[index] = value;
                                      datas[index]['isActive'] = value;
                                    });
                                    bool isActive = datas[index]['isActive'];
                                    int id = datas[index]['id'];
                                    if (isActive) {
                                      await ReminderAPI.alarmUpdate(
                                        id: id,
                                        isActive: isActive,
                                      );
                                      DateTime now = DateTime.now();
                                      String reScheduleTime =
                                          datas[index]['alarm_time'].toString();
                                      DateTime alarmTime = DateTime.parse(
                                        reScheduleTime,
                                      );
                                      if (alarmTime.isBefore(now)) {
                                        alarmTime = alarmTime.add(
                                          const Duration(days: 1),
                                        );
                                      }
                                      await AlarmService.alarmScheduler(
                                        alarmTime,
                                        desp,
                                        id,
                                      );
                                    } else {
                                      bool canceled =
                                          await AlarmService.cancelAlarm(
                                            id: id,
                                          );
                                      if (canceled) {
                                        await ReminderAPI.alarmUpdate(
                                          id: id,
                                          isActive: false,
                                        );
                                      }
                                    }
                                  },
                                  activeThumbColor: Colors.black,
                                  activeTrackColor: Colors.orange,
                                  inactiveThumbColor: Colors.orange.withOpacity(
                                    0.5,
                                  ),
                                  inactiveTrackColor: Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: datas.length,
                      )
                    : Center(
                        child: Container(
                          child: Text(
                            'Good things deserve a reminder!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
    );
  }
}
