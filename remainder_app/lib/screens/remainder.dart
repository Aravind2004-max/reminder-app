import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:remainder_app/helpers/reminder_body.dart';

class Remainder extends StatefulWidget {
  const Remainder({super.key});

  @override
  State<Remainder> createState() => _RemainderState();
}

class _RemainderState extends State<Remainder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder', style: TextStyle(letterSpacing: 1.5)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orange[400],
        leading: Container(
          height: 32,
          width: 32,
          padding: EdgeInsets.only(left: 20),
          child: Lottie.asset(
            'assets/animations/tittle_animation.json',
            repeat: true,
            animate: true,
            frameRate: FrameRate.max,
          ),
        ),
      ),
      body: ReminderBody(),
    );
  }
}
