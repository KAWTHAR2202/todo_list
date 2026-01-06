import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);

    // Init timezone
    tzdata.initializeTimeZones();
    tz.setLocalLocation(
      tz.getLocation('Europe/Paris'),
    ); // Ajuste selon ton fuseau horaire

    // Demander la permission sur Android 13+
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  // Notification instantanée (pour Pomodoro)
  static Future<void> showInstantNotification(String title, String body) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pomodoro_channel',
          'Pomodoro Notifications',
          channelDescription: 'Notifications for Pomodoro timer',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
    );
  }

  static Future<void> scheduleNotification(
    String title,
    DateTime dateTime,
  ) async {
    // Vérifier que la date est dans le futur
    if (dateTime.isBefore(DateTime.now())) {
      debugPrint('Cannot schedule notification in the past');
      return;
    }

    // Générer un ID unique basé sur le timestamp
    final id = dateTime.millisecondsSinceEpoch ~/ 1000;

    final scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

    debugPrint('Scheduling notification for: $scheduledDate');

    await _notifications.zonedSchedule(
      id,
      title,
      'Todo Reminder',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_channel',
          'Todo Notifications',
          channelDescription: 'Notifications for todo reminders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
