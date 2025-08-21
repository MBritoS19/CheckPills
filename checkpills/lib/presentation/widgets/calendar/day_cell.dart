import 'package:checkpills/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:checkpills/core/constants/calendar_constants.dart';
import 'package:checkpills/core/utils/calendar_utils.dart';
import 'package:checkpills/domain/entities/medication_entity.dart';

class DayCell extends StatelessWidget {
  final DateTime date;
  final List<MedicationEntity> medications;
  final bool isCurrentMonth;
  final Function() onTap;
  final bool showDetails;

  const DayCell({
    super.key,
    required this.date,
    required this.medications,
    required this.isCurrentMonth,
    required this.onTap,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(date);
    final textColor = isCurrentMonth ? Colors.black : Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isToday ? AppColors.primaryBlue.withOpacity(0.1) : null,
          border: isToday
              ? Border.all(color: AppColors.primaryBlue, width: 2)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                date.day.toString(),
                style: TextStyle(
                  color: textColor,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (medications.isNotEmpty && !showDetails)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  '${medications.length} med',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 10,
                  ),
                ),
              ),
            if (showDetails && medications.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    final medication = medications[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2.0,
                        vertical: 1.0,
                      ),
                      child: Text(
                        '• ${medication.name}',
                        style: const TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
