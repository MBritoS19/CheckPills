import 'package:flutter/material.dart';
import 'package:primeiro_flutter/domain/entities/medication.dart';

class MedicationProvider with ChangeNotifier {
  final List<Medication> _medicationList = [
    Medication(
      name: 'Dipirona',
      dose: '1 comprimido',
      type: 'Comprimido',
      stock: 30,
      doseInterval: const Duration(hours: 8),
      // MUDANÇA AQUI:
      isContinuous: false, // Não é de uso contínuo
      treatmentLength: 30, // Duração de 30...
      treatmentUnit: 'Dias', // ...dias.
      // totalDoses: 90, <-- REMOVIDO
      firstDoseTime: DateTime(2025, 8, 25, 8, 0),
    ),
    Medication(
      name: 'Paracetamol',
      dose: '500mg',
      type: 'Gotas',
      stock: 20,
      doseInterval: const Duration(hours: 6),
      // E AQUI:
      isContinuous: true, // É de uso contínuo, então não precisa de `treatmentLength` ou `treatmentUnit`.
      // totalDoses: 60, <-- REMOVIDO
      firstDoseTime: DateTime(2025, 8, 25, 12, 0),
      notes: 'Tomar após a refeição',
    ),
  ];

  List<Medication> get medicationList => _medicationList;

  void addMedication(Medication medication) {
    _medicationList.add(medication);
    notifyListeners();
  }
}