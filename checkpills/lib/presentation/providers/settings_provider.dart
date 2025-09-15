// lib/presentation/providers/settings_provider.dart

import 'package:CheckPills/data/datasources/database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  final AppDatabase database;
  Setting? _currentSettings;

  SettingsProvider({required this.database}) {
    _loadSettings();
  }

  Setting? get currentSettings => _currentSettings;

  Future<void> _loadSettings() async {
    try {
      _currentSettings = await database.settingsDao.getSettings();
      notifyListeners();
    } catch (e) {
      // Se não houver configurações, cria a primeira.
      if (_currentSettings == null) {
        await database.settingsDao.updateSettings(
          const SettingsCompanion(
            userName: Value(''),
            standardPillType: Value(''),
            darkMode: Value(false),
            refillReminder: Value(5),
          ),
        );
        _currentSettings = await database.settingsDao.getSettings();
      }
      notifyListeners();
    }
  }

  Future<void> updateUserName(String? name) async {
    await database.settingsDao.updateSettings(
      SettingsCompanion(
        userName: Value(name),
      ),
    );
    _currentSettings = _currentSettings!.copyWith(userName: Value(name));
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool isDarkMode) async {
    await database.settingsDao.updateSettings(
      SettingsCompanion(
        darkMode: Value(isDarkMode),
      ),
    );
    _currentSettings = _currentSettings!.copyWith(darkMode: isDarkMode);
    notifyListeners();
  }

  Future<void> updateRefillReminder(int days) async {
    await database.settingsDao.updateSettings(
      SettingsCompanion(
        refillReminder: Value(days),
      ),
    );
    _currentSettings = _currentSettings!.copyWith(refillReminder: days);
    notifyListeners();
  }
}
