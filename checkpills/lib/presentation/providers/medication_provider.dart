import 'dart:async';
import 'package:flutter/material.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:drift/drift.dart' hide Column;

class MedicationProvider with ChangeNotifier {
  final AppDatabase database;

  List<Prescription> _prescriptionList = [];
  List<DoseEventWithPrescription> _doseEventsForDay = [];
  StreamSubscription? _doseEventsSubscription;

  List<Prescription> get prescriptionList => _prescriptionList;
  List<DoseEventWithPrescription> get doseEventsForDay => _doseEventsForDay;

  MedicationProvider({required this.database}) {
    _loadPrescriptions();
  }

  @override
  void dispose() {
    _doseEventsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadPrescriptions() async {
    _prescriptionList = await database.prescriptionsDao.getAllPrescriptions();
    fetchDoseEventsForDay(DateTime.now());
  }

  void fetchDoseEventsForDay(DateTime date) {
    _doseEventsSubscription?.cancel();
    _doseEventsSubscription =
        database.doseEventsDao.watchDoseEventsForDay(date).listen((doses) {
      _doseEventsForDay = doses;
      notifyListeners();
    });
  }

  Future<void> addPrescription(PrescriptionsCompanion prescription) async {
    final newId = await database.prescriptionsDao.addPrescription(prescription);
    final newPrescription =
        await database.prescriptionsDao.getPrescriptionById(newId);
    await _generateAndInsertDoseEvents(newPrescription);
    await _loadPrescriptions();
  }

  Future<void> updatePrescription(
      int id, PrescriptionsCompanion updatedPrescription) async {
    await database.prescriptionsDao
        .updatePrescription(updatedPrescription.copyWith(id: Value(id)));
    await database.doseEventsDao.deleteFutureDoseEventsForPrescription(id);
    final reloadedPrescription =
        await database.prescriptionsDao.getPrescriptionById(id);
    await _generateAndInsertDoseEvents(reloadedPrescription);
    await _loadPrescriptions();
  }

  Future<void> deletePrescription(int id) async {
    await database.prescriptionsDao.deletePrescription(id);
    await _loadPrescriptions();
  }

  Future<void> toggleDoseStatus(DoseEvent doseEvent) async {
    final newStatus = doseEvent.status == DoseStatus.tomada
        ? DoseStatus.pendente
        : DoseStatus.tomada;
    final takenTime = newStatus == DoseStatus.tomada ? DateTime.now() : null;
    await database.doseEventsDao
        .updateDoseEventStatus(doseEvent.id, newStatus, takenTime);
  }

  Future<void> _generateAndInsertDoseEvents(Prescription prescription) async {
    final endDate = prescription.isContinuous
        ? DateTime.now().add(const Duration(days: 365))
        : _calculateTreatmentEndDate(prescription);

    DateTime nextDoseTime = prescription.firstDoseTime;

    while (nextDoseTime.isBefore(endDate)) {
      final newDoseEvent = DoseEventsCompanion.insert(
        prescriptionId: prescription.id,
        scheduledTime: nextDoseTime,
        status: const Value(DoseStatus.pendente),
        // MUDANÇA AQUI: Embrulhamos o DateTime com Value()
        createdAt: Value(DateTime.now()),
        // E AQUI TAMBÉM
        updatedAt: Value(DateTime.now()),
      );
      await database.doseEventsDao.addDoseEvent(newDoseEvent);

      nextDoseTime =
          nextDoseTime.add(Duration(minutes: prescription.doseInterval));
    }
  }

  DateTime _calculateTreatmentEndDate(Prescription prescription) {
    if (prescription.durationTreatment == null ||
        prescription.unitTreatment == null) {
      return prescription.firstDoseTime.add(const Duration(days: 365 * 5));
    }
    switch (prescription.unitTreatment) {
      case 'Dias':
        return prescription.firstDoseTime
            .add(Duration(days: prescription.durationTreatment!));
      case 'Semanas':
        return prescription.firstDoseTime
            .add(Duration(days: prescription.durationTreatment! * 7));
      case 'Meses':
        var d = prescription.firstDoseTime;
        return DateTime(d.year, d.month + prescription.durationTreatment!,
            d.day, d.hour, d.minute);
      case 'Anos':
        var d = prescription.firstDoseTime;
        return DateTime(d.year + prescription.durationTreatment!, d.month,
            d.day, d.hour, d.minute);
      default:
        return prescription.firstDoseTime.add(const Duration(days: 365 * 5));
    }
  }
}
