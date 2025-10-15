import 'package:flutter/material.dart';

class CustomShowcaseTooltip extends StatelessWidget {
  final String description;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const CustomShowcaseTooltip({
    super.key,
    required this.description,
    required this.onNext,
    required this.onSkip,
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
                  onPressed: onSkip,
                  child: const Text('Pular'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onNext,
                  child: const Text('Próximo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
