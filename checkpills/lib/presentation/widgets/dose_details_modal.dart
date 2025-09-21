import 'dart:io';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoseDetailsModal extends StatelessWidget {
  final DoseEventWithPrescription doseData;
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
    final textTheme = Theme.of(context).textTheme;

    // --- HELPER PARA O HEADER DE STATUS ---
    Widget buildStatusHeader() {
      IconData icon;
      String text;
      Color color;

      switch (doseEvent.status) {
        case DoseStatus.tomada:
          icon = Icons.check_circle;
          text = "Dose Tomada";
          color = colorScheme.primary;
          break;
        case DoseStatus.pulada:
          icon = Icons.skip_next_outlined;
          text = "Dose Pulada";
          color = Colors.orange;
          break;
        case DoseStatus.pendente:
          icon = Icons.radio_button_unchecked;
          text = "Dose Pendente";
          color = Colors.grey;
          break;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: color.withOpacity(0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(text, style: textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    
    // --- HELPER PARA AS LINHAS DE INFORMAÇÃO ---
    Widget buildInfoRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
            Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    
    // --- HELPER PARA OS CARDS DE SEÇÃO ---
    Widget buildInfoCard(String title, List<Widget> children) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Divider(height: 24),
              ...children,
            ],
          ),
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
          
          buildStatusHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (prescription.imagePath != null) ...[
                    Center(
                      child: Hero(
                        tag: 'med_image_${prescription.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(prescription.imagePath!),
                            width: 120, height: 120, fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  buildInfoCard("Detalhes da Dose", [
                    buildInfoRow("Horário Agendado", DateFormat('HH:mm').format(doseEvent.scheduledTime)),
                    buildInfoRow("Quantidade", prescription.doseDescription),
                    if (prescription.stock != -1)
                      buildInfoRow("Estoque Restante", '${prescription.stock} unidades'),
                  ]),

                  const SizedBox(height: 16),
                  
                  buildInfoCard("Informações do Tratamento", [
                    buildInfoRow("Tipo", prescription.type),
                    if (prescription.doseInterval > 0)
                      buildInfoRow("Intervalo", 'A cada ${Duration(minutes: prescription.doseInterval).inHours}h ${Duration(minutes: prescription.doseInterval).inMinutes.remainder(60)}min'),
                    if (!prescription.isContinuous && prescription.durationTreatment != null)
                      buildInfoRow("Duração", '${prescription.durationTreatment} ${prescription.unitTreatment}'),
                  ]),

                  if (prescription.notes?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 16),
                    buildInfoCard("Observações", [
                      Text(prescription.notes!, style: textTheme.bodyMedium)
                    ]),
                  ]
                ],
              ),
            ),
          ),
          
          // --- BARRA DE AÇÕES APRIMORADA ---
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Editar"),
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.redo),
                    label: const Text("Pular Dose"),
                    onPressed: doseEvent.status == DoseStatus.pendente ? onSkip : null, // Desativa se não estiver pendente
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: colorScheme.error),
                  onPressed: onDelete,
                  tooltip: "Excluir Medicamento",
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}