import 'dart:io';
import 'package:provider/provider.dart';
import 'package:CheckPills/presentation/providers/user_provider.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:share_plus/share_plus.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoseDetailsModal extends StatelessWidget {
  final DoseEventWithPrescription doseData;
  final VoidCallback onSkip;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus; // <-- NOVO CAMPO

  const DoseDetailsModal({
    super.key,
    required this.doseData,
    required this.onSkip,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus, // <-- TORNAR OBRIGATÓRIO
  });

  // MÉTODO PARA CONSTRUIR A MENSAGEM A SER COMPARTILHADA/COPIADA
  String _buildShareableMessage(BuildContext context) {
    // Acessa o nome do usuário ativo através do UserProvider
    final userName =
        Provider.of<UserProvider>(context, listen: false).activeUser?.name ??
            'Usuário';

    // Formata a data e a hora de forma legível
    final formattedTime =
        DateFormat('HH:mm').format(doseData.doseEvent.scheduledTime);
    final formattedDate = DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR')
        .format(doseData.doseEvent.scheduledTime);

    // Lista para construir a mensagem dinamicamente
    final messageParts = [
      'Olá, $userName.',
      '',
      'Lembrete de medicação:',
      '• Medicamento: ${doseData.prescription.name} (${doseData.prescription.doseDescription})',
      '• Horário: Agendado para às $formattedTime do dia $formattedDate.',
    ];

    // Adiciona a linha de estoque apenas se o controle estiver ativo
    if (doseData.prescription.stock != -1) {
      messageParts
          .add('• Estoque Atual: ${doseData.prescription.stock} unidades');
    }

    // Adiciona a linha de observações apenas se houver notas
    if (doseData.prescription.notes?.isNotEmpty ?? false) {
      messageParts.add('• Observações: ${doseData.prescription.notes}');
    }

    // Junta todas as partes com quebras de linha
    return messageParts.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final prescription = doseData.prescription;
    final doseEvent = doseData.doseEvent;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Obter as dimensões da tela
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;

    // Calcular o novo tamanho baseado na porcentagem (ex: 30% da largura da tela)
    final double imageSize = screenWidth * 0.50; // 30% da largura da tela

    // --- HELPER PARA O HEADER DE STATUS ---
    Widget buildStatusHeader() {
      IconData icon;
      String text;
      Color color;
      VoidCallback? action;

      switch (doseEvent.status) {
        case DoseStatus.tomada:
          icon = Icons.check_circle;
          text = "Dose Tomada";
          color = colorScheme.primary;
          action = onToggleStatus;
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
          action = onToggleStatus;
          break;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: color.withValues(alpha: 0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botão/Ícone que permite o toggle
            action != null
                ? IconButton(
                    icon: Icon(icon, color: color),
                    onPressed: action,
                  )
                : Icon(icon, color: color), // Ícone estático se não houver ação
            const SizedBox(width: 8),
            Text(text,
                style: textTheme.titleMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.bold)),
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
            Text(label,
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
            Text(value,
                style: textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
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
              Text(title,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Divider(height: 24),
              ...children,
            ],
          ),
        ),
      );
    }

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            title: Text(prescription.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            leading: null,
            automaticallyImplyLeading: false,
            actions: [
              // NOVO WIDGET: Menu de opções
              PopupMenuButton<String>(
                onSelected: (String value) async {
                  final message = _buildShareableMessage(context);
                  final imagePath = doseData.prescription.imagePath;

                  // Capture tudo que depende de `context` antes do await:
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  if (value == 'copy') {
                    // Ação de Copiar (await direto, sem usar context depois)
                    await FlutterClipboard.copy(message);
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Lembrete copiado para a área de transferência!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (value == 'share') {
                    // Ação de Compartilhar (nova API)
                    if (imagePath != null && await File(imagePath).exists()) {
                      final params = ShareParams(
                        text: message,
                        files: [XFile(imagePath)],
                      );
                      await SharePlus.instance.share(params);
                    } else {
                      await SharePlus.instance.share(
                        ShareParams(text: message),
                      );
                    }
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'copy',
                    child: ListTile(
                      leading: Icon(Icons.copy_all_outlined),
                      title: Text('Copiar detalhes'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'share',
                    child: ListTile(
                      leading: Icon(Icons.share_outlined),
                      title: Text('Compartilhar'),
                    ),
                  ),
                ],
              ),

              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
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
                            // Usando o tamanho calculado
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  buildInfoCard("Detalhes da Dose", [
                    buildInfoRow("Horário Agendado",
                        DateFormat('HH:mm').format(doseEvent.scheduledTime)),
                    buildInfoRow("Quantidade", prescription.doseDescription),
                    if (prescription.stock != -1)
                      buildInfoRow(
                          "Estoque Restante", '${prescription.stock} unidades'),
                  ]),
                  const SizedBox(height: 16),
                  buildInfoCard("Informações do Tratamento", [
                    buildInfoRow("Tipo", prescription.type),
                    // NOVO CÓDIGO
                    if (prescription.intervalValue > 0)
                      buildInfoRow("Intervalo",
                          'A cada ${prescription.intervalValue} ${prescription.intervalUnit}'),
                    if (!prescription.isContinuous &&
                        prescription.durationTreatment != null)
                      buildInfoRow("Duração",
                          '${prescription.durationTreatment} ${prescription.unitTreatment}'),
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
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.redo),
                    label: const Text("Pular Dose"),
                    onPressed: doseEvent.status == DoseStatus.pendente
                        ? onSkip
                        : null, // Desativa se não estiver pendente
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12)),
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
