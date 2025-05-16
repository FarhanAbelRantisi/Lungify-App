import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_init.initializeTimeZones();

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminder_channel_id',
      'Reminder Notifications',
      description: 'Notifications for reminders',
      importance: Importance.max,
      playSound: true,
      showBadge: true,
    );

    // Initialize channel
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
    debugPrint('Notification channel created: reminder_channel_id');

    // Request battery optimization permission
    await requestBatteryOptimizationPermission();

    // Initialize notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    debugPrint('Notification service initialized');
  }

  Future<void> requestBatteryOptimizationPermission() async {
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      final granted = await Permission.ignoreBatteryOptimizations.request();
      debugPrint('Battery optimization permission: $granted');
    } else {
      debugPrint('Battery optimization permission already granted');
    }
  }

  void _onNotificationTapped(NotificationResponse details) {
    debugPrint('Notification tapped: ${details.payload}');
  }

  Future<void> requestPermissions() async {
    final iosPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('iOS notification permission: $iosGranted');

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await androidPlugin?.requestNotificationsPermission();
    debugPrint('Android notification permission: $androidGranted');
  }

  Future<void> scheduleReminderNotifications({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? notes,
    String? category,
  }) async {
    final int reminderId = int.parse(id.hashCode.toString().replaceAll('-', '').substring(0, 9));
    debugPrint('Scheduling reminder: id=$id, reminderId=$reminderId, title=$title, time=$scheduledTime');

    try {
      debugPrint('Scheduling main notification for $scheduledTime');
      await _scheduleNotification(
        id: reminderId,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        notes: notes,
        category: category,
      );

      final reminderPreviewTime = scheduledTime.subtract(const Duration(minutes: 30));
      final now = DateTime.now();

      if (reminderPreviewTime.isAfter(now.subtract(const Duration(minutes: 1)))) {
        debugPrint('Scheduling preview notification for $reminderPreviewTime');
        await _scheduleNotification(
          id: reminderId + 1,
          title: "$title",
          body: "Reminder in 30 minutes",
          scheduledTime: reminderPreviewTime,
          notes: notes,
          category: category,
          isPreview: true,
        );
      } else if (scheduledTime.isAtSameMomentAs(now) || scheduledTime.isAfter(now)) {
        debugPrint('Scheduling immediate preview for $now');
        await _scheduleNotification(
          id: reminderId + 1,
          title: "Upcoming: $title",
          body: "Reminder starting now",
          scheduledTime: now.add(const Duration(seconds: 5)),
          notes: notes,
          category: category,
          isPreview: true,
        );
      }
    } catch (e) {
      debugPrint('Error scheduling reminder notifications: $e');
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? notes,
    String? category,
    bool isPreview = false,
  }) async {
    try {
      final String displayTitle = isPreview ? "Upcoming: $title" : title;
      final String displayBody = isPreview 
          ? "Reminder in 30 minutes${notes != null ? ' - $notes' : ''}"
          : "${body}${notes != null ? ' - $notes' : ''}";

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'reminder_channel_id',
        'Reminder Notifications',
        channelDescription: 'Notifications for reminders',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        styleInformation: BigTextStyleInformation(displayBody),
      );

      DarwinNotificationDetails iosNotificationDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );

      final payload = '$title|${scheduledTime.toIso8601String()}|$category';
      debugPrint('Zoned scheduling: id=$id, title=$displayTitle, time=$scheduledTime, payload=$payload');

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        displayTitle,
        displayBody,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint('Successfully scheduled notification: id=$id, time=$scheduledTime');
    } catch (e) {
      debugPrint('Error in _scheduleNotification: $e');
    }
  }

  Future<void> cancelNotification(String id) async {
    final int reminderId = int.parse(id.hashCode.toString().replaceAll('-', '').substring(0, 9));
    debugPrint('Cancelling notifications: reminderId=$reminderId, previewId=${reminderId + 1}');
    await _flutterLocalNotificationsPlugin.cancel(reminderId);
    await _flutterLocalNotificationsPlugin.cancel(reminderId + 1);
  }

  Future<void> cancelAllNotifications() async {
    debugPrint('Cancelling all notifications');
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}