// lib/screens/configuration_screen.dart

import 'package:CheckPills/data/datasources/database.dart';
import 'package:CheckPills/presentation/providers/settings_provider.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:CheckPills/core/theme/app_theme.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final String? currentUserName = provider.settings.userName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenWidth * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                title: Text(
                  currentUserName ?? 'Cadastrar Usuário',
                  style: TextStyle(
                    color: currentUserName == null ? Colors.blue : Colors.black,
                    fontWeight: currentUserName == null ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: Icon(
                  currentUserName == null ? Icons.add_circle_outline : Icons.edit,
                  color: Colors.blue,
                ),
                onTap: () {
                  _showUserNameDialog(context, provider);
                },
              ),
              const Divider(color: orangeColor),
              SwitchListTile(
                title: const Text('Modo Noturno'),
                value: provider.settings.darkMode,
                onChanged: (bool value) {
                  provider.updateSettings(
                      SettingsCompanion(darkMode: Value(value)));
                },
              ),
              const Divider(color: orangeColor),
              ListTile(
                title: const Text('Lembrete de Estoque'),
                subtitle: const Text(
                    'Lembre-me para repor o estoque quando faltarem X doses.'),
                trailing: DropdownButton<int>(
                  value: provider.settings.refillReminder,
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      provider.updateSettings(
                          SettingsCompanion(refillReminder: Value(newValue)));
                    }
                  },
                  items: <int>[
                    1,
                    2,
                    3,
                    4,
                    5,
                    6,
                    7,
                    8,
                    9,
                    10
                  ].map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value dose(s)'),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserNameDialog(BuildContext context, SettingsProvider provider) {
    String? currentName = provider.settings.userName;
    final TextEditingController userNameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(currentName == null ? 'Cadastrar Usuário' : 'Alterar Nome'),
          content: TextField(
            controller: userNameController,
            decoration: const InputDecoration(hintText: 'Digite o nome do usuário'),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Salvar'),
              onPressed: () {
                if (userNameController.text.isNotEmpty) {
                  provider.updateSettings(
                    SettingsCompanion(userName: Value(userNameController.text)),
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
}
