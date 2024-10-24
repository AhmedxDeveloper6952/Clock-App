import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({Key? key}) : super(key: key);

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with TickerProviderStateMixin {
  int _remainingTime = 0;
  Timer? _timer;
  double _selectedMinutes = 1;
  bool _isRunning = false;
  bool _isPaused = false;
  final TextEditingController _purposeController = TextEditingController();
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  final gradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6B48FF),
      Color(0xFF1EE3CF),
    ],
  );

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _purposeController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void startTimer() {
    _remainingTime = (_selectedMinutes * 60).toInt();
    _isRunning = true;
    _isPaused = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0 && !_isPaused) {
        setState(() {
          _remainingTime--;
        });
      } else if (_remainingTime == 0) {
        timer.cancel();
        _isRunning = false;
      }
    });
  }

  void togglePauseResume() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _rotationController.stop();
      } else {
        _rotationController.repeat();
      }
    });
  }

  void resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingTime = 0;
      _isRunning = false;
      _isPaused = false;
      _purposeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[900]!,
              Colors.grey[850]!,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                children: [
                  Text(
                    'FOCUS TIMER',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = gradient.createShader(
                          const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                        ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[800],
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B48FF).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: _purposeController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'What\'s your focus?',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        prefixIcon: ShaderMask(
                          shaderCallback: (bounds) =>
                              gradient.createShader(bounds),
                          child: const Icon(Icons.lightbulb_outline),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (_isRunning)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _rotationController,
                          builder: (_, child) {
                            return Transform.rotate(
                              angle: _rotationController.value * 2 * math.pi,
                              child: Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: gradient,
                                  backgroundBlendMode: BlendMode.srcIn,
                                ),
                              ),
                            );
                          },
                        ),
                        Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[900],
                          ),
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1.0 + (_pulseController.value * 0.1),
                                  child: Text(
                                    '${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 64,
                                      fontWeight: FontWeight.bold,
                                      foreground: Paint()
                                        ..shader = gradient.createShader(
                                          const Rect.fromLTWH(
                                              0.0, 0.0, 200.0, 70.0),
                                        ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Text(
                          '${_selectedMinutes.toInt()} minutes',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: const Color(0xFF6B48FF),
                            inactiveTrackColor: Colors.grey[800],
                            thumbColor: const Color(0xFF1EE3CF),
                            overlayColor:
                                const Color(0xFF1EE3CF).withOpacity(0.2),
                            trackHeight: 8,
                          ),
                          child: Slider(
                            value: _selectedMinutes,
                            min: 1,
                            max: 120,
                            divisions: 119,
                            onChanged: (value) {
                              setState(() {
                                _selectedMinutes = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isRunning)
                        IconButton(
                          iconSize: 72,
                          icon: Icon(
                            _isPaused ? Icons.play_circle : Icons.pause_circle,
                            color: const Color(0xFF1EE3CF),
                          ),
                          onPressed: togglePauseResume,
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ElevatedButton(
                            onPressed: startTimer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'START FOCUS',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (_isRunning) ...[
                        const SizedBox(width: 20),
                        IconButton(
                          iconSize: 72,
                          icon: const Icon(
                            Icons.stop_circle,
                            color: Color(0xFFFF4861),
                          ),
                          onPressed: resetTimer,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
