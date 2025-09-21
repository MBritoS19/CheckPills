import 'package:CheckPills/data/datasources/database.dart';
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

  UserProvider({required this.database}) {
    print("✅ [UserProvider] Criado. Iniciando a inicialização...");
    _initialize();

    database.usersDao.watchAllUsers().listen((users) {
      print("🔔 [UserProvider] A stream de usuários foi atualizada. Usuários encontrados: ${users.length}");
      _allUsers = users;

      if (_activeUser == null || !users.any((u) => u.id == _activeUser!.id)) {
        if (users.isNotEmpty) {
          print("👤 [UserProvider] Selecionando o primeiro usuário como ativo: ${users.first.name}");
          _selectUser(users.first);
        } else {
          print("👤 [UserProvider] Nenhum usuário ativo para selecionar.");
          _activeUser = null;
        }
      }
      notifyListeners();
    });
  }

  Future<void> _initialize() async {
    print("⏳ [UserProvider] Verificando se o primeiro usuário existe...");
    final initialUsers = await database.usersDao.getAllUsers();
    
    if (initialUsers.isEmpty) {
      print("✍️ [UserProvider] Nenhum usuário encontrado. Criando 'Perfil Principal'...");
      await addUser("Perfil Principal");
      print("✅ [UserProvider] 'Perfil Principal' criado.");
    } else {
      print("👍 [UserProvider] Usuários já existem. Pulando a criação.");
    }
    
    _isInitialized = true;
    print("🏁 [UserProvider] Inicialização concluída. Notificando a UI.");
    notifyListeners();
  }

  void _selectUser(User user) {
    if (_activeUser?.id != user.id) {
      _activeUser = user;
    }
  }

  void selectUser(User user) {
    if (_activeUser?.id != user.id) {
      _activeUser = user;
      print("🔄 [UserProvider] Usuário trocado manualmente para: ${user.name}");
      notifyListeners();
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