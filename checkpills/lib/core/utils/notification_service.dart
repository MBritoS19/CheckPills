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

  static const String channelId = 'dose_reminders_channel';
  static const String channelName = 'Lembretes de Dose';
  static const String channelDescription =
      'Notificações para lembrar de tomar medicamentos.';

  bool _initialized = false;

  /// Inicialização SIMPLES
  Future<void> init() async {
    if (_initialized) return;

    try {
      // Configuração Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

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
        importance: Importance.high,
        playSound: true, // Ativa som
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        showBadge: true,
        // NÃO definir 'sound' aqui - deixe o Android usar o som padrão do dispositivo
      );

      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(channel);
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('❌ Error creating channel: $e');
        print('Stack: $stack');
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
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final bool? androidGranted = await androidPlugin?.requestNotificationsPermission();
      
      // iOS
      final iosPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
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
      // Configuração Android SIMPLES - NÃO definir som para usar o padrão
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'dose_reminders_channel', // channelId
        'Lembretes de Dose',      // channelName
        channelDescription: 'Notificações para lembrar de tomar medicamentos.',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true, // Ativa som
        enableVibration: true,
        timeoutAfter: 30000,
        autoCancel: true,
        styleInformation: BigTextStyleInformation(body),
        // NÃO definir 'sound' - deixe o Android usar o som padrão do dispositivo
      );

      // Configuração iOS - NÃO definir som para usar o padrão
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        // NÃO definir 'sound' - deixe o iOS usar o som padrão do dispositivo
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
      final tz.TZDateTime tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);

      // Configuração Android SIMPLES - NÃO definir som para usar o padrão
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'dose_reminders_channel',
        'Lembretes de Dose',
        channelDescription: 'Notificações para lembrar de tomar medicamentos.',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true, // Ativa som
        enableVibration: true,
        timeoutAfter: 30000,
        autoCancel: true,
        styleInformation: BigTextStyleInformation(body),
        // NÃO definir 'sound' - deixe o Android usar o som padrão do dispositivo
      );

      // Configuração iOS - NÃO definir som para usar o padrão
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        // NÃO definir 'sound' - deixe o iOS usar o som padrão do dispositivo
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
        print('❌ Erro ao agendar $id: $e');
        print('Stack: $stack');
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
        if (notification.payload?.contains('PRESCRIPTION_ID:$prescriptionId') == true) {
          await _notificationsPlugin.cancel(notification.id);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erro ao cancelar notificações da prescrição $prescriptionId: $e');
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
        final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final bool? androidGranted = await androidPlugin?.areNotificationsEnabled();
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
