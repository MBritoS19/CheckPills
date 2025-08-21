import 'package:flutter/material.dart';
import 'package:checkpills/core/constants/medication_constants.dart';
import 'package:checkpills/core/constants/app_constants.dart';

class MedicationTypeSelection extends StatelessWidget {
  final String? selectedType;
  final Function(String) onTypeSelected;
  final double screenWidth;

  const MedicationTypeSelection({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Qual o tipo do medicamento?',
            style: TextStyle(
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ListView(
            shrinkWrap: true,
            children:
                MedicationConstants.medicationCategories.keys.map((category) {
              return RadioListTile<String>(
                title: Text(
                  category,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  MedicationConstants.medicationCategories[category]!
                      .join(', '),
                ),
                value: category,
                groupValue: selectedType,
                onChanged: (value) {
                  if (value != null) {
                    onTypeSelected(value);
                  }
                },
                activeColor: AppColors.primaryBlue,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
