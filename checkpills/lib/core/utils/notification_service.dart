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

  static const String channelId = 'dose_reminders_channel_v3';
  static const String channelName = 'Lembretes de Dose';
  static final Int64List vibrationPattern =
      Int64List.fromList([0, 1000, 500, 1000]);
  static const String channelDescription =
      'Notificações para lembrar de tomar medicamentos.';

  bool _initialized = false;

  /// Inicialização SIMPLES
  Future<void> init() async {
    if (_initialized) return;

    try {
      // Configuração Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/logo');

      // Configuração iOS
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
      );

      await _notificationsPlugin.initialize(initializationSettings);

      // Criar canal Android - VERSÃO SIMPLES
      await _createSimpleChannel();

      _initialized = true;
      if (kDebugMode) {
        print('✅ NotificationService initialized successfully');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('❌ Error initializing NotificationService: $e');
        print('Stack: $stack');
      }
    }
  }

  /// Canal SIMPLES - REMOVER configuração de som para usar o padrão do sistema
  Future<void> _createSimpleChannel() async {
    try {
      final AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: vibrationPattern,
        sound: const RawResourceAndroidNotificationSound('notification'),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        showBadge: true,
      );

      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(channel);

        // Opcional: Tentar deletar o canal antigo para não sujar as config do usuário
        try {
          await androidPlugin
              .deleteNotificationChannel('dose_reminders_channel');
          await androidPlugin
              .deleteNotificationChannel('dose_reminders_channel_v2');
        } catch (_) {}

        if (kDebugMode) {
          print(
              '✅ Canal $channelId criado com AudioAttributesUsage.alarm e vibração');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating channel: $e');
      }
    }
  }

  /// Configura timezone
  Future<void> configureLocalTimezone() async {
    try {
      tz.initializeTimeZones();
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timezoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      if (kDebugMode) {
        print('🕒 Timezone: $timeZoneName');
      }
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Etc/UTC'));
    }
  }

  /// Solicita permissões - MÉTODO ADICIONADO
  Future<bool> requestPermissions() async {
    try {
      // Android 13+
      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final bool? androidGranted =
          await androidPlugin?.requestNotificationsPermission();

      // iOS
      final iosPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final bool? iosGranted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      final bool granted = androidGranted ?? iosGranted ?? false;
      if (kDebugMode) {
        print('🔔 Permissions granted: $granted');
      }
      return granted;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error requesting permissions: $e');
      }
      return false;
    }
  }

  /// Notificação imediata - VERSÃO SIMPLES
  Future<void> showNotificationNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await init();

    try {
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'dose_reminders_channel_v3',
        'Lembretes de Dose',
        channelDescription: 'Notificações para lembrar de tomar medicamentos.',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: vibrationPattern, // GARANTIR O USO DO PADRÃO
        category: AndroidNotificationCategory.alarm,
        timeoutAfter: null,
        autoCancel: true,
        ongoing: true,
        channelShowBadge: true,
        styleInformation: BigTextStyleInformation(body),
        ledOnMs: 1000,
        ledOffMs: 500,
        visibility: NotificationVisibility.public,
        icon: '@drawable/logo',
        // IMPORTANTE: Usar o padrão de áudio correto para alarmes
        sound: const RawResourceAndroidNotificationSound('notification'),
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
        sound: 'notification.wav', // Para iOS
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
          macOS: iosDetails,
        ),
        payload: payload,
      );
    } catch (e, stack) {
      if (kDebugMode) {
        print('❌ Erro na notificação $id: $e');
        print('Stack: $stack');
      }
    }
  }

  /// Agendamento de notificação
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized) await init();

    try {
      final tz.TZDateTime tzScheduled =
          tz.TZDateTime.from(scheduledDate, tz.local);

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'dose_reminders_channel_v3',
        'Lembretes de Dose',
        channelDescription: 'Notificações para lembrar de tomar medicamentos.',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: vibrationPattern, // GARANTIR O USO DO PADRÃO
        category: AndroidNotificationCategory.alarm,
        timeoutAfter: null,
        autoCancel: true,
        ongoing: true,
        channelShowBadge: true,
        styleInformation: BigTextStyleInformation(body),
        ledOnMs: 1000,
        ledOffMs: 500,
        visibility: NotificationVisibility.public,
        icon: '@drawable/logo',
        sound: const RawResourceAndroidNotificationSound('notification'),
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
        sound: 'notification.wav',
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduled,
        NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
          macOS: iosDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (e, stack) {
      if (kDebugMode) {
        print('❌ Erro ao agendar notificação $id: $e');
        print('Stack: $stack');
      }
    }
  }

  /// Remove notificações fixas quando o medicamento é tomado
  Future<void> dismissPersistentNotification(int doseId) async {
    try {
      // Cancela a notificação principal
      await cancelNotification(doseId);

      // Também cancela possíveis notificações relacionadas
      await cancelNotification(10000 + (doseId * 10) + 1);
      await cancelNotification(10000 + (doseId * 10) + 2);
      await cancelNotification(10000 + (doseId * 10) + 3);

      if (kDebugMode) {
        print('🗑️ Notificação fixa removida para dose $doseId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erro ao remover notificação fixa: $e');
      }
    }
  }

  /// Remove todas as notificações fixas de uma prescrição
  Future<void> dismissAllPersistentNotificationsForPrescription(
      int prescriptionId) async {
    try {
      final pending = await getPendingNotifications();
      int removedCount = 0;

      for (final notification in pending) {
        if (notification.payload?.contains('PRESCRIPTION_ID:$prescriptionId') ==
            true) {
          await cancelNotification(notification.id);
          removedCount++;
        }
      }

      if (kDebugMode) {
        print(
            '🗑️ $removedCount notificações fixas removidas da prescrição $prescriptionId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Erro ao remover notificações fixas: $e');
      }
    }
  }

  /// Cancela notificação
  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao cancelar $id: $e');
      }
    }
  }

  /// Cancela todas as notificações de uma prescrição - MÉTODO ADICIONADO
  Future<void> cancelAllNotificationsForPrescription(int prescriptionId) async {
    try {
      final pending = await _notificationsPlugin.pendingNotificationRequests();

      for (final notification in pending) {
        if (notification.payload?.contains('PRESCRIPTION_ID:$prescriptionId') ==
            true) {
          await _notificationsPlugin.cancel(notification.id);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(
            '❌ Erro ao cancelar notificações da prescrição $prescriptionId: $e');
      }
    }
  }

  /// Obtém notificações pendentes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      return [];
    }
  }

  /// Debug: lista notificações pendentes - MÉTODO ADICIONADO
  Future<void> debugNotificationStatus() async {
    try {
      final pending = await getPendingNotifications();
      if (kDebugMode) {
        print('📋 Notificações pendentes: ${pending.length}');

        for (final notification in pending) {
          print('   - ID: ${notification.id}');
          print('     Title: ${notification.title}');
          print('     Body: ${notification.body}');
          print('     Payload: ${notification.payload}');
          print('     ---');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro no debug: $e');
      }
    }
  }

  /// Diagnóstico completo
  Future<void> debugNotificationSystem() async {
    if (kDebugMode) {
      print('\n🔍 ===== DIAGNÓSTICO DO SISTEMA =====');
      print('1. ✅ Inicializado: $_initialized');

      // Verificar permissões
      try {
        final androidPlugin =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final bool? androidGranted =
            await androidPlugin?.areNotificationsEnabled();
        print('2. 🔔 Notificações habilitadas: $androidGranted');
      } catch (e) {
        print('2. ❌ Erro nas permissões: $e');
      }

      // Verificar notificações pendentes
      final pending = await getPendingNotifications();
      print('3. 📋 Notificações pendentes: ${pending.length}');

      // Verificar timezone
      try {
        final now = tz.TZDateTime.now(tz.local);
        print('4. 🕒 Hora atual: $now');
      } catch (e) {
        print('4. ❌ Erro no timezone: $e');
      }

      print('🔍 ===== FIM DO DIAGNÓSTICO =====\n');
    }
  }
}
