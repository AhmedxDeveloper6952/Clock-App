import 'package:flutter/material.dart';
import 'package:myclock/pages/alarmpage.dart';
import 'package:myclock/pages/clockpage.dart';
import 'package:myclock/pages/stopwatch.dart';
import 'package:myclock/pages/timer.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ClockPage(),
    AlarmSettingScreen(),
    const TimerPage(),
    const StopWatch(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitle(_selectedIndex), // Dynamic title
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal, // AppBar color
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: GNav(
          gap: 8,
          color: Colors.white70,
          activeColor: Colors.tealAccent,
          iconSize: 24,
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          tabBackgroundColor: Colors.teal.withOpacity(0.1),
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          tabs: const [
            GButton(
              icon: Icons.lock_clock,
              text: 'Clock',
            ),
            GButton(
              icon: Icons.alarm,
              text: 'Alarm',
            ),
            GButton(
              icon: Icons.timer,
              text: 'Timer',
            ),
            GButton(
              icon: Icons.watch_later,
              text: 'Stopwatch',
            ),
          ],
        ),
      ),
    );
  }

  // Method to dynamically change the AppBar title
  String _getTitle(int index) {
    switch (index) {
      case 0:
        return "Clock";
      case 1:
        return "Alarm";
      case 2:
        return "Timer";
      case 3:
        return "Stopwatch";
      default:
        return "Clock";
    }
  }
}
