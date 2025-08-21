import 'package:flutter/material.dart';
import 'package:checkpills/core/utils/calendar_utils.dart';
import 'package:checkpills/domain/entities/medication_entity.dart';
import 'package:checkpills/presentation/widgets/calendar/calendar_view.dart';
import 'package:checkpills/presentation/widgets/calendar/day_cell.dart';

class WeekView extends CalendarView {
  final List<MedicationEntity> medications;

  const WeekView({
    super.key,
    required super.focusedDate,
    required this.medications,
    required super.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final daysInWeek = CalendarUtils.getDaysInWeek(focusedDate);

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: daysInWeek.length,
            itemBuilder: (context, index) {
              final date = daysInWeek[index];
              final dayMedications = CalendarUtils.getMedicationsForDate(
                medications,
                date,
              );

              return DayCell(
                date: date,
                medications: dayMedications,
                isCurrentMonth: true,
                onTap: () => onDateSelected(date),
                showDetails: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final firstDay = CalendarUtils.getFirstDayOfWeek(focusedDate);
    final lastDay = CalendarUtils.getLastDayOfWeek(focusedDate);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${firstDay.day} ${CalendarUtils.getMonthName(firstDay.month)} '
            '- ${lastDay.day} ${CalendarUtils.getMonthName(lastDay.month)} '
            '${lastDay.year}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  onDateSelected(focusedDate.subtract(const Duration(days: 7)));
                },
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  onDateSelected(focusedDate.add(const Duration(days: 7)));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
