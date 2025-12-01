import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:CheckPills/presentation/providers/user_provider.dart';
import 'package:CheckPills/core/utils/notification_service.dart';
import 'package:CheckPills/core/utils/notification_scheduler.dart';
import 'package:CheckPills/core/utils/notification_checker.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class MedicationProvider with ChangeNotifier {
  final AppDatabase database;
  final UserProvider userProvider;
  final NotificationService notificationService;
  late final NotificationScheduler notificationScheduler;
  late final NotificationChecker notificationChecker;

  // Streams - AGORA COM OS IMPORTS CORRETOS
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

  MedicationProvider({required this.database, required this.userProvider})
      : notificationService = NotificationService.instance {
    notificationScheduler = NotificationScheduler(
      database: database,
      notificationService: notificationService,
    );

    notificationChecker = NotificationChecker(
      database: database,
      notificationService: notificationService,
    );

    userProvider.addListener(_loadDataForActiveUser);
    _loadDataForActiveUser();
  }

  void startNotificationChecking() {
    notificationChecker.startPeriodicChecking();
  }

  // Para a verificação
  void stopNotificationChecking() {
    notificationChecker.stopPeriodicChecking();
  }

  // Verificação manual
  Future<void> checkDueMedicationsNow() async {
    await notificationChecker.checkNow();
  }

  // Limpa cache de notificações
  void clearNotificationCache() {
    notificationChecker.clearNotificationCache();
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

  // Método para agendar notificações próximas
  Future<void> scheduleNearbyNotifications() async {
    await notificationScheduler.scheduleNearbyNotifications();
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
  
  // GERA as doses e agenda notificações AUTOMATICAMENTE
  await _generateAndInsertDoseEvents(newPrescription);
}

Future<void> updatePrescription(
    int id, PrescriptionsCompanion updatedPrescription) async {
  // Cancela notificações antigas
  await notificationScheduler.cancelPrescriptionNotifications(id);
  
  await database.prescriptionsDao
      .updatePrescription(updatedPrescription.copyWith(id: Value(id)));
  await database.doseEventsDao.deleteFutureDoseEventsForPrescription(id);
  final reloadedPrescription =
      await database.prescriptionsDao.getPrescriptionById(id);
  
  // REGERA as doses e agenda notificações AUTOMATICAMENTE
  await _generateAndInsertDoseEvents(reloadedPrescription);
}

  Future<void> deletePrescription(int id) async {
    await database.prescriptionsDao.deletePrescription(id);
    await NotificationService.instance
        .cancelAllNotificationsForPrescription(id);
  }

  Future<bool> toggleDoseStatus(DoseEventWithPrescription doseData) async {
    final doseEvent = doseData.doseEvent;
    final prescription = doseData.prescription;

    final newStatus = doseEvent.status == DoseStatus.tomada
        ? DoseStatus.pendente
        : DoseStatus.tomada;
    final takenTime = newStatus == DoseStatus.tomada ? DateTime.now() : null;

    // Cancela notificações desta dose se foi tomada
    if (newStatus == DoseStatus.tomada) {
      await NotificationService.instance
          .cancelNotification(doseEvent.id * 10 + 1);
      await NotificationService.instance
          .cancelNotification(doseEvent.id * 10 + 2);
      await NotificationService.instance
          .cancelNotification(doseEvent.id * 10 + 3);
    }

    await database.doseEventsDao
        .updateDoseEventStatus(doseEvent.id, newStatus, takenTime);

    // Se o usuário está "desmarcando" uma dose, o estoque volta, sem necessidade de alerta.
    if (newStatus == DoseStatus.pendente) {
      await notificationScheduler
          .scheduleNotificationsForPrescription(prescription.id);
    }

    return false; // ou true conforme sua lógica de alerta
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
  final now = DateTime.now();
  
  // DOSE ÚNICA - sempre cria, independente do horário
  if (prescription.intervalValue == 0) {
    final newDoseEvent = DoseEventsCompanion.insert(
      prescriptionId: prescription.id,
      scheduledTime: prescription.firstDoseTime,
      status: const Value(DoseStatus.pendente),
    );

    final newDose = await database.doseEventsDao.addDoseEvent(newDoseEvent);
    
    if (prescription.enableNotifications) {
      await _scheduleNotificationsForNewDose(newDose, prescription);
    }
    return;
  }

  // MEDICAMENTOS COM INTERVALO - LÓGICA MELHORADA
  DateTime nextDoseTime = prescription.firstDoseTime;
  
  // CORREÇÃO INTELIGENTE: Só ajusta para "agora" se o horário passou há menos de 1 hora
  final oneHourAgo = now.subtract(const Duration(hours: 1));
  if (nextDoseTime.isBefore(oneHourAgo)) {
    // Horário muito no passado (>1 hora): começa do próximo ciclo
    while (nextDoseTime.isBefore(now)) {
      nextDoseTime = _calculateNextDoseTime(nextDoseTime, prescription);
    }
  } else if (nextDoseTime.isBefore(now)) {
    // Horário recente (<1 hora atrás): começa AGORA
    nextDoseTime = now;
  }
  // Se for futuro, mantém o horário escolhido

  final maxGenerationDate = now.add(const Duration(days: 60));
  final endDate = prescription.isContinuous
      ? maxGenerationDate
      : (_calculateTreatmentEndDate(prescription).isBefore(maxGenerationDate)
          ? _calculateTreatmentEndDate(prescription)
          : maxGenerationDate);

  int doseCount = 0;
  final maxDoses = 100;

  while ((nextDoseTime.isBefore(endDate) || doseCount == 0) && doseCount < maxDoses) {
    final newDoseEvent = DoseEventsCompanion.insert(
      prescriptionId: prescription.id,
      scheduledTime: nextDoseTime,
      status: const Value(DoseStatus.pendente),
    );

    final newDose = await database.doseEventsDao.addDoseEvent(newDoseEvent);
    
    if (prescription.enableNotifications) {
      await _scheduleNotificationsForNewDose(newDose, prescription);
    }

    nextDoseTime = _calculateNextDoseTime(nextDoseTime, prescription);
    doseCount++;
  }
}

  // Agenda notificações automaticamente para uma nova dose - ESTOQUE APENAS QUANDO ATIVO
Future<void> _scheduleNotificationsForNewDose(DoseEvent dose, Prescription prescription) async {
  final now = DateTime.now();
  
  // CORREÇÃO: Agenda notificações para qualquer dose que não esteja no passado distante
  // (permite doses que acabaram de passar, até 1 hora atrás)
  final oneHourAgo = now.subtract(const Duration(hours: 1));
  
  if (dose.scheduledTime.isAfter(oneHourAgo)) {
    
    String bodyText = '';
    
    if (prescription.notes?.isNotEmpty == true) {
      bodyText += '📝 ${prescription.notes}';
    }
    
    if (prescription.stock != -1) {
      if (bodyText.isNotEmpty) bodyText += '\n';
      bodyText += '📦 Estoque: ${prescription.stock} ${_getStockUnit(prescription.doseDescription)}';
      if (prescription.stock <= 3) {
        bodyText += ' ⚠️';
      }
    }

    // CORREÇÃO: Ajusta horários que já passaram para agora + alguns segundos
    DateTime adjustTimeIfPast(DateTime original) {
      return original.isBefore(now) ? now.add(const Duration(seconds: 5)) : original;
    }

    // 1. Lembrete Antecipado
    if (prescription.notifyMinutesBefore != null && prescription.notifyMinutesBefore! > 0) {
      final reminderTime = DateTime(
        dose.scheduledTime.year,
        dose.scheduledTime.month,
        dose.scheduledTime.day,
        dose.scheduledTime.hour,
        dose.scheduledTime.minute - prescription.notifyMinutesBefore!,
        0, 0
      );
      
      await _scheduleSingleNotification(
        id: _generateNotificationId(dose.id, 1),
        title: '⏰ ${prescription.name} - Lembrete em ${prescription.notifyMinutesBefore} min',
        body: bodyText,
        scheduledTime: adjustTimeIfPast(reminderTime),
        prescriptionId: prescription.id,
        doseId: dose.id,
      );
    }

    // 2. Lembrete Pontual
    if (prescription.notifyOnTime) {
      final exactTime = DateTime(
        dose.scheduledTime.year,
        dose.scheduledTime.month,
        dose.scheduledTime.day,
        dose.scheduledTime.hour,
        dose.scheduledTime.minute,
        0, 0
      );
      
      await _scheduleSingleNotification(
        id: _generateNotificationId(dose.id, 2),
        title: '💊 ${prescription.name} - Tome agora: ${prescription.doseDescription}',
        body: bodyText,
        scheduledTime: adjustTimeIfPast(exactTime),
        prescriptionId: prescription.id,
        doseId: dose.id,
      );
    }

    // 3. Lembrete de Atraso
    if (prescription.notifyAfterMinutes != null && prescription.notifyAfterMinutes! > 0) {
      final lateReminderTime = DateTime(
        dose.scheduledTime.year,
        dose.scheduledTime.month,
        dose.scheduledTime.day,
        dose.scheduledTime.hour,
        dose.scheduledTime.minute + prescription.notifyAfterMinutes!,
        0, 0
      );
      
      await _scheduleSingleNotification(
        id: _generateNotificationId(dose.id, 3),
        title: '⚠️ ${prescription.name} - Dose atrasada',
        body: bodyText,
        scheduledTime: adjustTimeIfPast(lateReminderTime),
        prescriptionId: prescription.id,
        doseId: dose.id,
      );
    }
  }
}

// Método auxiliar para obter unidade do estoque
String _getStockUnit(String doseDescription) {
  final parts = doseDescription.split(' ');
  return parts.length > 1 ? parts.sublist(1).join(' ') : 'unidades';
}


  Future<void> _scheduleSingleNotification({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledTime,
  required int prescriptionId,
  required int doseId,
}) async {
  try {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);

    await notificationService.scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledTime,
      payload: 'PRESCRIPTION_ID:$prescriptionId:DOSE_ID:$doseId:TIME:${scheduledTime.millisecondsSinceEpoch}',
    );

  } catch (e) {
    /*if (kDebugMode) {
      print('   ❌ Erro ao agendar notificação $id: $e');
    }*/
  }
}

// Gera ID único para notificação
  int _generateNotificationId(int doseId, int notificationType) {
    return 10000 + (doseId * 10) + notificationType;
  }

// ADICIONE ESTE MÉTODO AUXILIAR NO FINAL DA CLASSE (antes do dispose):
  bool _isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
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
