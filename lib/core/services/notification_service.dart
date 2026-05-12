import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _prefKeyEnabled = 'NOTIFICATION_ENABLED';
  static const String _prefKeyHour = 'NOTIFICATION_HOUR';
  static const String _prefKeyMinute = 'NOTIFICATION_MINUTE';

  Future<void> initNotifications() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }

  Future<void> scheduleDailyBudgetNotification({
    required double budgetAmount,
    required double spentAmount,
    required int hour,
    required int minute,
  }) async {
    await _notifications.cancelAll();

    final remaining = budgetAmount - spentAmount;
    final isOverBudget = remaining < 0;

    String title;
    String body;

    if (isOverBudget) {
      title = '⚠️ Vượt mức chi tiêu!';
      body = 'Bạn đã vượt ${_formatCurrency(remaining.abs())} so với mức chi tiêu tháng này.';
    } else if (remaining < budgetAmount * 0.1) {
      title = '🔔 Sắp hết ngân sách!';
      body = 'Còn lại ${_formatCurrency(remaining)} - hãy chi tiêu cẩn thận nhé!';
    } else {
      title = '💰 Báo cáo chi tiêu hàng ngày';
      body = 'Đã chi ${_formatCurrency(spentAmount)} / ${_formatCurrency(budgetAmount)}. Còn lại: ${_formatCurrency(remaining)}';
    }

    final scheduledDate = _nextInstanceOfTime(hour, minute);

    await _notifications.zonedSchedule(
      0,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_daily',
          'Thông báo chi tiêu',
          channelDescription: 'Nhắc nhở chi tiêu hàng ngày',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> showBudgetAlert({
    required double budgetAmount,
    required double spentAmount,
  }) async {
    final remaining = budgetAmount - spentAmount;
    final isOverBudget = remaining < 0;

    String title;
    String body;

    if (isOverBudget) {
      title = '⚠️ Vượt mức chi tiêu!';
      body = 'Bạn đã vượt ${_formatCurrency(remaining.abs())} so với mức ${_formatCurrency(budgetAmount)} tháng này.';
    } else {
      title = '💰 Trạng thái ngân sách';
      body = 'Đã chi ${_formatCurrency(spentAmount)} / ${_formatCurrency(budgetAmount)}. Còn lại: ${_formatCurrency(remaining)}';
    }

    await _notifications.show(
      1,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alert',
          'Cảnh báo chi tiêu',
          channelDescription: 'Cảnh báo khi vượt mức chi tiêu',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '${formatted}đ';
  }

  // Preference helpers
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKeyEnabled) ?? false;
  }

  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyEnabled, enabled);
  }

  static Future<int> getHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefKeyHour) ?? 20;
  }

  static Future<int> getMinute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefKeyMinute) ?? 0;
  }

  static Future<void> setTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKeyHour, hour);
    await prefs.setInt(_prefKeyMinute, minute);
  }

  Future<void> updateDailyNotification(double budget, double spent) async {
    final enabled = await isEnabled();
    if (enabled) {
      final hour = await getHour();
      final minute = await getMinute();
      await scheduleDailyBudgetNotification(
        budgetAmount: budget,
        spentAmount: spent,
        hour: hour,
        minute: minute,
      );
    }
  }
}
