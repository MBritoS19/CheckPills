import 'package:flutter/material.dart';
import 'package:primeiro_flutter/domain/entities/medication.dart';

class MedicationProvider with ChangeNotifier {
  final List<Medication> _medicationList = [
    Medication(
      name: 'Dipirona',
      dose: '1 comprimido',
      type: 'Comprimido',
      stock: 30,
      // MUDANÇA AQUI: Trocamos o int por um objeto Duration.
      doseInterval: const Duration(hours: 8),
      totalDoses: 90,
      firstDoseTime: DateTime(2025, 8, 22, 8, 0),
    ),
    Medication(
      name: 'Paracetamol',
      dose: '500mg',
      type: 'Gotas',
      stock: 20,
      // E AQUI TAMBÉM
      doseInterval: const Duration(hours: 6),
      totalDoses: 60,
      firstDoseTime: DateTime(2025, 8, 22, 12, 0),
      notes: 'Tomar após a refeição',
    ),
  ];

  List<Medication> get medicationList => _medicationList;

  void addMedication(Medication medication) {
    _medicationList.add(medication);
    notifyListeners();
  }
}
