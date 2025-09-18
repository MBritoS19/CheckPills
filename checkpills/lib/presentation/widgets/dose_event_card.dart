// lib/presentation/widgets/dose_event_card.dart

import 'package:CheckPills/data/datasources/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoseEventCard extends StatelessWidget {
  final DoseEventWithPrescription combinedData; // Nome da classe corrigido
  final VoidCallback onEdit;
  final Function(DoseEvent) onToggleStatus;

  const DoseEventCard({
    Key? key,
    required this.combinedData,
    required this.onEdit,
    required this.onToggleStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTaken = combinedData.doseEvent.status == DoseStatus.tomada;
    final time =
        DateFormat('HH:mm').format(combinedData.doseEvent.scheduledTime);
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.02,
      ),
      child: ListTile(
        leading: Text(
          time,
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
        title: Text(combinedData.prescription.name),
        subtitle: Text(combinedData.prescription.doseDescription),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(
                isTaken ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isTaken ? Colors.green : Colors.grey,
              ),
              onPressed: () => onToggleStatus(combinedData.doseEvent),
            ),
          ],
        ),
      ),
    );
  }
}
