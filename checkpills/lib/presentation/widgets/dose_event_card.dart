import 'dart:io';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoseEventCard extends StatelessWidget {
  final DoseEventWithPrescription doseData;
  final VoidCallback onToggleStatus;
  final VoidCallback onTap;

  const DoseEventCard({
    super.key,
    required this.doseData,
    required this.onToggleStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final doseEvent = doseData.doseEvent;
    final prescription = doseData.prescription;
    final colorScheme = Theme.of(context).colorScheme;

    // Helper para construir o ícone de status (sem o '_')
    Widget buildStatusIcon() {
      switch (doseEvent.status) {
        case DoseStatus.tomada:
          return Icon( // Adicionado 'const'
            Icons.check_circle,
            color: colorScheme.primary,
            size: 30,
          );
        case DoseStatus.pulada:
          return const Icon( // Adicionado 'const'
            Icons.skip_next_outlined,
            color: Colors.grey, // Cor neutra para 'pulada'
            size: 30,
          );
        case DoseStatus.pendente:
          return const Icon( // Adicionado 'const'
            Icons.radio_button_unchecked,
            color: Colors.grey,
            size: 30,
          );
      // Cláusula 'default' removida
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Card(
        color: Colors.transparent, 
        elevation: 0,
        child: ListTile(
          leading: Hero(
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
          title: Text(prescription.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(prescription.doseDescription),
              Text(
                'Horário: ${DateFormat('HH:mm').format(doseEvent.scheduledTime)}',
                style: const TextStyle(color: Colors.grey), // Adicionado 'const'
              ),
            ],
          ),
          trailing: IconButton(
            icon: buildStatusIcon(), // Chamando a função renomeada
            onPressed: doseEvent.status == DoseStatus.pulada ? null : onToggleStatus,
          ),
        ),
      ),
    );
  }
}