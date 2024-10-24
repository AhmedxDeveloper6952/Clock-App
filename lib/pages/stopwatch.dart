import 'dart:async';
import 'package:flutter/material.dart';

class StopWatch extends StatefulWidget {
  const StopWatch({Key? key}) : super(key: key);

  @override
  _StopWatchState createState() => _StopWatchState();
}

class _StopWatchState extends State<StopWatch> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  String _formattedTime = "00:00:00";

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _formattedTime = _formatTime(_stopwatch.elapsed);
      });
    });
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void _startStopwatch() {
    setState(() {
      _stopwatch.start();
    });
    _startTimer();
  }

  void _stopStopwatch() {
    setState(() {
      _stopwatch.stop();
    });
    _timer.cancel();
  }

  void _resetStopwatch() {
    setState(() {
      _stopwatch.reset();
      _formattedTime = "00:00:00";
    });
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              _formattedTime,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed:
                    _stopwatch.isRunning ? _stopStopwatch : _startStopwatch,
                child: Text(_stopwatch.isRunning ? 'Stop' : 'Start'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _resetStopwatch,
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
