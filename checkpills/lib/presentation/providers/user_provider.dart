// SUBSTITUA O CONTEÚDO INTEIRO do user_provider.dart

import 'dart:async'; // Importação necessária para o Completer
import 'package:CheckPills/data/datasources/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart';

class UserProvider with ChangeNotifier {
  final AppDatabase database;

  // Variáveis de estado
  User? _activeUser;
  List<User> _allUsers = [];
  bool _isInitialized = false;

  // Completer para sinalizar o fim da inicialização
  final Completer<void> _initializationCompleter = Completer<void>();
  bool _isFirstUserLoad = true;

  // Getters públicos
  User? get activeUser => _activeUser;
  List<User> get allUsers => _allUsers;
  bool get isInitialized => _isInitialized;
  Future<void> get initializationDone => _initializationCompleter.future;

  UserProvider({required this.database}) {
    print("✅ [UserProvider] Criado. Aguardando inicialização controlada.");
    _listenToUserChanges();
  }

  void _listenToUserChanges() {
    database.usersDao.watchAllUsers().listen((users) async {
      print(
          "🔔 [UserProvider] Stream de usuários atualizada. Usuários: ${users.length}");
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
        print("🏁 [UserProvider] Inicialização concluída e sinalizada.");
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
      print("💾 [UserProvider] ID ${user.id} salvo como último perfil ativo.");
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
}
