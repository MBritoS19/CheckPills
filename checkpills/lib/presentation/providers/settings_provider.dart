// lib/presentation/providers/settings_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:drift/drift.dart' hide Column;

class SettingsProvider with ChangeNotifier {
  final AppDatabase database;

  // O estado é uma variável simples, como no início.
  Setting _settings;

  Setting get settings => _settings;

  // O construtor recebe o estado inicial carregado do banco de dados.
  SettingsProvider({required this.database, Setting? initialSettings})
      : _settings = initialSettings ??
            Setting(
              id: 1,
              darkMode: false,
              refillReminder: 5,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

  // O método de atualização otimista permanece o mesmo da sua versão.
  Future<void> updateSettings(SettingsCompanion newSettings) async {
    final newDarkMode = newSettings.darkMode.present
        ? newSettings.darkMode.value
        : _settings.darkMode;
    final newUserName = newSettings.userName.present
        ? newSettings.userName.value
        : _settings.userName;
    final newRefillReminder = newSettings.refillReminder.present
        ? newSettings.refillReminder.value
        : _settings.refillReminder;

    _settings = Setting(
      id: _settings.id,
      createdAt: _settings.createdAt,
      darkMode: newDarkMode,
      userName: newUserName,
      refillReminder: newRefillReminder,
      updatedAt: DateTime.now(),
    );

    notifyListeners();

    await database.settingsDao.updateSettings(newSettings.copyWith(id: const Value(1)));
  }
}