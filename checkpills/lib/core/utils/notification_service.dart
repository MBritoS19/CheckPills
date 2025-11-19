import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Serviço Singleton para notificações locais.
class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'dose_reminders_channel';
  static const String channelName = 'Lembretes de Dose';
  static const String channelDescription =
      'Notificações para lembrar de tomar medicamentos.';

  bool _initialized = false;
  bool get initialized => _initialized;

  /// Inicializa o plugin, registra canais e handlers.
  Future<void> init() async {
    if (_initialized) return;

    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS / macOS initialization (Darwin)
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false, // vamos pedir manualmente
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Windows initialization - 'guid' pode ser exigido em algumas versões.
    const WindowsInitializationSettings initializationSettingsWindows =
        WindowsInitializationSettings(
      appName: 'CheckPills',
      appUserModelId: 'com.example.checkpills',
      guid: 'e1b80596-c677-4547-ae50-f26399f41e1f',
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      windows: initializationSettingsWindows,
    );

    // Inicializa e registra os callbacks
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked/payload: ${response.payload}');
        // TODO: rotear utilizando GlobalKey<NavigatorState> se precisar abrir tela.
      },
      onDidReceiveBackgroundNotificationResponse:
          notificationTapBackgroundHandler,
    );

    // Cria o canal Android (deve existir antes do agendamento)
    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final channel = const AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
      );
      await androidPlugin.createNotificationChannel(channel);
      debugPrint('✅ Android channel criado: $channelId');
    }

    _initialized = true;
    debugPrint('NotificationService initialized');
  }

  /// Handler background (top-level / static)
  static void notificationTapBackgroundHandler(NotificationResponse response) {
    debugPrint(
        'notificationTapBackgroundHandler invoked. payload: ${response.payload}');
  }

  /// Configura o timezone local usando flutter_timezone corretamente.
  /// Deve ser chamado **após** init() e **antes** de agendar notificações.
  Future<void> configureLocalTimezone() async {
    try {
      tz.initializeTimeZones();
      final dynamic tzResult = await FlutterTimezone.getLocalTimezone();
      String timeZoneName;

      // Compatibilidade: flutter_timezone pode retornar String ou um objeto
      if (tzResult is String) {
        timeZoneName = tzResult;
      } else if (tzResult != null) {
        try {
          timeZoneName =
              (tzResult as dynamic).identifier ?? (tzResult as dynamic).name;
        } catch (_) {
          timeZoneName = 'Etc/UTC';
        }
      } else {
        timeZoneName = 'Etc/UTC';
      }

      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint('🕒 Timezone configurado: $timeZoneName');
      } catch (e) {
        debugPrint('⚠️ Timezone $timeZoneName não mapeado: $e');
        tz.setLocalLocation(tz.getLocation('Etc/UTC'));
        debugPrint('🕒 Fallback para Etc/UTC aplicado');
      }
    } catch (e) {
      debugPrint('⚠️ Could not configure timezone: $e');
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Etc/UTC'));
    }
  }

  /// Solicita permissões de notificação (Android 13+, iOS)
  /// Retorna true se tem permissão (ou aparentemente tem).
  Future<bool> requestPermissions() async {
    bool granted = true;

    // Android
    try {
      final androidImpl =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final bool? androidResult =
          await androidImpl?.requestNotificationsPermission();
      debugPrint('Android permission request result: $androidResult');
      if (androidResult == false) granted = false;
    } catch (e) {
      debugPrint('Android permission request not available: $e');
    }

    // iOS / macOS
    try {
      final iosImpl =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final bool? iosResult = await iosImpl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('iOS permission request result: $iosResult');
      if (iosResult == false) granted = false;
    } catch (e) {
      debugPrint('iOS permission request error: $e');
    }

    debugPrint('Permissions overall granted: $granted');
    return granted;
  }

  /// Mostra uma notificação imediata (útil para testes)
  Future<void> showNotificationNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
    debugPrint('🔔 Notificação imediata mostrada: id=$id payload=$payload');
  }

  /// Agendamento de notificação (pontual) com timezone (zonedSchedule).
  /// scheduledDate deve ser DateTime local.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized) {
      debugPrint('⚠️ NotificationService not initialized. Calling init() now.');
      await init();
    }

    try {
      final tz.TZDateTime tzScheduled =
          tz.TZDateTime.from(scheduledDate, tz.local);

      //debugPrint('Agendando notificação id=$id para $tzScheduled (local tz)');

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      //debugPrint('✅ Notificação agendada: id=$id payload=$payload');
    } catch (e, st) {
      debugPrint('❌ Falha ao agendar notificação: $e\n$st');
      rethrow;
    }
  }

  /// Cancela notificação por id
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    debugPrint('Notificação cancelada: id=$id');
  }

  /// Cancela todas as notificações que contenham payload 'PRESCRIPTION_ID:xxx'
  Future<void> cancelAllNotificationsForPrescription(int prescriptionId) async {
    final pending = await _notificationsPlugin.pendingNotificationRequests();
    for (final n in pending) {
      if (n.payload != null && n.payload == 'PRESCRIPTION_ID:$prescriptionId') {
        await _notificationsPlugin.cancel(n.id);
        debugPrint(
            'Canceled notification ${n.id} for prescription $prescriptionId');
      }
    }
  }

  /// Lista notificações pendentes (útil para debug)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}
