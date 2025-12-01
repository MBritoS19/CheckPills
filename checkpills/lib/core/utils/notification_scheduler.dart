import 'package:flutter/foundation.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:CheckPills/core/utils/notification_service.dart';

class NotificationScheduler {
  final AppDatabase database;
  final NotificationService notificationService;

  NotificationScheduler({required this.database, required this.notificationService});

  // Agenda notificações apenas para as próximas 2 horas
  Future<void> scheduleNearbyNotifications() async {
    try {
      final now = DateTime.now();
      final next2Hours = now.add(const Duration(hours: 2));

      if (kDebugMode) {
        print('📅 Buscando doses das próximas 2 horas...');
        print('⏰ Agora: $now');
        print('⏳ Até: $next2Hours');
      }

      // Busca todas as prescrições ativas
      final prescriptions = await database.prescriptionsDao.watchAllPrescriptions().first;

      int scheduledCount = 0;
      final Set<int> scheduledDoseIds = <int>{};

      for (final prescription in prescriptions) {
        if (prescription.enableNotifications) {
          final doses = await _getUpcomingDoses(prescription.id, now, next2Hours);
          
          for (final dose in doses) {
            // Evita agendar múltiplas notificações para a mesma dose
            if (!scheduledDoseIds.contains(dose.id)) {
              await _scheduleAllNotificationsForDose(dose, prescription);
              scheduledDoseIds.add(dose.id);
              scheduledCount++;
            }
          }
        }
      }

      if (kDebugMode) {
        print('✅ Agendadas notificações para $scheduledCount doses');
        print('📊 Doses únicas agendadas: ${scheduledDoseIds.length}');
        
        // Mostra estatísticas
        final pending = await notificationService.getPendingNotifications();
        print('🔔 Total de notificações pendentes: ${pending.length}');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao agendar notificações: $e');
      }
    }
  }

  // Busca doses que acontecerão nas próximas 2 horas
  Future<List<DoseEvent>> _getUpcomingDoses(int prescriptionId, DateTime start, DateTime end) async {
    try {
      final allDoseEvents = await database.doseEventsDao.watchAllDoseEvents(0).first;
      
      final upcomingDoses = allDoseEvents
          .where((doseWithPrescription) => 
              doseWithPrescription.doseEvent.prescriptionId == prescriptionId &&
              doseWithPrescription.doseEvent.scheduledTime.isAfter(start) &&
              doseWithPrescription.doseEvent.scheduledTime.isBefore(end) &&
              doseWithPrescription.doseEvent.status == DoseStatus.pendente)
          .map((doseWithPrescription) => doseWithPrescription.doseEvent)
          .toList();

      if (kDebugMode && upcomingDoses.isNotEmpty) {
        print('💊 Encontradas ${upcomingDoses.length} doses para prescrição $prescriptionId');
        for (final dose in upcomingDoses) {
          print('   - ${dose.scheduledTime}');
        }
      }

      return upcomingDoses;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao buscar doses: $e');
      }
      return [];
    }
  }

  // Agenda TODAS as notificações para uma dose específica - ESTOQUE APENAS QUANDO ATIVO
Future<void> _scheduleAllNotificationsForDose(DoseEvent dose, Prescription prescription) async {
  final now = DateTime.now();

  // Prepara o texto do corpo
  String bodyText = '';
  
  // Adiciona observações se houver
  if (prescription.notes?.isNotEmpty == true) {
    bodyText += '📝 ${prescription.notes}';
  }
  
  // Adiciona informação de estoque apenas se o controle estiver ATIVO
  if (prescription.stock != -1) {
    if (bodyText.isNotEmpty) bodyText += '\n';
    bodyText += '📦 Estoque: ${prescription.stock} ${_getStockUnit(prescription.doseDescription)}';
    
    if (prescription.stock <= 3) {
      bodyText += ' ⚠️';
    }
  }

  // 1. Lembrete Antecipado (se configurado e dentro das próximas 2 horas)
  if (prescription.notifyMinutesBefore != null && prescription.notifyMinutesBefore! > 0) {
    final reminderTime = dose.scheduledTime.subtract(Duration(minutes: prescription.notifyMinutesBefore!));
    
    // Só agenda se estiver dentro das próximas 2 horas
    final twoHoursFromNow = now.add(const Duration(hours: 2));
    if (reminderTime.isAfter(now) && reminderTime.isBefore(twoHoursFromNow)) {
      await _scheduleSingleNotification(
        id: _generateNotificationId(dose.id, 1),
        title: '⏰ ${prescription.name} - Lembrete em ${prescription.notifyMinutesBefore} min',
        body: bodyText,
        scheduledTime: reminderTime,
        prescriptionId: prescription.id,
        doseId: dose.id,
      );
    }
  }

  // 2. Lembrete Pontual (NO HORÁRIO EXATO) - SEMPRE dentro das próximas 2 horas
  if (prescription.notifyOnTime && dose.scheduledTime.isAfter(now)) {
    await _scheduleSingleNotification(
      id: _generateNotificationId(dose.id, 2),
      title: '💊 ${prescription.name} - Tome agora: ${prescription.doseDescription}',
      body: bodyText,
      scheduledTime: dose.scheduledTime,
      prescriptionId: prescription.id,
      doseId: dose.id,
    );
  }

  // 3. Lembrete de Atraso (se configurado e dentro das próximas 2 horas)
  if (prescription.notifyAfterMinutes != null && prescription.notifyAfterMinutes! > 0) {
    final lateReminderTime = dose.scheduledTime.add(Duration(minutes: prescription.notifyAfterMinutes!));
    final twoHoursFromNow = now.add(const Duration(hours: 2));
    if (lateReminderTime.isAfter(now) && lateReminderTime.isBefore(twoHoursFromNow)) {
      await _scheduleSingleNotification(
        id: _generateNotificationId(dose.id, 3),
        title: '⚠️ ${prescription.name} - Dose atrasada',
        body: bodyText,
        scheduledTime: lateReminderTime,
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

  // Agenda uma notificação individual
  Future<void> _scheduleSingleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required int prescriptionId,
    required int doseId,
  }) async {
    try {
      await notificationService.scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTime,
        payload: 'PRESCRIPTION_ID:$prescriptionId:DOSE_ID:$doseId:TIME:${scheduledTime.millisecondsSinceEpoch}',
      );

      if (kDebugMode) {
        final difference = scheduledTime.difference(DateTime.now());
        final minutes = difference.inMinutes;
        final seconds = difference.inSeconds % 60;
      }
    } catch (e) {
      /*if (kDebugMode) {
        print('   ❌ Erro ao agendar notificação $id: $e');
      }*/
    }
  }

  // Gera ID único para notificação
  int _generateNotificationId(int doseId, int notificationType) {
    // Usa faixa de IDs específica para evitar conflitos
    return 10000 + (doseId * 10) + notificationType;
  }

  // Agenda notificações para um medicamento específico (apenas próximas 2 horas)
  Future<void> scheduleNotificationsForPrescription(int prescriptionId) async {
    try {
      final prescription = await database.prescriptionsDao.getPrescriptionById(prescriptionId);
      
      if (prescription.enableNotifications) {
        final now = DateTime.now();
        final next2Hours = now.add(const Duration(hours: 2));
        final doses = await _getUpcomingDoses(prescriptionId, now, next2Hours);
        
        for (final dose in doses) {
          await _scheduleAllNotificationsForDose(dose, prescription);
        }

        if (kDebugMode) {
          print('✅ Notificações agendadas para ${prescription.name} (próximas 2h)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao agendar notificações para prescrição $prescriptionId: $e');
      }
    }
  }

  // Cancela todas as notificações de uma prescrição
  Future<void> cancelPrescriptionNotifications(int prescriptionId) async {
    try {
      final pending = await notificationService.getPendingNotifications();
      int cancelledCount = 0;

      for (final notification in pending) {
        if (notification.payload?.contains('PRESCRIPTION_ID:$prescriptionId') == true) {
          await notificationService.cancelNotification(notification.id);
          cancelledCount++;
        }
      }

      if (kDebugMode) {
        print('🗑️ Canceladas $cancelledCount notificações da prescrição $prescriptionId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao cancelar notificações da prescrição $prescriptionId: $e');
      }
    }
  }

  // Atualiza todas as notificações (limpa e recria apenas próximas 2 horas)
  Future<void> refreshAllNotifications() async {
    if (kDebugMode) {
      print('🔄 Atualizando notificações (próximas 2 horas)...');
    }
    
    // Primeiro cancela todas as notificações existentes
    final pending = await notificationService.getPendingNotifications();
    for (final notification in pending) {
      await notificationService.cancelNotification(notification.id);
    }
    
    // Depois agenda novas notificações (apenas próximas 2 horas)
    await scheduleNearbyNotifications();
  }

  // Verifica e reage notificações se necessário (para quando o app é reaberto)
  Future<void> checkAndRescheduleIfNeeded() async {
    try {
      final pending = await notificationService.getPendingNotifications();
      
      if (pending.isEmpty) {
        await scheduleNearbyNotifications();
      } else {
        if (kDebugMode) {
          print('🔔 ${pending.length} notificações já agendadas');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao verificar notificações: $e');
      }
    }
  }
}
