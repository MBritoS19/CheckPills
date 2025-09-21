import 'dart:io';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoseDetailsModal extends StatelessWidget {
  final DoseEventWithPrescription doseData;
  // 1. ADICIONADO: Funções de callback para as ações
  final VoidCallback onSkip;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DoseDetailsModal({
    super.key, 
    required this.doseData,
    required this.onSkip,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final prescription = doseData.prescription;
    final doseEvent = doseData.doseEvent;
    final colorScheme = Theme.of(context).colorScheme;

    Widget _buildInfoRow(IconData icon, String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            title: Text(prescription.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            leading: null,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (prescription.imagePath != null)
                    Center(
                      child: Hero(
                        tag: 'med_image_${prescription.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(prescription.imagePath!),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  
                  _buildInfoRow(Icons.medication, "Dose Agendada",
                      '${prescription.doseDescription} às ${DateFormat('HH:mm').format(doseEvent.scheduledTime)}'),
                  
                  _buildInfoRow(Icons.category_outlined, "Tipo", prescription.type),

                  if(prescription.stock != -1)
                    _buildInfoRow(Icons.inventory_2_outlined, "Estoque Restante", 
                      '${prescription.stock} unidades'),

                  if(prescription.doseInterval > 0)
                    _buildInfoRow(Icons.hourglass_empty_outlined, "Intervalo", 
                      'A cada ${Duration(minutes: prescription.doseInterval).inHours}h ${Duration(minutes: prescription.doseInterval).inMinutes.remainder(60)}min'),

                  if(!prescription.isContinuous && prescription.durationTreatment != null)
                    _buildInfoRow(Icons.calendar_today_outlined, "Duração do Tratamento", 
                      '${prescription.durationTreatment} ${prescription.unitTreatment}'),
                  
                  if(prescription.notes?.isNotEmpty ?? false)
                    _buildInfoRow(Icons.notes_outlined, "Observações", prescription.notes!),
                ],
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 2. BOTÕES CONECTADOS ÀS FUNÇÕES
                TextButton.icon(
                  icon: const Icon(Icons.redo),
                  label: const Text("Pular Dose"),
                  onPressed: onSkip,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Editar"),
                  onPressed: onEdit,
                ),
                TextButton.icon(
                  icon: Icon(Icons.delete, color: colorScheme.error),
                  label: Text("Excluir", style: TextStyle(color: colorScheme.error)),
                  onPressed: onDelete,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}