import 'package:flutter/material.dart';
import 'package:primeiro_flutter/data/datasources/database.dart';

class MedicationProvider with ChangeNotifier {
  final AppDatabase database;

  List<Prescription> _prescriptionList = [];
  List<DoseEvent> _doseEventsForDay = [];

  List<Prescription> get prescriptionList => _prescriptionList;
  List<DoseEvent> get doseEventsForDay => _doseEventsForDay;

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
        if(startOfDay.isAfter(treatmentEndDate)){
          continue; // O tratamento já acabou, vamos para a próxima prescrição
        }
      }

      // Vamos encontrar a primeira dose que ocorre *neste dia ou antes*.
      DateTime doseCalculator = prescription.firstDoseTime;
      
      // Avançamos o calculador até chegar ao dia que nos interessa.
      // Isso otimiza o processo para tratamentos longos.
      while(doseCalculator.isBefore(startOfDay)) {
        doseCalculator = doseCalculator.add(Duration(minutes: prescription.doseInterval));
      }

      // Agora, a partir da primeira dose do dia, geramos as restantes para aquele dia.
      while(doseCalculator.isBefore(endOfDay)) {
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
        doseCalculator = doseCalculator.add(Duration(minutes: prescription.doseInterval));
      }
    }

    // Após garantir que todas as doses do dia foram geradas,
    // nós lemos a lista final do banco.
    _doseEventsForDay = await database.getDoseEventsForDay(date);
    _doseEventsForDay.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    notifyListeners();
  }

  // Função auxiliar para calcular a data final do tratamento
  DateTime _calculateTreatmentEndDate(Prescription prescription) {
    if (prescription.durationTreatment == null || prescription.unitTreatment == null) {
      return prescription.firstDoseTime;
    }

    switch(prescription.unitTreatment) {
      case 'Dias':
        return prescription.firstDoseTime.add(Duration(days: prescription.durationTreatment!));
      case 'Semanas':
        return prescription.firstDoseTime.add(Duration(days: prescription.durationTreatment! * 7));
      case 'Meses':
        // Adicionar meses é mais complexo, pois eles têm dias diferentes
        var d = prescription.firstDoseTime;
        return DateTime(d.year, d.month + prescription.durationTreatment!, d.day, d.hour, d.minute);
      case 'Anos':
        var d = prescription.firstDoseTime;
        return DateTime(d.year + prescription.durationTreatment!, d.month, d.day, d.hour, d.minute);
      default:
        return prescription.firstDoseTime;
    }
  }

  Future<void> addPrescription(PrescriptionsCompanion prescription) async {
    await database.into(database.prescriptions).insert(prescription);
    await _loadPrescriptions();
  }
}