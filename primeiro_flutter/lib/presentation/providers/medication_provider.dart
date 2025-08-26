import 'package:flutter/material.dart';
import 'package:primeiro_flutter/data/datasources/database.dart';
import 'package:primeiro_flutter/domain/entities/medication.dart';
import 'package:drift/drift.dart'; // LINHA ADICIONADA AQUI

class MedicationProvider with ChangeNotifier {
  final AppDatabase database;
  List<Prescription> _medicationList = [];

  List<Prescription> get medicationList => _medicationList;

  MedicationProvider({required this.database}) {
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    _medicationList = await database.select(database.prescriptions).get();
    notifyListeners();
  }

  Future<void> addMedication(Medication medication) async {
    final prescriptionCompanion = PrescriptionsCompanion.insert(
      name: medication.name,
      doseDescription: medication.dose,
      type: medication.type,
      stock: medication.stock,
      doseInterval: medication.doseInterval.inMinutes,
      isContinuous: medication.isContinuous,
      durationTreatment: Value(medication.durationTreatment),
      unitTreatment: Value(medication.unitTreatment),
      firstDoseTime: medication.firstDoseTime,
      notes: Value(medication.notes),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await database.into(database.prescriptions).insert(prescriptionCompanion);
    await _loadMedications();
  }
}