import 'package:CheckPills/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      if (settingsProvider.settings != null) {
        _userNameController.text = settingsProvider.settings!.userName ?? '';
        _refillReminderController.text =
            (settingsProvider.settings!.refillReminder).toString();
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
    final isDarkMode = settingsProvider.settings?.darkMode ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações do Usuário',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: 'Nome de Usuário',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                settingsProvider.saveUserName(value);
              },
            ),
            const Divider(height: 32),
            ListTile(
              title: const Text('Modo Escuro'),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  settingsProvider.toggleDarkMode(value);
                },
              ),
            ),
            const Divider(height: 32),
            const Text(
              'Lembretes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _refillReminderController,
              decoration: const InputDecoration(
                labelText: 'Lembrete de refil',
                suffixText: 'dias antes de acabar',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final days = int.tryParse(value);
                if (days != null) {
                  settingsProvider.saveRefillReminder(days);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
