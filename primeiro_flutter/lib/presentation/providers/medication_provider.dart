// lib/presentation/providers/medication_provider.dart

import 'package:flutter/material.dart';
import 'package:primeiro_flutter/data/datasources/database.dart';

class MedicationProvider with ChangeNotifier {
  final AppDatabase database;

  List<Prescription> _prescriptionList = [];
  List<DoseEventWithPrescription> _doseEventsForDay = [];

  List<Prescription> get prescriptionList => _prescriptionList;
  List<DoseEventWithPrescription> get doseEventsForDay => _doseEventsForDay;

  MedicationProvider({required this.database}) {
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    _prescriptionList = await database.select(database.prescriptions).get();
    await fetchDoseEventsForDay(DateTime.now());
  }

  Future<void> fetchDoseEventsForDay(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    for (final prescription in _prescriptionList) {
      // Se a primeira dose sequer começou, não há o que calcular.
      if (endOfDay.isBefore(prescription.firstDoseTime)) {
        continue;
      }

      // Lógica para tratamento com data de fim
      if (!prescription.isContinuous) {
        DateTime treatmentEndDate = _calculateTreatmentEndDate(prescription);
        if (startOfDay.isAfter(treatmentEndDate)) {
          continue; // O tratamento já acabou, vamos para a próxima prescrição
        }
      }

      // Vamos encontrar a primeira dose que ocorre *neste dia ou antes*.
      DateTime doseCalculator = prescription.firstDoseTime;

      // Avançamos o calculador até chegar ao dia que nos interessa.
      // Isso otimiza o processo para tratamentos longos.
      while (doseCalculator.isBefore(startOfDay)) {
        doseCalculator =
            doseCalculator.add(Duration(minutes: prescription.doseInterval));
      }

      // Agora, a partir da primeira dose do dia, geramos as restantes para aquele dia.
      while (doseCalculator.isBefore(endOfDay)) {
        // Verificamos se esta dose já existe no banco de dados.
        // `getSingleOrNull` é uma forma eficiente de verificar se um registo existe.
        final existingDose = await (database.select(database.doseEvents)
              ..where((d) => d.scheduledTime.equals(doseCalculator))
              ..where((d) => d.prescriptionId.equals(prescription.id)))
            .getSingleOrNull();

        // Se a dose não existir, nós a criamos.
        if (existingDose == null) {
          final newDoseEvent = DoseEventsCompanion.insert(
            prescriptionId: prescription.id,
            scheduledTime: doseCalculator,
            status: DoseStatus.pendente,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await database.into(database.doseEvents).insert(newDoseEvent);
        }

        // Avançamos para a próxima dose.
        doseCalculator =
            doseCalculator.add(Duration(minutes: prescription.doseInterval));
      }
    }

    // Após garantir que todas as doses do dia foram geradas,
    // nós lemos a lista final do banco.
    _doseEventsForDay = await database.getDoseEventsForDay(date);
    _doseEventsForDay.sort((a, b) =>
        a.doseEvent.scheduledTime.compareTo(b.doseEvent.scheduledTime));
    notifyListeners();
  }

  // Função auxiliar para calcular a data final do tratamento
  DateTime _calculateTreatmentEndDate(Prescription prescription) {
    if (prescription.durationTreatment == null ||
        prescription.unitTreatment == null) {
      return prescription.firstDoseTime;
    }

    switch (prescription.unitTreatment) {
      case 'Dias':
        return prescription.firstDoseTime
            .add(Duration(days: prescription.durationTreatment!));
      case 'Semanas':
        return prescription.firstDoseTime
            .add(Duration(days: prescription.durationTreatment! * 7));
      case 'Meses':
        // Adicionar meses é mais complexo, pois eles têm dias diferentes
        var d = prescription.firstDoseTime;
        return DateTime(d.year, d.month + prescription.durationTreatment!,
            d.day, d.hour, d.minute);
      case 'Anos':
        var d = prescription.firstDoseTime;
        return DateTime(d.year + prescription.durationTreatment!, d.month,
            d.day, d.hour, d.minute);
      default:
        return prescription.firstDoseTime;
    }
  }

  Future<void> addPrescription(PrescriptionsCompanion prescription) async {
    await database.into(database.prescriptions).insert(prescription);
    await _loadPrescriptions();
  }

  Future<void> updatePrescription(
      int id, PrescriptionsCompanion newPrescription) async {
    // 1. Atualiza o registro principal da prescrição
    await database.updatePrescription(id, newPrescription);

    // 2. Apaga os eventos de doses futuros para esta prescrição
    // A data de corte é o início do dia atual, garantindo que os eventos passados não sejam afetados.
    final today = DateTime.now();
    await database.deleteDoseEventsForPrescription(
        id, DateTime(today.year, today.month, today.day));

    // 3. Recarrega as prescrições, o que gerará novos eventos para o futuro
    // com base nos dados atualizados.
    await _loadPrescriptions();
    notifyListeners();
  }

  Future<void> _generateAndInsertDoseEvents(Prescription prescription) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDose = prescription.firstDoseTime;

    DateTime currentDoseTime = firstDose;

    // Lógica para começar a gerar a partir de hoje
    if (firstDose.isBefore(today)) {
      final intervalMinutes = prescription.doseInterval;
      var timeSinceFirstDose = today.difference(firstDose);
      var numIntervals =
          (timeSinceFirstDose.inMinutes / intervalMinutes).ceil();
      currentDoseTime =
          firstDose.add(Duration(minutes: numIntervals * intervalMinutes));
    }

    while (true) {
      // Limite a geração de eventos para um ano para evitar sobrecarga
      if (currentDoseTime
          .isAfter(DateTime.now().add(const Duration(days: 365)))) {
        break;
      }

      if (!prescription.isContinuous) {
        final endDate = _calculateEndDate(prescription);
        if (currentDoseTime.isAfter(endDate)) {
          break;
        }
      }

      final doseEvent = DoseEventsCompanion.insert(
        prescriptionId: prescription.id,
        scheduledTime: currentDoseTime,
        status: DoseStatus.pendente,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await database.into(database.doseEvents).insert(doseEvent);

      currentDoseTime =
          currentDoseTime.add(Duration(minutes: prescription.doseInterval));
    }
  }

  DateTime _calculateEndDate(Prescription prescription) {
    if (prescription.durationTreatment == null ||
        prescription.unitTreatment == null) {
      return prescription.firstDoseTime;
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
        return prescription.firstDoseTime;
    }
  }

  // ADICIONADO: Função para deletar uma prescrição
  Future<void> deletePrescription(int id) async {
    await database.deletePrescription(id);
    await _loadPrescriptions();
    notifyListeners();
  }

  Future<void> toggleDoseStatus(DoseEvent doseEvent) async {
    // Lógica para alternar o status
    final newStatus = doseEvent.status == DoseStatus.tomada
        ? DoseStatus.pendente
        : DoseStatus.tomada;

    // Define a hora que foi tomada se o status for "tomada"
    final takenTime = newStatus == DoseStatus.tomada ? DateTime.now() : null;

    // Chama a função do banco de dados para atualizar
    await database.toggleDoseStatus(doseEvent.id, newStatus,
        takenTime: takenTime);

    // Recarrega os eventos para a tela
    await fetchDoseEventsForDay(doseEvent.scheduledTime);
  }
}
