import 'dart:io';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoseEventCard extends StatelessWidget {
  final DoseEventWithPrescription doseData;
  final VoidCallback onToggleStatus;
  final VoidCallback onImageTap;

  const DoseEventCard({
    super.key,
    required this.doseData,
    required this.onToggleStatus,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final doseEvent = doseData.doseEvent;
    final prescription = doseData.prescription;
    final isTaken = doseEvent.status == DoseStatus.tomada;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        // LEADING: Imagem do medicamento com animação Hero
        leading: GestureDetector(
          onTap: onImageTap,
          child: Hero(
            tag: 'med_image_${prescription.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                width: 50,
                height: 50,
                color: Colors.grey[200],
                child: prescription.imagePath != null
                    ? Image.file(
                        File(prescription.imagePath!),
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.medication_liquid, color: Colors.grey),
              ),
            ),
          ),
        ),
        
        // TITLE: Nome do medicamento
        title: Text(prescription.name),

        // SUBTITLE: Descrição da dose e horário
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(prescription.doseDescription),
            Text(
              'Horário: ${DateFormat('HH:mm').format(doseEvent.scheduledTime)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),

        // TRAILING: Botão para marcar a dose como tomada
        trailing: IconButton(
          icon: Icon(
            isTaken ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isTaken ? colorScheme.primary : Colors.grey,
            size: 30,
          ),
          onPressed: onToggleStatus,
        ),
      ),
    );
  }
}