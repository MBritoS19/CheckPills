import 'package:flutter/material.dart';
import 'package:primeiro_flutter/domain/entities/medication.dart';

class MedicationProvider with ChangeNotifier {
  final List<Medication> _medicationList = [
    Medication(
      name: 'Dipirona',
      dose: '1 comprimido',
      type: 'Comprimido', // ADICIONADO AQUI
      stock: 30,
      doseIntervalInHours: 8,
      totalDoses: 90,
      firstDoseTime: '08:00',
    ),
    Medication(
      name: 'Paracetamol',
      dose: '500mg',
      type: 'Gotas', // E AQUI
      stock: 20,
      doseIntervalInHours: 6,
      totalDoses: 60,
      firstDoseTime: '12:00',
      notes: 'Tomar após a refeição',
    ),
  ];

  List<Medication> get medicationList => _medicationList;

  void addMedication(Medication medication) {
    _medicationList.add(medication);
    notifyListeners();
  }
}
