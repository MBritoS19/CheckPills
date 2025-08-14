import 'package:flutter/material.dart';
import 'package:checkpills/core/theme/app_theme.dart';

class MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;

  const MedicationCard({super.key, required this.name, required this.dosage});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.medication,
          color: AppTheme.primaryColor, // Removidos os parênteses ()
        ),
        title: Text(name),
        subtitle: Text('Dose: $dosage'),
      ),
    );
  }
}
