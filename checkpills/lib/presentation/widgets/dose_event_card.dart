import 'dart:io';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoseEventCard extends StatelessWidget {
  final DoseEventWithPrescription doseData;
  final VoidCallback onToggleStatus;
  final VoidCallback onTap;
  final VoidCallback onUndoSkip;
  // Propriedade para indicar se a dose está atrasada (overdue).
  final bool isOverdue;

  const DoseEventCard({
    super.key,
    required this.doseData,
    required this.onToggleStatus,
    required this.onTap,
    required this.onUndoSkip,
    this.isOverdue = false, // Adicionada no construtor
  });

  @override
  Widget build(BuildContext context) {
    final doseEvent = doseData.doseEvent;
    final prescription = doseData.prescription;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // --- LÓGICA DE OPACIDADE E RISCADO ---
    final bool isActionCompleted = doseEvent.status != DoseStatus.pendente;
    final double contentOpacity = isActionCompleted ? 0.6 : 1.0;
    final TextDecoration? textDecoration =
        isActionCompleted ? TextDecoration.lineThrough : null;

    // --- LÓGICA DE DESTAQUE PARA DOSE ATRASADA (LARANJA CLARO) ---
    // Aplica destaque APENAS se estiver atrasada (isOverdue == true) E pendente (!isActionCompleted)
    final bool shouldHighlightOverdue = isOverdue && !isActionCompleted;

    // Cor Laranja CLARO para o fundo
    final Color veryLightOrange = Colors.orange.shade50;

    // Cor Laranja Escuro para o texto (para contraste)
    final Color darkOrange = Colors.orange.shade800;

    final Color cardBackgroundColor = shouldHighlightOverdue
        ? veryLightOrange // Fundo suave laranja usando shade50
        : colorScheme.surface;

    // Borda removida (cor transparente e largura 0.0)
    final Color cardBorderColor = Colors.transparent;

    // Cor condicional para o texto do horário (Laranja Escuro)
    final Color timeTextColor =
        shouldHighlightOverdue ? darkOrange : colorScheme.primary;

    Widget buildStatusIcon() {
      switch (doseEvent.status) {
        case DoseStatus.tomada:
          return Icon(
            Icons.check_circle,
            color: colorScheme.primary,
            size: 30,
          );
        case DoseStatus.pulada:
          return const Icon(
            Icons.skip_next_outlined,
            color: Colors.grey,
            size: 30,
          );
        case DoseStatus.pendente:
          return const Icon(
            Icons.radio_button_unchecked,
            color: Colors.grey,
            size: 30,
          );
      }
    }

    return Card(
      elevation: 2,
      // Aplicando a cor de fundo condicional
      color: cardBackgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        // Borda completamente removida
        side: BorderSide(
          color: cardBorderColor,
          width: 0.0,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Opacity(
          opacity: contentOpacity,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- BLOCO DO HORÁRIO ---
                Container(
                  width: 90,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(doseEvent.scheduledTime),
                        style: textTheme.titleLarge?.copyWith(
                          // Aplicando a cor condicional ao texto do horário (Laranja)
                          color: timeTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Horário",
                        style:
                            textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                // --- DIVISOR VERTICAL ---
                const VerticalDivider(width: 1, thickness: 1),

                // --- BLOCO DE DETALHES ---
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    child: Row(
                      children: [
                        // Imagem
                        Hero(
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
                                  : const Icon(Icons.medication_liquid,
                                      color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Textos
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                prescription.name,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: textDecoration,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                prescription.doseDescription,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[700],
                                  decoration: textDecoration,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Botão de Status
                        IconButton(
                          icon: buildStatusIcon(),
                          onPressed: () {
                            if (doseEvent.status == DoseStatus.pulada) {
                              onUndoSkip();
                            } else {
                              onToggleStatus();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
