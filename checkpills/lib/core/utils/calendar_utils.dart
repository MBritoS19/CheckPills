import 'package:checkpills/domain/entities/medication_entity.dart';
import 'package:flutter/material.dart';

class CalendarUtils {
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  static DateTime getFirstDayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  static DateTime getLastDayOfWeek(DateTime date) {
    return date
        .add(Duration(days: DateTime.daysPerWeek - date.weekday % 7 - 1));
  }

  static List<DateTime> getDaysInMonth(DateTime date) {
    final firstDay = getFirstDayOfMonth(date);
    final lastDay = getLastDayOfMonth(date);
    final daysInMonth = lastDay.day;

    return List.generate(daysInMonth, (index) {
      return DateTime(date.year, date.month, index + 1);
    });
  }

  static List<DateTime> getDaysInWeek(DateTime date) {
    final firstDay = getFirstDayOfWeek(date);

    return List.generate(DateTime.daysPerWeek, (index) {
      return firstDay.add(Duration(days: index));
    });
  }

  static List<MedicationEntity> getMedicationsForDate(
    List<MedicationEntity> medications,
    DateTime date,
  ) {
    return medications.where((medication) {
      final medicationTime = _parseTimeString(medication.firstDoseTime);
      final medicationDate = DateTime(
        date.year,
        date.month,
        date.day,
        medicationTime.hour,
        medicationTime.minute,
      );

      // Verificar se a medicação ocorre nesta data
      // Esta é uma implementação simplificada - precisa ser expandida
      // para considerar intervalos e durações
      return medicationDate.isAtSameMomentAs(date);
    }).toList();
  }

  static TimeOfDay _parseTimeString(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String getMonthName(int month) {
    return CalendarConstants.months[month - 1];
  }

  static String getWeekDayName(int weekday) {
    return CalendarConstants.weekDays[weekday % 7];
  }
}
