// lib/core/utils/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Padrão Singleton para garantir uma única instância deste serviço
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Configurações de inicialização para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configurações de inicialização para iOS/macOS
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // Inicializa o plugin
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Métodos que serão implementados nas próximas fases
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Lógica futura aqui
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotificationsForPrescription(int prescriptionId) async {
    // Lógica futura aqui
  }
}