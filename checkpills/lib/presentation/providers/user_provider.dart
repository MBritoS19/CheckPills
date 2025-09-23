import 'package:CheckPills/data/datasources/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart';

class UserProvider with ChangeNotifier {
  final AppDatabase database;

  User? _activeUser;
  List<User> _allUsers = [];
  bool _isInitialized = false;

  User? get activeUser => _activeUser;
  List<User> get allUsers => _allUsers;
  bool get isInitialized => _isInitialized;
  
  int? _lastActiveUserId; // Nova variável para guardar o ID carregado

  UserProvider({required this.database}) {
    print("✅ [UserProvider] Criado. Iniciando a inicialização...");
    _initialize();

    database.usersDao.watchAllUsers().listen((users) {
      print(
          "🔔 [UserProvider] A stream de usuários foi atualizada. Usuários encontrados: ${users.length}");
      _allUsers = users;

      if (_activeUser == null || !users.any((u) => u.id == _activeUser!.id)) {
        User? userToSelect;
        if (users.isNotEmpty) {
          // Tenta encontrar o usuário pelo ID salvo
          if (_lastActiveUserId != null) {
            userToSelect = users.firstWhere((u) => u.id == _lastActiveUserId,
                orElse: () => users.first);
          } else {
            // Se não houver ID salvo, seleciona o primeiro da lista
            userToSelect = users.first;
          }
          print(
              "👤 [UserProvider] Selecionando usuário ativo: ${userToSelect.name}");
          _selectUser(userToSelect);
        } else {
          _activeUser = null;
        }
      }
      notifyListeners();
    });
  }

  Future<void> _initialize() async {
    print("⏳ [UserProvider] Carregando último ID de perfil ativo...");
    final prefs = await SharedPreferences.getInstance();
    _lastActiveUserId = prefs.getInt('last_active_user_id');
    print("💾 [UserProvider] ID carregado: $_lastActiveUserId");

    final initialUsers = await database.usersDao.getAllUsers();
    if (initialUsers.isEmpty) {
      print(
          "✍️ [UserProvider] Nenhum usuário encontrado. Criando 'Perfil Principal'...");
      await addUser("Perfil Principal");
    } else {
      print("👍 [UserProvider] Usuários já existem.");
    }

    _isInitialized = true;
    print("🏁 [UserProvider] Inicialização concluída.");
    notifyListeners();
  }

  void _selectUser(User user) {
    if (_activeUser?.id != user.id) {
      _activeUser = user;
    }
  }

  Future<void> selectUser(User user) async {
    if (_activeUser?.id != user.id) {
      _activeUser = user;
      print("🔄 [UserProvider] Usuário trocado manualmente para: ${user.name}");
      notifyListeners();

      // Salva o ID do novo perfil ativo
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
      darkMode: const Value(false),
      refillReminder: const Value(5),
    );
    await database.userSettingsDao.updateSettingsForUser(defaultSettings);
  }

  Future<void> deleteUser(int userId) async {
    await database.usersDao.deleteUser(userId);
  }

  Future<void> updateUser(UsersCompanion updatedUser) async {
    await database.usersDao.updateUser(updatedUser);
  }
}
