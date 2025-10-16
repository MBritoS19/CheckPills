import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class CustomShowcaseTooltip extends StatelessWidget {
  final String description;
  final ShowCaseWidgetState showcaseState; // A "linha direta" para o estado
  final VoidCallback onTutorialFinish;
  final bool isLastStep;

  const CustomShowcaseTooltip({
    super.key,
    required this.description,
    required this.showcaseState, // Novo parâmetro
    required this.onTutorialFinish,
    this.isLastStep = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    onTutorialFinish();
                    showcaseState.dismiss(); // USA O ESTADO DIRETAMENTE
                  },
                  child: const Text('Pular'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (isLastStep) {
                      onTutorialFinish();
                      showcaseState.dismiss(); // USA O ESTADO DIRETAMENTE
                    } else {
                      showcaseState.next(); // USA O ESTADO DIRETAMENTE
                    }
                  },
                  child: Text(isLastStep ? 'Concluir' : 'Próximo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
