import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class MedicationUtils {
  static final Uuid _uuid = Uuid();

  static String generateId() {
    return _uuid.v4();
  }

  static bool validateTimeFormat(String time) {
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
  }

  static TimeOfDay parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
