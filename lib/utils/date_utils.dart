import 'package:intl/intl.dart';

abstract class AppDateUtils {
  AppDateUtils._();
  static final DateFormat _dayFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _dayTimeFormat = DateFormat('MMM d, yyyy • h:mm a');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static String formatDay(DateTime date) => _dayFormat.format(date);
  static String formatDayTime(DateTime date) => _dayTimeFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());
  static bool isOverdue(DateTime dueDate) {
    final now = DateTime.now();
    return dueDate.isBefore(DateTime(now.year, now.month, now.day));
  }
  static bool isWithinNextDays(DateTime date, int days) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(Duration(days: days));
    return !date.isBefore(start) && date.isBefore(end);
  }
  static DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);
}
