import 'package:CheckPills/data/datasources/database.dart';
import 'package:CheckPills/presentation/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart';

class UserSettingsProvider with ChangeNotifier {
  final AppDatabase database;
  final UserProvider userProvider;

  UserSetting? _settings;
  UserSetting? get settings => _settings;

  UserSettingsProvider({required this.database, required this.userProvider}) {
    // Ouve as mudanças no UserProvider
    userProvider.addListener(_loadSettingsForActiveUser);
    // Carrega as configurações iniciais
    _loadSettingsForActiveUser();
  }

  void _loadSettingsForActiveUser() async {
    final activeUser = userProvider.activeUser;
    if (activeUser != null) {
      // Ouve as mudanças nas configurações do usuário ativo
      database.userSettingsDao
          .watchSettingsForUser(activeUser.id)
          .listen((settings) {
        _settings = settings;
        notifyListeners();
      });
    } else {
      _settings = null;
      notifyListeners();
    }
  }

  Future<void> updateSettings(UserSettingsCompanion newSettings) async {
    final activeUser = userProvider.activeUser;
    if (activeUser == null) return;

    // Atualização otimista (opcional, mas melhora a experiência do usuário)
    if (newSettings.darkMode.present) {
      _settings = _settings?.copyWith(darkMode: newSettings.darkMode.value);
    }
    if (newSettings.refillReminder.present) {
      _settings =
          _settings?.copyWith(refillReminder: newSettings.refillReminder.value);
    }
    notifyListeners();

    // Persiste a mudança no banco, garantindo que o userId esteja correto
    await database.userSettingsDao
        .updateSettingsForUser(newSettings.copyWith(userId: Value(activeUser.id)));
  }

  @override
  void dispose() {
    userProvider.removeListener(_loadSettingsForActiveUser);
    super.dispose();
  }
}