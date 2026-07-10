import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../strings.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  static const String _channelId = 'task_reminders';
  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);}
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        AppStrings.notificationChannelName,
        description: AppStrings.notificationChannelDescription,
        importance: Importance.high,
      ),
    );
    await androidPlugin?.requestNotificationsPermission();
    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
    _initialized = true;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          AppStrings.notificationChannelName,
          channelDescription: AppStrings.notificationChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

  Future<void> showTaskCompleted(String taskId, String title) async {
    await init();
    await _plugin.show(
      taskId.hashCode,
      AppStrings.taskCompletedTitle,
      AppStrings.taskCompletedBody(title),
      _details,
    );
  }

  Future<void> scheduleTaskDueReminder({
    required String taskId,
    required String title,
    required DateTime dueDate,
  }) async {
    await init();
    if (dueDate.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(
      taskId.hashCode,
      AppStrings.taskDueSoonTitle,
      AppStrings.taskDueSoonBody(title),
      tz.TZDateTime.from(dueDate, tz.local),
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(String taskId) async {
    await _plugin.cancel(taskId.hashCode);
  }

  Future<void> showRemoteMessage(RemoteMessage message) async {
    await init();
    final notification = message.notification;
    if (notification == null) return;
    await _plugin.show(
      message.hashCode,
      notification.title ?? AppStrings.appName,
      notification.body ?? '',
      _details,
    );
  }
}
