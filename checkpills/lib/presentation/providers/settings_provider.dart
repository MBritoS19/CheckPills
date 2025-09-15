// lib/presentation/providers/settings_provider.dart

import 'package:CheckPills/data/datasources/database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  final AppDatabase database;

  SettingsProvider({required this.database}) {
    _loadSettings();
  }

  Setting? _settings;

  Setting? get settings => _settings;

  Future<void> _loadSettings() async {
    _settings = await database.settingsDao.getSettings();
    notifyListeners();
  }

  Future<void> saveUserName(String name) async {
    final settingsCompanion = SettingsCompanion(
      userName: Value(name),
      updatedAt: Value(DateTime.now()),
    );
    await database.settingsDao.saveSettings(settingsCompanion);
    await _loadSettings();
  }

  Future<void> saveRefillReminder(int days) async {
    final settingsCompanion = SettingsCompanion(
      refillReminder: Value(days),
      updatedAt: Value(DateTime.now()),
    );
    await database.settingsDao.saveSettings(settingsCompanion);
    await _loadSettings();
  }

  Future<void> toggleDarkMode(bool isEnabled) async {
    final settingsCompanion = SettingsCompanion(
      darkMode: Value(isEnabled),
      updatedAt: Value(DateTime.now()),
    );
    await database.settingsDao.saveSettings(settingsCompanion);
    await _loadSettings();
  }
}
