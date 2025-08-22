import 'package:flutter/material.dart';
import 'package:primeiro_flutter/domain/entities/medication.dart';

class MedicationProvider with ChangeNotifier {
  final List<Medication> _medicationList = [
    Medication(
      name: 'Dipirona',
      dose: '1 comprimido',
      type: 'Comprimido',
      stock: 30,
      doseIntervalInHours: 8,
      totalDoses: 90,
      // MUDANÇA AQUI: Agora usamos DateTime para criar a data e hora.
      firstDoseTime: DateTime(2025, 8, 21, 8, 0), // Ano, Mês, Dia, Hora, Minuto
    ),
    Medication(
      name: 'Paracetamol',
      dose: '500mg',
      type: 'Gotas',
      stock: 20,
      doseIntervalInHours: 6,
      totalDoses: 60,
      // E AQUI TAMBÉM
      firstDoseTime: DateTime(2025, 8, 21, 12, 0),
      notes: 'Tomar após a refeição',
    ),
  ];

  List<Medication> get medicationList => _medicationList;

  void addMedication(Medication medication) {
    _medicationList.add(medication);
    notifyListeners();
  }
}
