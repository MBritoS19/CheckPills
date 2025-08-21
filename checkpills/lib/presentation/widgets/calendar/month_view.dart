import 'package:flutter/material.dart';
import 'package:checkpills/core/utils/calendar_utils.dart';
import 'package:checkpills/domain/entities/medication_entity.dart';
import 'package:checkpills/presentation/widgets/calendar/calendar_view.dart';
import 'package:checkpills/presentation/widgets/calendar/day_cell.dart';

class MonthView extends CalendarView {
  final List<MedicationEntity> medications;

  const MonthView({
    super.key,
    required super.focusedDate,
    required this.medications,
    required super.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = CalendarUtils.getDaysInMonth(focusedDate);
    final firstDay = CalendarUtils.getFirstDayOfMonth(focusedDate);
    final daysBefore = firstDay.weekday % 7;
    final totalCells = daysInMonth.length + daysBefore;

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              if (index < daysBefore) {
                return const SizedBox.shrink();
              }

              final dayIndex = index - daysBefore;
              if (dayIndex >= daysInMonth.length) {
                return const SizedBox.shrink();
              }

              final date = daysInMonth[dayIndex];
              final dayMedications = CalendarUtils.getMedicationsForDate(
                medications,
                date,
              );

              return DayCell(
                date: date,
                medications: dayMedications,
                isCurrentMonth: true,
                onTap: () => onDateSelected(date),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${CalendarUtils.getMonthName(focusedDate.month)} ${focusedDate.year}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  onDateSelected(
                    DateTime(focusedDate.year, focusedDate.month - 1, 1),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  onDateSelected(
                    DateTime(focusedDate.year, focusedDate.month + 1, 1),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
