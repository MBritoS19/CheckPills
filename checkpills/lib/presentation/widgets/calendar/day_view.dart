import 'package:flutter/material.dart';
import 'package:checkpills/core/utils/calendar_utils.dart';
import 'package:checkpills/domain/entities/medication_entity.dart';
import 'package:checkpills/presentation/widgets/calendar/calendar_view.dart';
import 'package:checkpills/presentation/widgets/calendar/day_cell.dart';

class DayView extends CalendarView {
  final List<MedicationEntity> medications;

  const DayView({
    super.key,
    required super.focusedDate,
    required this.medications,
    required super.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final dayMedications = CalendarUtils.getMedicationsForDate(
      medications,
      focusedDate,
    );

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: dayMedications.length,
            itemBuilder: (context, index) {
              final medication = dayMedications[index];
              return ListTile(
                title: Text(medication.name),
                subtitle: Text('Dose: ${medication.dose}'),
                trailing: Text(medication.firstDoseTime),
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
            '${focusedDate.day} ${CalendarUtils.getMonthName(focusedDate.month)} '
            '${focusedDate.year}',
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
                  onDateSelected(focusedDate.subtract(const Duration(days: 1)));
                },
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  onDateSelected(focusedDate.add(const Duration(days: 1)));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
