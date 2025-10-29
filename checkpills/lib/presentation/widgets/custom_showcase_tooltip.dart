import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class CustomShowcaseTooltip extends StatelessWidget {
  final String description;
  final VoidCallback onTutorialFinish;
  final bool isLastStep;

  const CustomShowcaseTooltip({
    super.key,
    required this.description,
    required this.onTutorialFinish,
    this.isLastStep = false,
  });

  @override
  Widget build(BuildContext context) {
    // Pega a instância atual do ShowcaseView (nova API)
    final showcase = ShowcaseView.get();

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
                    showcase.dismiss(); // Usa o novo objeto showcase
                  },
                  child: const Text('Pular'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (isLastStep) {
                      onTutorialFinish();
                      showcase.dismiss(); // Usa o novo objeto showcase
                    } else {
                      showcase.next(); // Avança para o próximo passo
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
