import 'package:checkpills/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

enum CalendarViewType {
  month,
  week,
  day,
}

extension CalendarViewTypeExtension on CalendarViewType {
  String get label {
    switch (this) {
      case CalendarViewType.month:
        return 'Visualização Mensal';
      case CalendarViewType.week:
        return 'Visualização Semanal';
      case CalendarViewType.day:
        return 'Visualização Diária';
    }
  }
}

class CalendarConstants {
  static const Map<CalendarViewType, String> viewTypeLabels = {
    CalendarViewType.month: 'Visualização Mensal',
    CalendarViewType.week: 'Visualização Semanal',
    CalendarViewType.day: 'Visualização Diária',
  };

  static const List<String> weekDays = [
    'Dom',
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb'
  ];

  static const List<String> months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro'
  ];

  static const Map<MedicationStatus, Color> statusColors = {
    MedicationStatus.taken: AppColors.takenDose,
    MedicationStatus.missed: AppColors.missedDose,
    MedicationStatus.pending: AppColors.refillReminder,
    MedicationStatus.upcoming: AppColors.primaryBlue,
  };
}

class MedicationStatus {
  static const String taken = 'taken';
  static const String missed = 'missed';
  static const String pending = 'pending';
  static const String upcoming = 'upcoming';
}
