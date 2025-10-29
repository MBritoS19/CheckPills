import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Passo 1: Inicializa as configurações básicas do plugin de notificação.
  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const WindowsInitializationSettings initializationSettingsWindows =
        WindowsInitializationSettings(
      appName: 'CheckPills', // Nome do seu aplicativo
      appUserModelId: 'com.example.checkpills', 
      guid: 'e1b80596-c677-4547-ae50-f26399f41e1f', 
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      windows: initializationSettingsWindows,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  /// Passo 2: Configura o fuso horário local do dispositivo.
  Future<void> configureLocalTimezone() async {
    tz.initializeTimeZones();
    String timeZoneName;
    try {
      // Obtém o fuso horário do dispositivo.
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      timeZoneName = tzInfo.localizedName?.name ?? tzInfo.identifier;
    } catch (e) {
      // Se falhar, registra o erro e usa UTC como fallback seguro.
      debugPrint('Could not get timezone: $e');
      timeZoneName = 'Etc/UTC';
    }
    // Define a localização para a biblioteca 'timezone'.
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  // O método de permissões permanece o mesmo.
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

  // O método de agendamento foi mantido, pois já está correto e
  // depende da configuração externa do fuso horário.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
          scheduledDate, tz.local), // Usa o fuso horário configurado
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'dose_reminders_channel',
          'Lembretes de Dose',
          channelDescription:
              'Notificações para lembrar de tomar medicamentos.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  // Os métodos de cancelamento permanecem os mesmos.
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotificationsForPrescription(int prescriptionId) async {
    final pendingNotifications =
        await _notificationsPlugin.pendingNotificationRequests();
    for (var notification in pendingNotifications) {
      if (notification.payload == 'PRESCRIPTION_ID:$prescriptionId') {
        await _notificationsPlugin.cancel(notification.id);
      }
    }
  }
}
