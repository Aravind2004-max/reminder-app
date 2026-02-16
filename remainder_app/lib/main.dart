import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:remainder_app/constants/global_variables.dart';
import 'package:remainder_app/helpers/bottom_navigation_bar.dart';
import 'package:remainder_app/screens/alarm_ringing_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';

void main() async {
  //these are used to get or initialize all needy things for our notification/alarm
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  //plugin initialization
  final plugin = FlutterLocalNotificationsPlugin();
  plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (BuildContext context) {
        return GlobalVariables();
      },
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NavigationScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/alarm_screen': (context) {
          return AlarmRingingScreen();
        },
      },
    );
  }
}
