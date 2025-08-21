import 'package:flutter/material.dart';

abstract class CalendarView extends StatelessWidget {
  final DateTime focusedDate;
  final Function(DateTime) onDateSelected;

  const CalendarView({
    super.key,
    required this.focusedDate,
    required this.onDateSelected,
  });
}
