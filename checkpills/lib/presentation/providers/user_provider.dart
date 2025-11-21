// SUBSTITUA O CONTEÚDO INTEIRO do user_provider.dart

import 'dart:async'; // Importação necessária para o Completer
import 'package:CheckPills/data/datasources/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class UserProvider with ChangeNotifier {
  final AppDatabase database;

  // Variáveis de estado
  User? _activeUser;
  List<User> _allUsers = [];
  bool _isInitialized = false;

  // Completer para sinalizar o fim da inicialização
  Completer<void> _initializationCompleter = Completer<void>();
  bool _isFirstUserLoad = true;

  final List<VoidCallback> _resetListeners = [];

  // Getters públicos
  User? get activeUser => _activeUser;
  List<User> get allUsers => _allUsers;
  bool get isInitialized => _isInitialized;
  Future<void> get initializationDone => _initializationCompleter.future;

  UserProvider({required this.database}) {
    _listenToUserChanges();
  }

  void _listenToUserChanges() {
    database.usersDao.watchAllUsers().listen((users) async {
      _allUsers = users;

      User? userToSelect;
      if (users.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final lastActiveUserId = prefs.getInt('last_active_user_id');

        if (lastActiveUserId != null) {
          userToSelect = users.firstWhere((u) => u.id == lastActiveUserId,
              orElse: () => users.first);
        } else {
          userToSelect = users.first;
        }
      }

      _activeUser = userToSelect;

      // Se for o primeiro carregamento de dados, sinaliza que a inicialização terminou.
      if (_isFirstUserLoad) {
        _isInitialized = true;
        _isFirstUserLoad = false;
        _initializationCompleter.complete();
      }

      notifyListeners();
    });
  }

  Future<void> selectUser(User user) async {
    if (_activeUser?.id != user.id) {
      _activeUser = user;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_active_user_id', user.id);
    }
  }

  Future<void> addUser(String name) async {
    final newUserCompanion = UsersCompanion.insert(name: name);
    final newId = await database.usersDao.addUser(newUserCompanion);

    final defaultSettings = UserSettingsCompanion.insert(
      userId: Value(newId),
      themeMode: const Value(0),
      refillReminder: const Value(5),
    );
    await database.userSettingsDao.updateSettingsForUser(defaultSettings);
  }

  Future<void> deleteUser(int userId) async {
    await database.usersDao.deleteUser(userId);
  }

  Future<void> updateUser(UsersCompanion updatedUser) async {
    await database.usersDao.updateUser(updatedUser);

    if (updatedUser.id.present && _activeUser?.id == updatedUser.id.value) {
      if (updatedUser.name.present) {
        _activeUser = _activeUser?.copyWith(name: updatedUser.name.value);
      }
    }
    notifyListeners();
  }

  Future<void> resetApp() async {
    try {

      // 1. Cancela todas as notificações
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin.cancelAll();

      // 2. Limpa o banco de dados
      await database.resetDatabase();

      // 3. Limpa o SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

    } catch (e) {
      ////debugPrint('Erro ao resetar app: $e');
      rethrow;
    }
  }

  Future<void> _cancelAllNotificationsDirectly() async {
    try {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      ////debugPrint('Erro ao cancelar notificações: $e');
    }
  }
}
