import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:CheckPills/core/utils/notification_service.dart';

class NotificationChecker {
  final AppDatabase database;
  final NotificationService notificationService;
  Timer? _checkTimer;
  final Duration _checkInterval = const Duration(minutes: 1); // Verifica a cada 1 minuto

  NotificationChecker({required this.database, required this.notificationService});

  // Inicia a verificação periódica
  void startPeriodicChecking() {
    if (_checkTimer != null) {
      _checkTimer!.cancel();
    }

    _checkTimer = Timer.periodic(_checkInterval, (timer) {
      _checkForDueMedications();
    });

    if (kDebugMode) {
      print('🔄 Iniciada verificação periódica de medicamentos');
    }
  }

  // Para a verificação
  void stopPeriodicChecking() {
    _checkTimer?.cancel();
    _checkTimer = null;
    
    if (kDebugMode) {
      print('🛑 Parada verificação periódica de medicamentos');
    }
  }

  // Verifica se há medicamentos no horário atual
  Future<void> _checkForDueMedications() async {
    try {
      final now = DateTime.now();
      // Margem de 1 minuto para compensar pequenas diferenças de tempo
      final startTime = now.subtract(const Duration(minutes: 1));
      final endTime = now.add(const Duration(minutes: 1));

      if (kDebugMode) {
        print('⏰ Verificando medicamentos no horário: $now');
      }

      // Busca todas as prescrições ativas
      final prescriptions = await database.prescriptionsDao.watchAllPrescriptions().first;
      int notificationsSent = 0;

      for (final prescription in prescriptions) {
        if (prescription.enableNotifications) {
          final dueDoses = await _getDueDoses(prescription.id, startTime, endTime);
          
          for (final dose in dueDoses) {
            // Verifica se já notificou esta dose recentemente
            if (!_hasNotifiedRecently(dose.id)) {
              await _sendDueNotification(dose, prescription);
              _markAsNotified(dose.id);
              notificationsSent++;
            }
          }
        }
      }

      if (kDebugMode && notificationsSent > 0) {
        print('✅ Enviadas $notificationsSent notificações de medicamentos no horário');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao verificar medicamentos: $e');
      }
    }
  }

  // Busca doses que estão no horário atual
  Future<List<DoseEvent>> _getDueDoses(int prescriptionId, DateTime startTime, DateTime endTime) async {
    try {
      final allDoseEvents = await database.doseEventsDao.watchAllDoseEvents(0).first;
      
      return allDoseEvents
          .where((doseWithPrescription) => 
              doseWithPrescription.doseEvent.prescriptionId == prescriptionId &&
              doseWithPrescription.doseEvent.scheduledTime.isAfter(startTime) &&
              doseWithPrescription.doseEvent.scheduledTime.isBefore(endTime) &&
              doseWithPrescription.doseEvent.status == DoseStatus.pendente)
          .map((doseWithPrescription) => doseWithPrescription.doseEvent)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao buscar doses: $e');
      }
      return [];
    }
  }

  // Envia notificação para dose no horário
  Future<void> _sendDueNotification(DoseEvent dose, Prescription prescription) async {
    try {
      await notificationService.showNotificationNow(
        id: _generateDueNotificationId(dose.id),
        title: '💊 Hora do ${prescription.name}',
        body: 'Está na hora de tomar ${prescription.doseDescription}',
        payload: 'DOSE_DUE:${dose.id}:${prescription.id}',
      );

    } catch (e) {
      /*if (kDebugMode) {
        print('❌ Erro ao enviar notificação para ${prescription.name}: $e');
      }*/
    }
  }

  // Gera ID único para notificação de dose no horário
  int _generateDueNotificationId(int doseId) {
    return 1000000 + doseId; // IDs altos para evitar conflitos
  }

  // Cache simples para evitar notificações duplicadas
  final Set<int> _notifiedDoses = <int>{};
  
  bool _hasNotifiedRecently(int doseId) {
    return _notifiedDoses.contains(doseId);
  }

  void _markAsNotified(int doseId) {
    _notifiedDoses.add(doseId);
    
    // Limpa o cache após 2 horas para evitar crescimento infinito
    Future.delayed(const Duration(hours: 2), () {
      _notifiedDoses.remove(doseId);
    });
  }

  // Verificação manual (útil quando o app é aberto)
  Future<void> checkNow() async {
    if (kDebugMode) {
      print('🔍 Verificação manual de medicamentos no horário');
    }
    await _checkForDueMedications();
  }

  // Limpa o cache de notificações
  void clearNotificationCache() {
    _notifiedDoses.clear();
    if (kDebugMode) {
      print('🧹 Cache de notificações limpo');
    }
  }
}
