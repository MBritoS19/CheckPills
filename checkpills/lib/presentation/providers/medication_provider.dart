import 'package:CheckPills/data/datasources/database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'dart:async';

class MedicationProvider with ChangeNotifier {
  final AppDatabase database;

  List<Prescription> _prescriptionList = [];
  List<DoseEventWithPrescription> _doseEventsForDay = [];
  StreamSubscription? _doseEventsSubscription;

  List<Prescription> get prescriptionList => _prescriptionList;
  List<DoseEventWithPrescription> get doseEventsForDay => _doseEventsForDay;

  StreamSubscription? _allEventsSubscription; // Nova variável
  Map<DateTime, List<DoseEventWithPrescription>> eventsByDay =
      {}; // Nova variável

  MedicationProvider({required this.database}) {
    _loadPrescriptions();
    _listenToAllDoseEvents();
  }

  @override
  void dispose() {
    _doseEventsSubscription?.cancel();
    _allEventsSubscription?.cancel(); // Nova linha
    super.dispose();
  }

  void _listenToAllDoseEvents() {
    _allEventsSubscription?.cancel();
    _allEventsSubscription =
        database.doseEventsDao.watchAllDoseEvents().listen((allDoses) {
      // Agrupa a lista de doses em um mapa por dia
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

      eventsByDay = newEventsByDay;
      notifyListeners();
    });
  }

  Future<void> _loadPrescriptions() async {
    _prescriptionList = await database.prescriptionsDao.getAllPrescriptions();
    fetchDoseEventsForDay(DateTime.now());
  }

  Future<void> updatePrescriptionStock(int prescriptionId, int newStock) async {
    await database.prescriptionsDao.updateStock(prescriptionId, newStock);
    // Recarrega as prescrições para que a UI reflita a mudança
    await _loadPrescriptions();
  }

  Future<void> stopTrackingStock(int prescriptionId) async {
    // Define o estoque como -1 para indicar que não é mais controlado
    await database.prescriptionsDao.updateStock(prescriptionId, -1);
    await _loadPrescriptions();
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

  // Substitua o método antigo por este
  Future<void> toggleDoseStatus(DoseEventWithPrescription doseData) async {
    final doseEvent = doseData.doseEvent;
    final prescription = doseData.prescription;

    final newStatus = doseEvent.status == DoseStatus.tomada
        ? DoseStatus.pendente
        : DoseStatus.tomada;
    final takenTime = newStatus == DoseStatus.tomada ? DateTime.now() : null;

    // Atualiza o status do evento de dose
    await database.doseEventsDao
        .updateDoseEventStatus(doseEvent.id, newStatus, takenTime);

    // Lógica para incrementar/decrementar estoque
    if (prescription.stock != -1) {
      // Só altera o estoque se ele estiver sendo controlado
      // Tenta extrair a quantidade da dose. Ex: "2 comprimidos" -> 2. Se falhar, assume 1.
      final doseQuantity =
          int.tryParse(prescription.doseDescription.split(' ').first) ?? 1;

      if (newStatus == DoseStatus.tomada) {
        // Se marcou como tomada, decrementa o estoque
        final newStock = prescription.stock - doseQuantity;
        await database.prescriptionsDao.updateStock(prescription.id, newStock);
      } else {
        // Se desmarcou, incrementa o estoque de volta
        final newStock = prescription.stock + doseQuantity;
        await database.prescriptionsDao.updateStock(prescription.id, newStock);
      }
      // Recarrega os dados para a UI refletir o novo estoque
      await _loadPrescriptions();
    }
  }

  Future<void> _generateAndInsertDoseEvents(Prescription prescription) async {
    // NOVO: Adiciona um tratamento especial para dose única
    if (prescription.doseInterval == 0) {
      final newDoseEvent = DoseEventsCompanion.insert(
        prescriptionId: prescription.id,
        scheduledTime: prescription.firstDoseTime,
        status: const Value(DoseStatus.pendente),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );
      await database.doseEventsDao.addDoseEvent(newDoseEvent);
      return; // Sai da função para não entrar no loop abaixo
    }

    // O código existente continua daqui para baixo, sem alterações
    final endDate = prescription.isContinuous
        ? DateTime.now().add(const Duration(days: 365))
        : _calculateTreatmentEndDate(prescription);

    DateTime nextDoseTime = prescription.firstDoseTime;

    while (nextDoseTime.isBefore(endDate)) {
      final newDoseEvent = DoseEventsCompanion.insert(
        prescriptionId: prescription.id,
        scheduledTime: nextDoseTime,
        status: const Value(DoseStatus.pendente),
        createdAt: Value(DateTime.now()),
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
