// lib/presentation/providers/medication_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:drift/drift.dart' hide Column;

class MedicationProvider with ChangeNotifier {
  final AppDatabase database;

  List<Prescription> _prescriptionList = [];
  List<DoseEventWithPrescriptionAndPatient> _doseEventsForDay = [];
  StreamSubscription? _doseEventsSubscription;

  List<Prescription> get prescriptionList => _prescriptionList;
  List<DoseEventWithPrescriptionAndPatient> get doseEventsForDay => _doseEventsForDay;

  StreamSubscription? _allEventsSubscription;
  Map<DateTime, List<DoseEventWithPrescriptionAndPatient>> eventsByDay = {};

  MedicationProvider({required this.database}) {
    _loadPrescriptions();
    _listenToAllDoseEvents();
  }

  @override
  void dispose() {
    _doseEventsSubscription?.cancel();
    _allEventsSubscription?.cancel();
    super.dispose();
  }

  void _loadPrescriptions() async {
    _prescriptionList = await database.prescriptionsDao.getAllPrescriptions();
    notifyListeners();
  }

  void _listenToAllDoseEvents() {
    _allEventsSubscription?.cancel();
    _allEventsSubscription =
        database.doseEventsDao.watchAllDoseEvents().listen((allDoses) {
      final newEventsByDay = <DateTime, List<DoseEventWithPrescriptionAndPatient>>{};
      for (final dose in allDoses) {
        final day = DateTime.utc(
          dose.doseEvent.scheduledTime.year,
          dose.doseEvent.scheduledTime.month,
          dose.doseEvent.scheduledTime.day,
        );
        newEventsByDay.putIfAbsent(day, () => []).add(dose);
      }
      eventsByDay = newEventsByDay;
      notifyListeners();
    });
  }

  Future<void> fetchDoseEventsForDay(DateTime date) async {
    _doseEventsSubscription?.cancel();
    final eventsStream =
        database.doseEventsDao.watchDoseEventsForDay(date);
    _doseEventsSubscription = eventsStream.listen((events) {
      _doseEventsForDay = events;
      notifyListeners();
    });
  }

  Future<void> addPrescription(PrescriptionsCompanion newPrescription) async {
    final id = await database.prescriptionsDao.addPrescription(newPrescription);
    final prescription = await database.prescriptionsDao.getPrescriptionById(id);
    if (prescription != null) {
      await _generateDoseEvents(prescription);
    }
    _loadPrescriptions();
  }

  Future<void> updatePrescription(PrescriptionsCompanion updatedPrescription) async {
    await database.prescriptionsDao.updatePrescription(updatedPrescription);
    _loadPrescriptions();
  }

  Future<void> deletePrescription(int id) async {
    await database.prescriptionsDao.deletePrescription(id);
    _loadPrescriptions();
  }

  Future<void> toggleDoseStatus(DoseEvent doseEvent) async {
    final updatedStatus = doseEvent.status == DoseStatus.tomada
        ? DoseStatus.pendente
        : DoseStatus.tomada;

    await database.doseEventsDao.updateDoseEvent(
      doseEvent.copyWith(
        status: updatedStatus,
        updatedAt: DateTime.now(),
      ).toCompanion(true),
    );
  }

  Future<void> _generateDoseEvents(Prescription prescription) async {
    // Lógica para gerar eventos de dose
  }

  DateTime _calculateTreatmentEndDate(Prescription prescription) {
    if (prescription.durationTreatment == null || prescription.unitTreatment == null) {
      return prescription.firstDoseTime.add(const Duration(days: 365 * 5));
    }
    switch (prescription.unitTreatment) {
      case 'Dias':
        return prescription.firstDoseTime.add(Duration(days: prescription.durationTreatment!));
      case 'Semanas':
        return prescription.firstDoseTime.add(Duration(days: prescription.durationTreatment! * 7));
      case 'Meses':
        var d = prescription.firstDoseTime;
        return DateTime(d.year, d.month + prescription.durationTreatment!, d.day, d.hour, d.minute);
      case 'Anos':
        var d = prescription.firstDoseTime;
        return DateTime(d.year + prescription.durationTreatment!, d.month, d.day, d.hour, d.minute);
      default:
        return prescription.firstDoseTime.add(const Duration(days: 365 * 5));
    }
  }
}
