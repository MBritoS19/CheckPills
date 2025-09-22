import 'dart:async';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:CheckPills/presentation/providers/user_provider.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

class MedicationProvider with ChangeNotifier {
  final AppDatabase database;
  final UserProvider userProvider;

  // Streams
  StreamSubscription? _doseEventsForDaySubscription;
  StreamSubscription? _allDoseEventsSubscription;
  StreamSubscription? _prescriptionsSubscription;

  // Listas de dados
  List<Prescription> _prescriptionList = [];
  List<DoseEventWithPrescription> _doseEventsForDay = [];
  Map<DateTime, List<DoseEventWithPrescription>> _eventsByDay = {};

  // Getters públicos
  List<Prescription> get prescriptionList => _prescriptionList;
  List<DoseEventWithPrescription> get doseEventsForDay => _doseEventsForDay;
  Map<DateTime, List<DoseEventWithPrescription>> get eventsByDay =>
      _eventsByDay;

  MedicationProvider({required this.database, required this.userProvider}) {
    userProvider.addListener(_loadDataForActiveUser);
    _loadDataForActiveUser();
  }

  void _loadDataForActiveUser() {
    final activeUser = userProvider.activeUser;

    _prescriptionsSubscription?.cancel();
    _allDoseEventsSubscription?.cancel();
    _doseEventsForDaySubscription?.cancel();

    if (activeUser != null) {
      _prescriptionsSubscription = database.prescriptionsDao
          .watchAllPrescriptionsForUser(activeUser.id)
          .listen((prescriptions) {
        _prescriptionList = prescriptions;
        notifyListeners();
      });

      _allDoseEventsSubscription = database.doseEventsDao
          .watchAllDoseEvents(activeUser.id)
          .listen((allDoses) {
        final newEventsByDay = <DateTime, List<DoseEventWithPrescription>>{};
        for (final dose in allDoses) {
          final day = DateTime.utc(
              dose.doseEvent.scheduledTime.year,
              dose.doseEvent.scheduledTime.month,
              dose.doseEvent.scheduledTime.day);
          final existingDoses = newEventsByDay[day] ?? [];
          existingDoses.add(dose);
          newEventsByDay[day] = existingDoses;
        }
        _eventsByDay = newEventsByDay;
        notifyListeners();
      });

      fetchDoseEventsForDay(_doseEventsForDay.isNotEmpty
          ? _doseEventsForDay.first.doseEvent.scheduledTime
          : DateTime.now());
    } else {
      _prescriptionList = [];
      _doseEventsForDay = [];
      _eventsByDay = {};
      notifyListeners();
    }
  }

  void fetchDoseEventsForDay(DateTime date) {
    _doseEventsForDaySubscription?.cancel();
    final activeUser = userProvider.activeUser;
    if (activeUser == null) return;

    _doseEventsForDaySubscription = database.doseEventsDao
        .watchDoseEventsForDay(activeUser.id, date)
        .listen((doses) {
      _doseEventsForDay = doses;
      notifyListeners();
    });
  }

  Future<void> addPrescription(PrescriptionsCompanion prescription) async {
    final activeUser = userProvider.activeUser;
    if (activeUser == null) return;

    final newId = await database.prescriptionsDao
        .addPrescription(prescription.copyWith(userId: Value(activeUser.id)));
    final newPrescription =
        await database.prescriptionsDao.getPrescriptionById(newId);
    await _generateAndInsertDoseEvents(newPrescription);
  }

  Future<void> updatePrescription(
      int id, PrescriptionsCompanion updatedPrescription) async {
    await database.prescriptionsDao
        .updatePrescription(updatedPrescription.copyWith(id: Value(id)));
    await database.doseEventsDao.deleteFutureDoseEventsForPrescription(id);
    final reloadedPrescription =
        await database.prescriptionsDao.getPrescriptionById(id);
    await _generateAndInsertDoseEvents(reloadedPrescription);
  }

  Future<void> deletePrescription(int id) async {
    await database.prescriptionsDao.deletePrescription(id);
  }

  Future<void> toggleDoseStatus(DoseEventWithPrescription doseData) async {
    final doseEvent = doseData.doseEvent;
    final prescription = doseData.prescription;
    final newStatus = doseEvent.status == DoseStatus.tomada
        ? DoseStatus.pendente
        : DoseStatus.tomada;
    final takenTime = newStatus == DoseStatus.tomada ? DateTime.now() : null;

    await database.doseEventsDao
        .updateDoseEventStatus(doseEvent.id, newStatus, takenTime);

    if (prescription.stock != -1) {
      final doseQuantity =
          int.tryParse(prescription.doseDescription.split(' ').first) ?? 1;

      final newStock = newStatus == DoseStatus.tomada
          ? prescription.stock - doseQuantity
          : prescription.stock + doseQuantity;

      await database.prescriptionsDao.updateStock(prescription.id, newStock);
    }
  }

  Future<void> skipDoseAndReschedule(DoseEventWithPrescription doseData) async {
    final doseEvent = doseData.doseEvent;
    final prescription = doseData.prescription;

    await database.doseEventsDao.updateDoseEventStatus(
      doseEvent.id,
      DoseStatus.pulada,
      null,
    );

    if (prescription.intervalValue == 0) return;

    final lastDose = await database.doseEventsDao
        .getLastDoseEventForPrescription(prescription.id);

    if (lastDose == null) return;

    final newFinalDoseTime =
        _calculateNextDoseTime(lastDose.scheduledTime, prescription);

    final endDate = _calculateTreatmentEndDate(prescription);

    if (!newFinalDoseTime.isAfter(endDate)) {
      final newDoseEvent = DoseEventsCompanion.insert(
        prescriptionId: prescription.id,
        scheduledTime: newFinalDoseTime,
        status: const Value(DoseStatus.pendente),
      );
      await database.doseEventsDao.addDoseEvent(newDoseEvent);
    }
  }

  Future<void> undoSkipDose(DoseEventWithPrescription doseData) async {
    final doseEvent = doseData.doseEvent;
    final prescription = doseData.prescription;

    // 1. Reverte o status da dose atual para "pendente"
    await database.doseEventsDao.updateDoseEventStatus(
      doseEvent.id,
      DoseStatus.pendente, // Voltando para pendente
      null,
    );

    // Se for dose única, não há o que remover
    if (prescription.intervalValue == 0) return;

    // 2. Encontra a última dose agendada
    final lastDose = await database.doseEventsDao
        .getLastDoseEventForPrescription(prescription.id);

    // 3. Se uma última dose existir, remove-a
    if (lastDose != null) {
      await database.doseEventsDao.deleteDoseEvent(lastDose.id);
    }
  }

  Future<void> updatePrescriptionStock(int prescriptionId, int newStock) async {
    await database.prescriptionsDao.updateStock(prescriptionId, newStock);
  }

  Future<void> stopTrackingStock(int prescriptionId) async {
    await database.prescriptionsDao.updateStock(prescriptionId, -1);
  }

  Future<void> _generateAndInsertDoseEvents(Prescription prescription) async {
    if (prescription.intervalValue == 0) {
      final newDoseEvent = DoseEventsCompanion.insert(
        prescriptionId: prescription.id,
        scheduledTime: prescription.firstDoseTime,
        status: const Value(DoseStatus.pendente),
      );
      await database.doseEventsDao.addDoseEvent(newDoseEvent);
      return;
    }

    final endDate = prescription.isContinuous
        ? DateTime.now().add(const Duration(days: 365))
        : _calculateTreatmentEndDate(prescription);

    DateTime nextDoseTime = prescription.firstDoseTime;

    while (nextDoseTime.isBefore(endDate)) {
      final newDoseEvent = DoseEventsCompanion.insert(
        prescriptionId: prescription.id,
        scheduledTime: nextDoseTime,
        status: const Value(DoseStatus.pendente),
      );
      await database.doseEventsDao.addDoseEvent(newDoseEvent);

      nextDoseTime = _calculateNextDoseTime(nextDoseTime, prescription);
    }
  }

  // NOVO MÉTODO AUXILIAR
  DateTime _calculateNextDoseTime(
      DateTime currentTime, Prescription prescription) {
    switch (prescription.intervalUnit) {
      case 'Horas':
        return currentTime.add(Duration(hours: prescription.intervalValue));
      case 'Dias':
        return currentTime.add(Duration(days: prescription.intervalValue));
      case 'Semanas':
        return currentTime.add(Duration(days: prescription.intervalValue * 7));
      case 'Meses':
        // Adicionar meses requer um cuidado especial para não causar problemas
        // com meses de durações diferentes (ex: 31 de janeiro + 1 mês = 28 de fevereiro).
        return DateTime(
          currentTime.year,
          currentTime.month + prescription.intervalValue,
          currentTime.day,
          currentTime.hour,
          currentTime.minute,
        );
      default:
        // Caso padrão, apenas para segurança.
        return currentTime.add(Duration(days: prescription.intervalValue));
    }
  }

  DateTime _calculateTreatmentEndDate(Prescription prescription) {
    if (prescription.durationTreatment == null ||
        prescription.unitTreatment == null) {
      // Para tratamentos sem duração definida, definimos um fim muito distante
      return prescription.firstDoseTime.add(const Duration(days: 365 * 10));
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
        // Adiciona um dia extra para garantir que o último dia seja incluído
        var endDate = DateTime(d.year,
            d.month + prescription.durationTreatment!, d.day, d.hour, d.minute);
        return endDate.add(const Duration(days: 1));
      case 'Anos':
        var d = prescription.firstDoseTime;
        var endDate = DateTime(d.year + prescription.durationTreatment!,
            d.month, d.day, d.hour, d.minute);
        return endDate.add(const Duration(days: 1));
      default:
        return prescription.firstDoseTime.add(const Duration(days: 365 * 10));
    }
  }

  @override
  void dispose() {
    userProvider.removeListener(_loadDataForActiveUser);
    _doseEventsForDaySubscription?.cancel();
    _allDoseEventsSubscription?.cancel();
    _prescriptionsSubscription?.cancel();
    super.dispose();
  }
}
