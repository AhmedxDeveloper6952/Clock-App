import 'package:flutter/material.dart';
import 'package:one_clock/one_clock.dart';

class ClockPage extends StatelessWidget {
  const ClockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clock"),
        centerTitle: true,
      ),
      body: Center(
        child: AnalogClock(
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              colors: [Colors.black, Colors.grey],
              radius: 0.85,
            ),
            border: Border.all(width: 4.0, color: Colors.blueAccent),
            shape: BoxShape.circle,
          ),
          width: 300.0,
          isLive: true,
          hourHandColor: Colors.red,
          minuteHandColor: Colors.blue,
          showSecondHand: true,
          numberColor: Colors.white,
          showNumbers: true,
          showAllNumbers: true,
          textScaleFactor: 1.5,
          showTicks: true,
          showDigitalClock: false, // Change to true to show digital time
          datetime: DateTime.now(),
        ),
      ),
    );
  }
}
