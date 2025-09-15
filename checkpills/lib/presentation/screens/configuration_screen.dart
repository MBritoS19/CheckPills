// lib/presentation/screens/configuration_screen.dart

import 'package:CheckPills/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  final _userNameController = TextEditingController();
  final _refillReminderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Preenche os campos com os valores atuais do provedor quando a tela é inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      if (settingsProvider.currentSettings != null) {
        _userNameController.text =
            settingsProvider.currentSettings!.userName ?? '';
        _refillReminderController.text =
            (settingsProvider.currentSettings!.refillReminder).toString();
      }
    });
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _refillReminderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDarkMode = settingsProvider.currentSettings?.darkMode ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Seção de Informações do Usuário
            const Text(
              'Informações do Usuário',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nome do usuário',
              ),
              onChanged: (value) {
                settingsProvider.updateUserName(value);
              },
            ),
            const SizedBox(height: 32),

            // Seção de Preferências do App
            const Text(
              'Preferências do Aplicativo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Modo Escuro'),
                Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    settingsProvider.toggleDarkMode(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text('Lembrete de refil (dias antes do fim)'),
                ),
                SizedBox(
                  width: 80,
                  // NOVO: Campo de texto para o número
                  child: TextFormField(
                    controller: _refillReminderController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      final days = int.tryParse(value);
                      if (days != null) {
                        settingsProvider.updateRefillReminder(days);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
