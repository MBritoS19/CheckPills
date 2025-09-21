// lib/presentation/screens/configuration_screen.dart

import 'package:CheckPills/presentation/providers/settings_provider.dart';
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
  // NOVO: Helper para criar os títulos de seção
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 24.0, bottom: 8.0, left: 16.0, right: 16.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context)
              .colorScheme
              .primary, // Usa a cor primária do tema
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos 'watch' para que a UI se reconstrua com as mudanças
    final provider = context.watch<SettingsProvider>();
    final String? currentUserName = provider.settings.userName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: SingleChildScrollView(
        // O padding foi removido daqui para ser aplicado por seção
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Alinha os headers à esquerda
          children: [
            // SEÇÃO DE PERFIL
            _buildSectionHeader("Perfil"),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(currentUserName ?? 'Definir nome de usuário'),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () {
                _showUserNameDialog(context, provider);
              },
            ),

            // SEÇÃO DE APARÊNCIA
            _buildSectionHeader("Aparência"),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Modo Noturno'),
              value: provider.settings.darkMode,
              onChanged: (bool value) {
                provider
                    .updateSettings(SettingsCompanion(darkMode: Value(value)));
              },
            ),

            // SEÇÃO DE LEMBRETES
            _buildSectionHeader("Lembretes"),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Lembrete de Estoque'),
              subtitle:
                  const Text('Ser notificado quando restarem poucas doses'),
              // NOVO: Mostra o valor atual e é clicável
              trailing: Text(
                '${provider.settings.refillReminder} doses',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                _showRefillReminderDialog(context, provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUserNameDialog(BuildContext context, SettingsProvider provider) {
    String? currentName = provider.settings.userName;
    final TextEditingController userNameController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(currentName == null ? 'Cadastrar Usuário' : 'Alterar Nome'),
          content: TextField(
            controller: userNameController,
            decoration:
                const InputDecoration(hintText: 'Digite o nome do usuário'),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // Dentro de _showUserNameDialog
            // Dentro de _showUserNameDialog
            TextButton(
              child: const Text('Salvar'),
              onPressed: () {
                final newName = userNameController.text;

                provider.updateSettings(
                  SettingsCompanion(
                      userName: Value(newName.isEmpty ? null : newName)),
                );

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showRefillReminderDialog(
      BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Lembrete de Reposição de Estoque'),
          children: <int>[1, 2, 3, 5, 10, 15].map((int value) {
            return SimpleDialogOption(
              onPressed: () {
                provider.updateSettings(
                  SettingsCompanion(refillReminder: Value(value)),
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
