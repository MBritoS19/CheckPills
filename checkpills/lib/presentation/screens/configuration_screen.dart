import 'package:CheckPills/presentation/providers/user_provider.dart';
import 'package:CheckPills/presentation/providers/user_settings_provider.dart';
import 'package:CheckPills/presentation/screens/profile_management_screen.dart';
import 'package:CheckPills/presentation/screens/reports_screen.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:CheckPills/main.dart'; // ← ADICIONE ESTA LINHA

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  bool _isResetting = false;

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
    if (_isResetting) {
      return _buildLoadingScreen('Reiniciando aplicativo...');
    }

    final settingsProvider = context.watch<UserSettingsProvider>();
    final userProvider = context.watch<UserProvider>();

    final String? currentUserName = userProvider.activeUser?.name;
    final settings = settingsProvider.settings;

    // Se não há usuários e o provider foi inicializado, vai para onboarding
    if (userProvider.allUsers.isEmpty && userProvider.isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MyApp()),
          (route) => false,
        );
      });
      return _buildLoadingScreen('Redirecionando...');
    }

    // Loading normal enquanto carrega configurações
    if (settings == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Configurações')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SEÇÃO DE PERFIL
            _buildSectionHeader("Perfil"),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Flexible(
                child: Builder(
                  builder: (BuildContext context) {
                    // 1. Armazena o nome do usuário ou 'Carregando...'
                    final String nameToDisplay =
                        currentUserName ?? 'Carregando...';

                    // 2. Garante que o widget ocupe 100% da largura.
                    return SizedBox(
                      width: double.infinity, // Garante 100% da largura do pai
                      child: Text(
                        nameToDisplay, // Usamos o nome COMPLETO.

                        // O Flutter calcula o quanto cabe na largura total e adiciona "..."
                        // no final da linha, cumprindo o requisito de limitar o texto ao tamanho do celular.
                        overflow: TextOverflow.ellipsis,

                        // Garante que o truncamento aconteça em uma única linha.
                        maxLines: 1,

                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  },
                ),
              ),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () {
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

            // SEÇÃO DE RELATÓRIOS
            _buildSectionHeader("Relatórios"),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Relatórios e Estatísticas'),
              subtitle: const Text('Veja seu histórico de medicamentos'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ReportsScreen(),
                  ),
                );
              },
            ),

            // SEÇÃO DE APARÊNCIA
            _buildSectionHeader("Aparência"),
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined),
              title: const Text('Tema'),
              subtitle: Text(_getCurrentThemeName(settings.themeMode)),
              onTap: () {
                _showThemeSelectionDialog(context, settingsProvider);
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
                '${settings.refillReminder} doses',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                _showRefillReminderDialog(context, settingsProvider);
              },
            ),

            // SEÇÃO: MANUTENÇÃO
            _buildSectionHeader("Manutenção"),
            ListTile(
              leading: const Icon(Icons.restart_alt, color: Colors.red),
              title: const Text('Reiniciar Aplicativo',
                  style: TextStyle(color: Colors.red)),
              subtitle: const Text('Voltar às configurações iniciais'),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),
              onTap: () {
                _showResetConfirmationDialog(context, userProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  String _getCurrentThemeName(int themeMode) {
    switch (themeMode) {
      case 1:
        return 'Claro';
      case 2:
        return 'Escuro';
      default:
        return 'Padrão do Sistema';
    }
  }

  void _showThemeSelectionDialog(
      BuildContext context, UserSettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Selecionar Tema'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                provider.updateSettings(
                  const UserSettingsCompanion(themeMode: Value(0)), // Sistema
                );
                Navigator.pop(context);
              },
              child: const Text('Padrão do Sistema'),
            ),
            SimpleDialogOption(
              onPressed: () {
                provider.updateSettings(
                  const UserSettingsCompanion(themeMode: Value(1)), // Claro
                );
                Navigator.pop(context);
              },
              child: const Text('Claro'),
            ),
            SimpleDialogOption(
              onPressed: () {
                provider.updateSettings(
                  const UserSettingsCompanion(themeMode: Value(2)), // Escuro
                );
                Navigator.pop(context);
              },
              child: const Text('Escuro'),
            ),
          ],
        );
      },
    );
  }

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

  // NOVO MÉTODO: Diálogo de confirmação para reset
  void _showResetConfirmationDialog(
      BuildContext context, UserProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reiniciar Aplicativo'),
          content: const Text(
            'Tem certeza que deseja voltar o aplicativo às configurações iniciais?\n\n'
            '⚠️  Esta ação irá:'
            '\n• Apagar TODOS os usuários e perfis'
            '\n• Remover TODOS os medicamentos'
            '\n• Limpar TODOS os históricos'
            '\n• Cancelar TODAS as notificações'
            '\n• Voltar todas as configurações ao padrão'
            '\n\nEsta ação NÃO pode ser desfeita!',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Reiniciar Tudo',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _performReset(context, provider);
              },
            ),
          ],
        );
      },
    );
  }

  // NOVO MÉTODO: Executar o reset
  Future<void> _performReset(
      BuildContext context, UserProvider provider) async {
    setState(() {
      _isResetting = true;
    });

    try {
      // Executa o reset (apenas limpa dados)
      await provider.resetApp();

      // Navega diretamente para o MyApp
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MyApp()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResetting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao reiniciar aplicativo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
