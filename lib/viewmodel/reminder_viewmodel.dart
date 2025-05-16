import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/reminder_service.dart';
import '../services/notification_service.dart';

class ReminderViewModel extends ChangeNotifier {
  final ReminderService _reminderService = ReminderService();
  final NotificationService _notificationService = NotificationService();
  int selectedMonthIndex = DateTime.now().month - 1;
  int selectedIndex = 0;

  final List<Map<String, dynamic>> _reminders = [];
  List<Map<String, dynamic>> get reminders => _reminders;

  List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  List<Map<String, String>> days = [];

  bool _isInitialized = false;

  ReminderViewModel() {
    _generateDaysForMonth();
    if (!_isInitialized) {
      // Initialize notification service
      _notificationService.initialize().then((_) {
        _notificationService.requestPermissions();
        loadReminders();
      });
      _isInitialized = true;
    }
  }

  Future<void> addReminder(Map<String, dynamic> reminder) async {
    // Add to Firestore
    await _reminderService.addReminder(reminder);
    
    // Reload reminders from Firestore
    await loadReminders();
    
    // After reloading, find the newly added reminder with its ID
    final newReminder = _reminders.firstWhere(
      (element) =>
        element['title'] == reminder['title'] &&
        element['time'] == reminder['time'] &&
        element['date'] == reminder['date'],
      orElse: () => reminder,
    );
    
    // Schedule notification for the new reminder
    _scheduleNotificationForReminder(newReminder);
  }

  Future<void> updateReminder(String id, Map<String, dynamic> newData) async {
    // Cancel existing notifications for this reminder
    await _notificationService.cancelNotification(id);
    
    // Update in database
    await _reminderService.updateReminder(id, newData);
    
    // Update in local list
    final index = _reminders.indexWhere((element) => element['id'] == id);
    if (index != -1) {
      // Preserve the ID from the existing reminder
      newData['id'] = id;
      _reminders[index] = newData;
      
      // Schedule new notifications for the updated reminder
      _scheduleNotificationForReminder(newData);
      
      notifyListeners(); // Notify UI to update
    }
  }

  Future<void> deleteReminder(String id) async {
    // Cancel notifications for this reminder
    await _notificationService.cancelNotification(id);
    
    // Delete from database
    await _reminderService.deleteReminder(id);
    
    // Delete from local list
    _reminders.removeWhere((element) => element['id'] == id);
    notifyListeners();
  }

  Future<void> loadReminders() async {
    final fetched = await _reminderService.fetchReminders();
    
    // Cancel notifications for reminders that no longer exist
    for (var local in _reminders) {
      if (!fetched.any((remote) => remote['id'] == local['id'])) {
        await _notificationService.cancelNotification(local['id']);
      }
    }
    
    // Hapus reminder yang tidak ada di Firebase
    _reminders.removeWhere((local) => 
      !fetched.any((remote) => remote['id'] == local['id']));
    
    // Update existing reminders
    for (var remote in fetched) {
      final index = _reminders.indexWhere((local) => local['id'] == remote['id']);
      if (index != -1) {
        _reminders[index] = remote;
      } else {
        _reminders.add(remote);
        
        // Schedule notification for newly fetched reminders
        _scheduleNotificationForReminder(remote);
      }
    }
    
    notifyListeners();
  }
  
  void _scheduleNotificationForReminder(Map<String, dynamic> reminder) {
    try {
      final dateStr = reminder['date'];
      final timeStr = reminder['time'];
      final reminderId = reminder['id'];
      debugPrint('Scheduling notification for reminder: id=$reminderId, date=$dateStr, time=$timeStr');

      if (dateStr == null || timeStr == null) {
        debugPrint('Invalid date or time: date=$dateStr, time=$timeStr');
        return;
      }

      // Parse date
      final DateTime reminderDate = DateTime.parse(dateStr);

      // Parse time (e.g., "23:33" in 24-hour format)
      final DateFormat timeFormat = DateFormat('HH:mm');
      final DateTime parsedTime = timeFormat.parse(timeStr.trim());

      // Create scheduled time
      final scheduledTime = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );

      debugPrint('Parsed scheduled time: $scheduledTime');

      // Only schedule if in the future
      if (scheduledTime.isAfter(DateTime.now())) {
        debugPrint('Calling scheduleReminderNotifications for id=$reminderId');
        _notificationService.scheduleReminderNotifications(
          id: reminderId,
          title: reminder['title'],
          body: "It's time for your reminder!",
          scheduledTime: scheduledTime,
          notes: reminder['notes'],
          category: reminder['category'],
        );
        debugPrint('Scheduled notification for id=$reminderId at $scheduledTime');
      } else {
        debugPrint('Not scheduling: time $scheduledTime is in the past');
      }
    } catch (e) {
      debugPrint('Error in _scheduleNotificationForReminder: $e');
    }
  }

  void _generateDaysForMonth() {
    days.clear();
    final now = DateTime.now();
    int year = now.year;
    int month = selectedMonthIndex + 1;
    int daysInMonth = DateUtils.getDaysInMonth(year, month);

    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(year, month, i);
      final dayName = DateFormat('EEE').format(date);
      days.add({
        'day': dayName,
        'date': i.toString(),
      });
    }

    final currentDate = now.day;
    if (now.month == month) {
      selectedIndex = currentDate - 1;
    } else {
      selectedIndex = 0;
    }

    notifyListeners();
  }

  void selectIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void setMonth(int index) {
    selectedMonthIndex = index;
    selectedIndex = 0;
    _generateDaysForMonth();
  }

  List<Map<String, dynamic>> get filteredReminders {
    final selectedDay = days[selectedIndex]['date'];
    final selectedMonth = selectedMonthIndex + 1;
    final now = DateTime.now();
    final selectedYear = now.year;

    return reminders.where((reminder) {
      final dateStr = reminder['date'];
      if (dateStr == null || dateStr is! String) return false;

      try {
        final reminderDate = DateTime.parse(dateStr);
        return reminderDate.year == selectedYear &&
            reminderDate.month == selectedMonth &&
            reminderDate.day.toString() == selectedDay;
      } catch (e) {
        return false;
      }
    }).toList();
  }
}