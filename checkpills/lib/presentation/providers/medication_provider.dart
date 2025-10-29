import 'dart:async';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:CheckPills/presentation/providers/user_provider.dart';
import 'package:CheckPills/core/utils/notification_service.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
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
      _sortDoseEvents(_doseEventsForDay); // APLICAÇÃO DA ORDENAÇÃO
      notifyListeners();
    });
  }

  Future<void> rescheduleSingleDose(int doseId, DateTime newTime) async {
    // Usamos a nova função do DAO para atualizar a hora e resetar o status
    await database.doseEventsDao.updateDoseEvent(
      doseId,
      DoseEventsCompanion(
        scheduledTime: Value(newTime),
        status: const Value(DoseStatus.pendente), // Volta para pendente
      ),
    );
  }

// ADICIONE ESTE NOVO MÉTODO
  Future<void> markDoseAsSkipped(int doseId) async {
    await database.doseEventsDao.updateDoseEventStatus(
      doseId,
      DoseStatus.pulada,
      null, // Sem hora de tomada
    );
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
    await NotificationService.instance
        .cancelAllNotificationsForPrescription(id);
    await database.prescriptionsDao
        .updatePrescription(updatedPrescription.copyWith(id: Value(id)));
    await database.doseEventsDao.deleteFutureDoseEventsForPrescription(id);
    final reloadedPrescription =
        await database.prescriptionsDao.getPrescriptionById(id);
    await _generateAndInsertDoseEvents(reloadedPrescription);
  }

  Future<void> deletePrescription(int id) async {
    await database.prescriptionsDao.deletePrescription(id);
    await NotificationService.instance.cancelAllNotificationsForPrescription(id);
  }

  Future<bool> toggleDoseStatus(DoseEventWithPrescription doseData) async {
    final doseEvent = doseData.doseEvent;
    final prescription = doseData.prescription;

    final newStatus = doseEvent.status == DoseStatus.tomada
        ? DoseStatus.pendente
        : DoseStatus.tomada;
    final takenTime = newStatus == DoseStatus.tomada ? DateTime.now() : null;

    if (newStatus == DoseStatus.tomada) {
      await NotificationService.instance
          .cancelNotification(doseEvent.id * 10 + 2);
      await NotificationService.instance
          .cancelNotification(doseEvent.id * 10 + 3);
    }

    await database.doseEventsDao
        .updateDoseEventStatus(doseEvent.id, newStatus, takenTime);

    // Se o usuário está "desmarcando" uma dose, o estoque volta, sem necessidade de alerta.
    if (newStatus == DoseStatus.pendente) {
      if (prescription.stock != -1) {
        final doseQuantity =
            int.tryParse(prescription.doseDescription.split(' ').first) ?? 1;
        final newStock = prescription.stock + doseQuantity;
        await database.prescriptionsDao.updateStock(prescription.id, newStock);
      }
      return false; // Não aciona o alerta
    }

    // --- Lógica de Alerta (apenas quando uma dose é TOMADA) ---

    int newStock = prescription.stock;
    if (prescription.stock != -1) {
      final doseQuantity =
          int.tryParse(prescription.doseDescription.split(' ').first) ?? 1;
      newStock = prescription.stock - doseQuantity;
      await database.prescriptionsDao.updateStock(prescription.id, newStock);
    }

    // VERIFICAÇÃO 1: Se for dose única ou se o estoque não for controlado, não avise.
    if (prescription.intervalValue == 0 || newStock == -1) return false;

    // VERIFICAÇÃO 2: Se não for contínuo e houver estoque para terminar, não avise.
    if (!prescription.isContinuous) {
      final remainingDoses =
          await database.doseEventsDao.countFutureDoseEvents(prescription.id);
      if (newStock >= remainingDoses) {
        return false;
      }
    }

    // VERIFICAÇÃO 3: Verifique contra o lembrete de reposição do usuário.
    final activeUser = userProvider.activeUser;
    if (activeUser == null) return false;
    final settings =
        await database.userSettingsDao.getSettingsForUser(activeUser.id);
    final refillReminder = settings?.refillReminder ?? 5; // Usa 5 como padrão

    if (newStock <= refillReminder) {
      return true; // CONDIÇÃO ATINGIDA! Sinalize para a UI.
    }

    return false; // Nenhuma condição de alerta foi atingida.
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
    final notificationService = NotificationService.instance;

    Future<void> scheduleNotificationsForDose(
        int doseId, DateTime scheduledTime) async {
      // 1. Lembrete Antecipado
      if (prescription.notifyMinutesBefore != null) {
        await notificationService.scheduleNotification(
          id: doseId * 10 + 1,
          title: 'Lembrete: ${prescription.name}',
          body:
              'Hora de tomar sua dose de ${prescription.doseDescription} em ${prescription.notifyMinutesBefore} minutos.',
          scheduledDate: scheduledTime
              .subtract(Duration(minutes: prescription.notifyMinutesBefore!)),
          payload: 'PRESCRIPTION_ID:${prescription.id}',
        );
      }

      // 2. Lembrete Pontual
      if (prescription.notifyOnTime) {
        await notificationService.scheduleNotification(
          id: doseId * 10 + 2,
          title: 'Está na hora: ${prescription.name}',
          body: 'Tome sua dose de ${prescription.doseDescription} agora.',
          scheduledDate: scheduledTime,
          payload: 'PRESCRIPTION_ID:${prescription.id}',
        );
      }

      // 3. Lembrete de Atraso
      if (prescription.notifyAfterMinutes != null) {
        await notificationService.scheduleNotification(
          id: doseId * 10 + 3,
          title: 'Dose Atrasada: ${prescription.name}',
          body:
              'Você esqueceu de tomar sua dose de ${prescription.doseDescription} às ${DateFormat('HH:mm').format(scheduledTime)}.',
          scheduledDate: scheduledTime
              .add(Duration(minutes: prescription.notifyAfterMinutes!)),
          payload: 'PRESCRIPTION_ID:${prescription.id}',
        );
      }
    }

    // Lógica de geração de doses
    if (prescription.intervalValue == 0) {
      // Dose única
      final newDoseEvent = DoseEventsCompanion.insert(
        prescriptionId: prescription.id,
        scheduledTime: prescription.firstDoseTime,
        status: const Value(DoseStatus.pendente),
      );
      // CORRIGIDO: addDoseEvent agora retorna o objeto completo
      final newDose = await database.doseEventsDao.addDoseEvent(newDoseEvent);
      if (prescription.enableNotifications) {
        await scheduleNotificationsForDose(newDose.id, newDose.scheduledTime);
      }
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
      // CORRIGIDO: addDoseEvent agora retorna o objeto completo
      final newDose = await database.doseEventsDao.addDoseEvent(newDoseEvent);
      if (prescription.enableNotifications) {
        await scheduleNotificationsForDose(newDose.id, newDose.scheduledTime);
      }

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

  // --- LÓGICA DE ORDENAÇÃO POR STATUS (NOVO CÓDIGO) ---

  // Método auxiliar para determinar a prioridade de ordenação
  // 1: Pendentes (no horário/futuro)
  // 2: Atrasadas
  // 3: Completas (Tomadas ou Puladas)
  int _getDosePriority(DoseEventWithPrescription dose) {
    final status = dose.doseEvent.status;
    final scheduledTime = dose.doseEvent.scheduledTime;
    final now = DateTime.now();

    // 3. Doses Tomadas ou Puladas (Completas) - Última prioridade
    if (status == DoseStatus.tomada || status == DoseStatus.pulada) {
      return 3;
    }

    // 1 & 2. Doses Pendentes
    if (status == DoseStatus.pendente) {
      // 2. Atrasadas: Agendada antes de agora
      if (scheduledTime.isBefore(now)) {
        return 2;
      }
      // 1. Pendentes (no horário/futuro) - Primeira prioridade
      return 1;
    }

    // Default
    return 4;
  }

  // Ordena a lista de doses de acordo com o status
  void _sortDoseEvents(List<DoseEventWithPrescription> doses) {
    doses.sort((a, b) {
      final priorityA = _getDosePriority(a);
      final priorityB = _getDosePriority(b);

      // 1. Ordena pela prioridade (1, 2, 3)
      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }

      // 2. Se a prioridade for a mesma, ordena pelo horário agendado (mais cedo primeiro)
      return a.doseEvent.scheduledTime.compareTo(b.doseEvent.scheduledTime);
    });
  }

  // --- FIM DA LÓGICA DE ORDENAÇÃO ---

  @override
  void dispose() {
    userProvider.removeListener(_loadDataForActiveUser);
    _doseEventsForDaySubscription?.cancel();
    _allDoseEventsSubscription?.cancel();
    _prescriptionsSubscription?.cancel();
    super.dispose();
  }
}
