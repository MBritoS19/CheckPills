// lib/presentation/providers/settings_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:drift/drift.dart' hide Column;

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
    await database.settingsDao.updateSettings(newSettings);
  }
}
