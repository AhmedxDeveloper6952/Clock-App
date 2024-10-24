import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:audioplayers/audioplayers.dart';

class AlarmSettingScreen extends StatefulWidget {
  const AlarmSettingScreen({Key? key}) : super(key: key);

  @override
  _AlarmSettingScreenState createState() => _AlarmSettingScreenState();
}

class _AlarmSettingScreenState extends State<AlarmSettingScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _alarmEnabled = true;
  String _selectedAlarmTone = 'Default Tone';
  final audioPlayer = AudioPlayer();

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final List<Alarm> _alarms = [];

  // Add vibration patterns
  final List<String> _vibrationPatterns = ['Normal', 'Strong', 'Gentle'];
  String _selectedVibrationPattern = 'Normal';

  @override
  void initState() {
    super.initState();
    _initializeTimeZone();
    _initializeLocalNotifications();
  }

  Future<void> _initializeTimeZone() async {
    tz.initializeTimeZones();
  }

  Future<void> _initializeLocalNotifications() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Initialize Android settings
    const androidInitialize =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize iOS settings
    const iOSInitialize = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        debugPrint('Notification tapped');
        await _playAlarmSound();
      },
    );
  }

  Future<void> _playAlarmSound() async {
    try {
      await audioPlayer.play(AssetSource('sounds/alarm.mp3'));
    } catch (e) {
      debugPrint('Error playing alarm sound: $e');
    }
  }

  Future<void> _scheduleAlarmNotification(
      Duration timeUntilAlarm, int alarmId) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = now.add(timeUntilAlarm);

    // Ensure the scheduled time is in the future
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Configure notification details
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'alarm_channel_id',
      'Alarm Notifications',
      channelDescription: 'Channel for alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('alarm_sound'),
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      vibrationPattern: Int64List.fromList(_getVibrationPattern()),
      enableLights: true,
      color: const Color.fromARGB(255, 255, 0, 0),
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
      sound: 'alarm_sound.wav',
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      alarmId,
      'Alarm',
      'Time to wake up!',
      scheduledDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  List<int> _getVibrationPattern() {
    switch (_selectedVibrationPattern) {
      case 'Strong':
        return [0, 1000, 500, 1000, 500, 1000];
      case 'Gentle':
        return [0, 500, 200, 500];
      default:
        return [0, 800, 400, 800];
    }
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
              Colors.indigo[900]!,
              Colors.indigo[700]!,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Set Alarm',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.indigo[800]!,
                          Colors.purple[700]!,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimeSelector(),
                      const SizedBox(height: 32),
                      _buildAlarmToneSelector(),
                      const SizedBox(height: 32),
                      _buildVibrationSelector(),
                      const SizedBox(height: 32),
                      _buildAlarmToggle(),
                      const SizedBox(height: 40),
                      _buildSaveButton(),
                      const SizedBox(height: 24),
                      _buildAlarmsList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wake Up Time',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      timePickerTheme: TimePickerThemeData(
                        backgroundColor: Colors.indigo[900],
                        hourMinuteTextColor: Colors.white,
                        dialHandColor: Colors.purple[300],
                        dialBackgroundColor: Colors.indigo[700],
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() => _selectedTime = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[300]!, Colors.indigo[300]!],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple[300]!.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _selectedTime.format(context),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmToneSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alarm Sound',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedAlarmTone,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            dropdownColor: Colors.indigo[900],
            style: const TextStyle(color: Colors.white),
            items: ['Default Tone', 'Gentle Wake', 'Nature Sounds']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedAlarmTone = value!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVibrationSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vibration Pattern',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedVibrationPattern,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            dropdownColor: Colors.indigo[900],
            style: const TextStyle(color: Colors.white),
            items: _vibrationPatterns.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedVibrationPattern = value!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Enable Alarm',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          Switch(
            value: _alarmEnabled,
            onChanged: (value) => setState(() => _alarmEnabled = value),
            activeColor: Colors.purple[300],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_alarmEnabled) {
            final now = DateTime.now();
            final selectedDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              _selectedTime.hour,
              _selectedTime.minute,
            );

            final timeUntilAlarm = selectedDateTime.isBefore(now)
                ? selectedDateTime.add(const Duration(days: 1)).difference(now)
                : selectedDateTime.difference(now);

            final newAlarm = Alarm(
              time: _selectedTime,
              tone: _selectedAlarmTone,
              enabled: _alarmEnabled,
              vibrationPattern: _selectedVibrationPattern,
            );

            setState(() => _alarms.add(newAlarm));
            _scheduleAlarmNotification(timeUntilAlarm, _alarms.length - 1);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Alarm set for ${_selectedTime.format(context)}',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.purple[700],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.purple[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Save Alarm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // [Previous code remains the same until the _buildAlarmsList() method]

  Widget _buildAlarmsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scheduled Alarms',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _alarms.length,
          itemBuilder: (context, index) {
            final alarm = _alarms[index];
            return Dismissible(
              key: Key('alarm_$index'),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                setState(() {
                  _alarms.removeAt(index);
                });
                _flutterLocalNotificationsPlugin.cancel(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Alarm deleted'),
                    backgroundColor: Colors.red[700],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple[900]!.withOpacity(0.7),
                      Colors.indigo[900]!.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple[300],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.alarm,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    alarm.time.format(context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${alarm.tone} • ${alarm.vibrationPattern}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  trailing: Switch(
                    value: alarm.enabled,
                    onChanged: (value) {
                      setState(() {
                        _alarms[index] = Alarm(
                          time: alarm.time,
                          tone: alarm.tone,
                          enabled: value,
                          vibrationPattern: alarm.vibrationPattern,
                        );
                      });
                      if (!value) {
                        _flutterLocalNotificationsPlugin.cancel(index);
                      } else {
                        final now = DateTime.now();
                        final selectedDateTime = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          alarm.time.hour,
                          alarm.time.minute,
                        );
                        final timeUntilAlarm = selectedDateTime.isBefore(now)
                            ? selectedDateTime
                                .add(const Duration(days: 1))
                                .difference(now)
                            : selectedDateTime.difference(now);
                        _scheduleAlarmNotification(timeUntilAlarm, index);
                      }
                    },
                    activeColor: Colors.purple[300],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}

class Alarm {
  final TimeOfDay time;
  final String tone;
  final bool enabled;
  final String vibrationPattern;

  const Alarm({
    required this.time,
    required this.tone,
    required this.enabled,
    required this.vibrationPattern,
  });

  @override
  String toString() {
    return 'Alarm(time: ${time.hour}:${time.minute}, tone: $tone, enabled: $enabled, vibrationPattern: $vibrationPattern)';
  }
}
