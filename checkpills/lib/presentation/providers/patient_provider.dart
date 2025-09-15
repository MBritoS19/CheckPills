// lib/presentation/providers/patient_provider.dart

import 'package:flutter/material.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:drift/drift.dart' hide Column;

class PatientProvider with ChangeNotifier {
  final AppDatabase database;
  List<Patient> _patientList = [];

  List<Patient> get patientList => _patientList;

  PatientProvider({required this.database}) {
    _loadPatients();
  }

  void _loadPatients() {
    database.patientsDao.getAllPatients().then((patients) {
      _patientList = patients;
      notifyListeners();
    });
  }

  Future<void> addPatient(String name) async {
    final newPatient = PatientsCompanion.insert(
      name: name,
    );
    await database.patientsDao.addPatient(newPatient);
    _loadPatients(); // Removido o 'await'
  }
}
