import 'package:flutter/material.dart';
import 'package:myclock/homepage.dart';

void main() {
  runApp(const MyClockApp());
}

class MyClockApp extends StatelessWidget {
  const MyClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Clock App',
      home: const HomePage(),
    );
  }
}
