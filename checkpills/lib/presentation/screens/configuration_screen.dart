import 'package:CheckPills/presentation/providers/user_provider.dart';
import 'package:CheckPills/presentation/providers/user_settings_provider.dart';
import 'package:CheckPills/presentation/screens/profile_management_screen.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 24.0, bottom: 8.0, left: 16.0, right: 16.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Agora pegamos os dois providers necessários
    final settingsProvider = context.watch<UserSettingsProvider>();
    final userProvider = context.watch<UserProvider>();
    
    // O nome do usuário vem do UserProvider
    final String? currentUserName = userProvider.activeUser?.name;
    // As configurações vêm do UserSettingsProvider
    final settings = settingsProvider.settings;

    // Se as configurações ainda não carregaram, mostramos um loader
    if (settings == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Configurações')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SEÇÃO DE PERFIL
            _buildSectionHeader("Perfil"),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(currentUserName ?? 'Carregando...'), // Mostra o nome do perfil ativo
              trailing: const Icon(Icons.edit_outlined),
              onTap: () {
                // Só permite editar se o usuário ativo já foi carregado
                if (userProvider.activeUser != null) {
                  _showUserNameDialog(context, userProvider);
                }
              },
            ),

            ListTile(
    leading: const Icon(Icons.switch_account_outlined),
    title: const Text('Gerenciar Perfis'),
    trailing: const Icon(Icons.arrow_forward_ios),
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ProfileManagementScreen(),
        ),
      );
    },
  ),

            // SEÇÃO DE APARÊNCIA
            _buildSectionHeader("Aparência"),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Modo Noturno'),
              value: settings.darkMode, // Usa as configurações carregadas
              onChanged: (bool value) {
                settingsProvider
                    .updateSettings(UserSettingsCompanion(darkMode: Value(value)));
              },
            ),

            // SEÇÃO DE LEMBRETES
            _buildSectionHeader("Lembretes"),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Lembrete de Estoque'),
              subtitle:
                  const Text('Ser notificado quando restarem poucas doses'),
              trailing: Text(
                '${settings.refillReminder} doses', // Usa as configurações carregadas
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                _showRefillReminderDialog(context, settingsProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Este método agora recebe UserProvider para alterar o nome do PERFIL
  void _showUserNameDialog(BuildContext context, UserProvider provider) {
    final activeUser = provider.activeUser;
    if (activeUser == null) return;

    final TextEditingController userNameController =
        TextEditingController(text: activeUser.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alterar Nome do Perfil'),
          content: TextField(
            controller: userNameController,
            decoration:
                const InputDecoration(hintText: 'Digite o nome do perfil'),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Salvar'),
              onPressed: () {
                final newName = userNameController.text;
                if (newName.isNotEmpty) {
                  // A chamada de atualização agora é no UserProvider
                  provider.updateUser(
                    UsersCompanion(
                      id: Value(activeUser.id),
                      name: Value(newName),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Este método não muda, pois opera no UserSettingsProvider
  void _showRefillReminderDialog(
      BuildContext context, UserSettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Lembrete de Reposição de Estoque'),
          children: <int>[1, 2, 3, 5, 10, 15].map((int value) {
            return SimpleDialogOption(
              onPressed: () {
                provider.updateSettings(
                  UserSettingsCompanion(refillReminder: Value(value)),
                );
                Navigator.pop(context);
              },
              child: Text('$value doses restantes'),
            );
          }).toList(),
        );
      },
    );
  }
}