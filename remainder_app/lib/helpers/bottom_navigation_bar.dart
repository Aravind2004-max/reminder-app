import 'package:flutter/material.dart';
import 'package:remainder_app/screens/home_screen.dart';
import 'package:remainder_app/screens/remainder.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey();

class _NavigationScreenState extends State<NavigationScreen> {
  int _currentIndex = 0;
  final List _pages = const [HomeScreen(), Remainder()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note_sharp),
            label: 'Reminder',
          ),
        ],
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.orange,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
      ),
    );
  }
}
