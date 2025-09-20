// lib/presentation/providers/settings_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:CheckPills/data/datasources/database.dart';

class SettingsProvider with ChangeNotifier {
  final AppDatabase database;
  StreamSubscription? _settingsSubscription;

  Setting _settings = Setting(
    id: 1,
    userName: null,
    standardPillType: null,
    darkMode: false,
    refillReminder: 5,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Setting get settings => _settings;

  SettingsProvider({required this.database}) {
    _listenToSettings();
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    super.dispose();
  }

  void _listenToSettings() {
    _settingsSubscription?.cancel();
    _settingsSubscription =
        database.settingsDao.watchSettings().listen((settings) {
      if (settings != null) {
        _settings = settings;
        notifyListeners();
      }
    });
  }

  Future<void> updateSettings(SettingsCompanion newSettings) async {
    // 1. Manda o banco de dados se atualizar em segundo plano.
    // Removemos o 'await' para não esperar aqui.
    database.settingsDao.updateSettings(newSettings);

    // 2. Atualiza o estado local do provider IMEDIATAMENTE.
    // Usamos o método copyWith para criar um novo objeto 'Setting'
    // com os valores que acabaram de ser alterados.
    _settings = _settings.copyWith(
      userName: newSettings.userName,
      standardPillType: newSettings.standardPillType,
      darkMode: newSettings.darkMode.present
          ? newSettings.darkMode.value
          : _settings.darkMode,
      refillReminder: newSettings.refillReminder.present
          ? newSettings.refillReminder.value
          : _settings.refillReminder,
      updatedAt: newSettings.updatedAt.present
          ? newSettings.updatedAt.value
          : DateTime.now(),
    );

    // 3. Notifica a UI sobre a mudança instantaneamente.
    notifyListeners();
  }
}
