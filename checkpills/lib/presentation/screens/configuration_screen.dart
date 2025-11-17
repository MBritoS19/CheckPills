import 'package:CheckPills/presentation/providers/user_provider.dart';
import 'package:CheckPills/presentation/providers/user_settings_provider.dart';
import 'package:CheckPills/presentation/screens/profile_management_screen.dart';
import 'package:CheckPills/presentation/screens/reports_screen.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:CheckPills/main.dart';
import 'package:CheckPills/presentation/providers/backup_provider.dart';
import 'package:CheckPills/core/services/backup_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:CheckPills/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
              title: SizedBox(
                width: double.infinity,
                child: Text(
                  currentUserName ?? 'Carregando...',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 18),
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

// BACKUP DOS DADOS
            ListTile(
              leading: const Icon(Icons.backup, color: Colors.green),
              title: const Text('Backup e Restauração'),
              subtitle: const Text('Faça backup ou restaure seus dados'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                _showBackupModal(context);
              },
            ),

// REINICIAR APLICATIVO (já existente)
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

  void _showBackupOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.save, color: Colors.blue),
                title: const Text('Backup Local'),
                subtitle: const Text('Salvar backup no dispositivo'),
                onTap: () {
                  Navigator.pop(context);
                  _createLocalBackup(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.green),
                title: const Text('Compartilhar Backup'),
                subtitle: const Text('Salvar e compartilhar arquivo'),
                onTap: () {
                  Navigator.pop(context);
                  _createAndShareBackup(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

// Diálogo de opções de restore
  void _showRestoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file, color: Colors.orange),
                title: const Text('Restaurar de Arquivo'),
                subtitle: const Text('Selecionar arquivo de backup'),
                onTap: () {
                  Navigator.pop(context);
                  _restoreFromFile(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Colors.purple),
                title: const Text('Backups Locais'),
                subtitle: const Text('Ver backups salvos no dispositivo'),
                onTap: () {
                  Navigator.pop(context);
                  _showLocalBackups(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _testBackupFunctionality(BuildContext context) async {
    final backupProvider = context.read<BackupProvider>();

    try {
      print('🧪 INICIANDO TESTE DE BACKUP...');

      // Teste simples usando apenas o BackupProvider
      await backupProvider.createLocalBackup();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Teste de backup executado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ TESTE FALHOU: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro no teste: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

// Nos métodos principais, use também apenas o BackupProvider
  Future<void> _createLocalBackup(BuildContext context) async {
    final backupProvider = context.read<BackupProvider>();

    try {
      await backupProvider.createLocalBackup();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Falha ao criar backup: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _createAndShareBackup(BuildContext context) async {
    final backupProvider = context.read<BackupProvider>();

    try {
      await backupProvider.createAndShareBackup();

      // Não precisa de SnackBar aqui porque o compartilhamento já mostra sua própria UI
      print('✅ Backup compartilhado com sucesso!');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Falha ao compartilhar backup: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

// MÉTODO _restoreFromFile - ATUALIZADO COM MENSAGENS MELHORES
  Future<void> _restoreFromFile(BuildContext context) async {
    final backupProvider = context.read<BackupProvider>();

    try {
      // Mostrar confirmação
      final shouldRestore = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restaurar Backup'),
          content: const Text(
            'Tem certeza que deseja restaurar um backup?\n\n'
            '⚠️ ATENÇÃO: Todos os dados atuais serão substituídos pelos dados do backup.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Continuar',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );

      if (shouldRestore != true) return;

      print('🔄 INICIANDO RESTAURAÇÃO VIA FILE PICKER...');

      // Abrir seletor de arquivos
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        print('📁 Arquivo selecionado: $filePath');

        // 🔥 ESTRATÉGIA: Fechar seletor de arquivos antes de restaurar
        Navigator.of(context).pop();

        // Aguardar fechamento do seletor
        await Future.delayed(const Duration(milliseconds: 300));

        // Fazer restauração
        await backupProvider.restoreFromSpecificFile(filePath);

        // 🔥 Navegação segura para MainScreen
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Backup restaurado com sucesso!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          });
        }
      }
    } catch (e) {
      print('❌ ERRO NA RESTAURAÇÃO: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao restaurar backup: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

// Método para mostrar backups locais
  Future<void> _showLocalBackups(BuildContext context) async {
    // TODO: Implementar lista de backups locais
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nenhum backup local encontrado'),
        backgroundColor: Colors.blue,
      ),
    );
  }

// Método para abrir o modal de backups - DENTRO da _ConfigurationScreenState
  void _showBackupModal(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: screenHeight * 0.7,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // CABEÇALHO (mantido igual)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Backup e Restauração',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // CONTEÚDO COM SCROLL (apenas backups locais)
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // SEÇÃO: BACKUPS LOCAIS (mantida igual)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildLocalBackupsSection(context),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔥 BOTÕES NA PARTE DE BAIXO (mantendo funcionalidades e estilo originais)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: _buildOriginalActionsSection(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOriginalActionsSection(BuildContext context) {
    final theme = Theme.of(context);
    final backupProvider = context.watch<BackupProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // INDICADOR DE PROGRESSO (original)
        if (backupProvider.isBackingUp || backupProvider.isRestoring) ...[
          LinearProgressIndicator(
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            backupProvider.isBackingUp
                ? 'Criando backup...'
                : 'Restaurando backup...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
        ],

        // BOTÕES ORIGINAIS (mesmo layout responsivo)
        if (screenWidth > 400)
          _buildOriginalHorizontalButtons(context, backupProvider, screenWidth)
        else
          _buildOriginalVerticalButtons(context, backupProvider, screenWidth),

        // MENSAGEM DE ERRO ORIGINAL
        if (backupProvider.lastError != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    backupProvider.lastError!,
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red.shade600, size: 16),
                  onPressed: () => backupProvider.clearError(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOriginalHorizontalButtons(
      BuildContext context, BackupProvider backupProvider, double screenWidth) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: backupProvider.isBackingUp
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : const Icon(Icons.backup),
            label: backupProvider.isBackingUp
                ? const Text('Criando...')
                : const Text('Criar Backup'),
            onPressed: backupProvider.isBackingUp || backupProvider.isRestoring
                ? null
                : () {
                    _createBackup(context);
                  },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            icon: backupProvider.isRestoring
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.upload_file),
            label: backupProvider.isRestoring
                ? const Text('Restaurando...')
                : const Text('Procurar Arquivo'),
            onPressed: backupProvider.isBackingUp || backupProvider.isRestoring
                ? null
                : () {
                    _selectBackupFile(context);
                  },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

// BOTÕES VERTICAIS ORIGINAIS
  Widget _buildOriginalVerticalButtons(
      BuildContext context, BackupProvider backupProvider, double screenWidth) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: backupProvider.isBackingUp
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : const Icon(Icons.backup),
            label: backupProvider.isBackingUp
                ? const Text('Criando Backup...')
                : const Text('Criar Backup'),
            onPressed: backupProvider.isBackingUp || backupProvider.isRestoring
                ? null
                : () {
                    _createBackup(context);
                  },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: backupProvider.isRestoring
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.upload_file),
            label: backupProvider.isRestoring
                ? const Text('Restaurando Backup...')
                : const Text('Procurar Arquivo'),
            onPressed: backupProvider.isBackingUp || backupProvider.isRestoring
                ? null
                : () {
                    _selectBackupFile(context);
                  },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

// SEÇÃO DE BACKUPS LOCAIS - DENTRO da _ConfigurationScreenState
  Widget _buildLocalBackupsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Backups Locais',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // LISTA DE BACKUPS (vazia por enquanto)
          _buildBackupList(context),
        ],
      ),
    );
  }

// LISTA DE BACKUPS - DENTRO da _ConfigurationScreenState
  Widget _buildBackupList(BuildContext context) {
    final backupProvider = context.watch<BackupProvider>();
    final backups = backupProvider.backups;

    if (backups.isEmpty) {
      return Container(
        height: 140,
        alignment: Alignment.center, // 🔥 CENTRALIZAÇÃO DIRETA
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_off,
                size: 32,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhum backup local',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Use os botões abaixo para criar seu primeiro backup',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children:
          backups.map((backup) => _buildBackupItem(context, backup)).toList(),
    );
  }

// ITEM DE BACKUP - DENTRO da _ConfigurationScreenState
  Widget _buildBackupItem(BuildContext context, BackupFileInfo backup) {
    final stats = backup.stats;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.backup, color: Colors.green.shade600, size: 20),
        ),
        title: Text(
          _formatBackupName(backup.name),
          style: const TextStyle(fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${backup.formattedDate} • ${backup.formattedSize}'),
            if (stats != null) ...[
              const SizedBox(height: 2),
              Text(
                '${stats['users']} usuários • ${stats['prescriptions']} medicações • ${stats['doseEvents']} eventos',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restore',
              child: Row(
                children: [
                  Icon(Icons.restore, size: 20),
                  SizedBox(width: 8),
                  Text('Restaurar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, size: 20),
                  SizedBox(width: 8),
                  Text('Compartilhar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  SizedBox(width: 8),
                  Text('Informações'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Deletar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            _handleBackupAction(context, value, backup);
          },
        ),
        onTap: () {
          _showBackupInfo(context, backup);
        },
      ),
    );
  }

// MOSTRAR INFORMAÇÕES DO BACKUP
  Future<void> _shareBackupFile(
      BuildContext context, BackupFileInfo backup) async {
    try {
      await Share.shareXFiles(
        [XFile(backup.path)],
        subject: 'CheckPills Backup - ${backup.formattedDate}',
        text: 'Backup do CheckPills criado em ${backup.formattedDate}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showBackupInfo(BuildContext context, BackupFileInfo backup) {
    final stats = backup.stats;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informações do Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Arquivo: ${backup.name}'),
            Text('Tamanho: ${backup.formattedSize}'),
            Text('Data: ${backup.formattedDate}'),
            if (stats != null) ...[
              const SizedBox(height: 16),
              const Text('Conteúdo:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• ${stats['users']} usuários'),
              Text('• ${stats['prescriptions']} medicamentos'),
              Text('• ${stats['doseEvents']} eventos de dose'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

// Método auxiliar para formatar o nome do backup
  String _formatBackupName(String fileName) {
    // Remove a extensão .json e o prefixo checkpills_backup_
    final withoutExtension = fileName.replaceAll('.json', '');
    final withoutPrefix = withoutExtension.replaceAll('checkpills_backup_', '');

    // Tenta converter o timestamp para data legível
    try {
      final timestamp = int.tryParse(withoutPrefix);
      if (timestamp != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return 'Backup ${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      // Se não conseguir converter, usa o nome original
    }

    return withoutPrefix;
  }

// SEÇÃO DE AÇÕES - DENTRO da _ConfigurationScreenState
  Widget _buildActionsSection(BuildContext context) {
    final theme = Theme.of(context);
    final backupProvider = context.watch<BackupProvider>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // INDICADOR DE PROGRESSO
          if (backupProvider.isBackingUp || backupProvider.isRestoring) ...[
            LinearProgressIndicator(
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              backupProvider.isBackingUp
                  ? 'Criando backup...'
                  : 'Restaurando backup...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
          ],

          Row(
            children: [
              // BOTÃO CRIAR BACKUP
              Expanded(
                child: OutlinedButton.icon(
                  icon: backupProvider.isBackingUp
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : const Icon(Icons.backup),
                  label: backupProvider.isBackingUp
                      ? const Text('Criando...')
                      : const Text('Criar Backup'),
                  onPressed:
                      backupProvider.isBackingUp || backupProvider.isRestoring
                          ? null
                          : () {
                              _createBackup(context);
                            },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // BOTÃO PROCURAR ARQUIVO
              Expanded(
                child: FilledButton.icon(
                  icon: backupProvider.isRestoring
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.upload_file),
                  label: backupProvider.isRestoring
                      ? const Text('Restaurando...')
                      : const Text('Procurar Arquivo'),
                  onPressed:
                      backupProvider.isBackingUp || backupProvider.isRestoring
                          ? null
                          : () {
                              _selectBackupFile(context);
                            },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          // MENSAGEM DE ERRO
          if (backupProvider.lastError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      backupProvider.lastError!,
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon:
                        Icon(Icons.close, color: Colors.red.shade600, size: 16),
                    onPressed: () => backupProvider.clearError(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

// MÉTODOS DE AÇÃO - DENTRO da _ConfigurationScreenState
  void _handleBackupAction(
      BuildContext context, String action, BackupFileInfo backup) {
    final backupProvider = context.read<BackupProvider>();

    switch (action) {
      case 'restore':
        _showRestoreConfirmation(context, backup);
        break;
      case 'share':
        _shareBackupFile(context, backup);
        break;
      case 'info':
        _showBackupInfo(context, backup);
        break;
      case 'delete':
        _showDeleteConfirmation(context, backup, backupProvider);
        break;
    }
  }

  void _showRestoreConfirmation(BuildContext context, BackupFileInfo backup) {
    final backupProvider = context.read<BackupProvider>();
    final stats = backup.stats;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tem certeza que deseja restaurar este backup?'),
            const SizedBox(height: 8),
            Text('⚠️ Todos os dados atuais serão substituídos.',
                style: TextStyle(color: Colors.orange.shade800)),
            if (stats != null) ...[
              const SizedBox(height: 12),
              const Text('Este backup contém:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• ${stats['users']} usuários'),
              Text('• ${stats['prescriptions']} medicamentos'),
              Text('• ${stats['doseEvents']} eventos'),
              const SizedBox(height: 8),
              Text(
                  'Data do backup: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(stats['backupDate'].toString()))}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Fechar o diálogo PRIMEIRO
              Navigator.pop(context);

              // Iniciar a restauração de forma SEGURA
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _restoreFromSpecificFile(context, backup, backupProvider);
              });
            },
            child: const Text('Restaurar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

// RESTAURAR DE ARQUIVO ESPECÍFICO
  Future<void> _restoreFromSpecificFile(BuildContext context,
      BackupFileInfo backup, BackupProvider backupProvider) async {
    try {
      print('🔄 INICIANDO RESTAURAÇÃO DO BACKUP: ${backup.name}');

      // 🔥 CORREÇÃO: Fechar TODOS os modais de forma SEGURA
      int popCount = 0;
      while (Navigator.of(context).canPop() && popCount < 3) {
        Navigator.of(context).pop();
        popCount++;
        await Future.delayed(const Duration(milliseconds: 100));
      }

      print('🔧 Modais fechados: $popCount');

      // Aguardar estabilização
      await Future.delayed(const Duration(milliseconds: 500));

      // Fazer a restauração
      await backupProvider.restoreFromSpecificFile(backup.path);

      print('✅ RESTAURAÇÃO CONCLUÍDA - Aguardando navegação...');

      // 🔥 CORREÇÃO: Navegação SUPER SEGURA
      if (mounted) {
        // Aguardar mais tempo para garantir estabilidade
        await Future.delayed(const Duration(milliseconds: 800));

        // Usar Navigator pushAndRemoveUntil de forma mais específica
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (Route<dynamic> route) => false,
        );

        print('🎯 Navegação para MainScreen concluída');
      }
    } catch (e) {
      print('❌ ERRO NA RESTAURAÇÃO: $e');
      if (mounted) {
        // 🔥 CORREÇÃO: Mostrar erro mas NÃO tentar navegar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Falha na restauração: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }

// REINICIAR SILENCIOSAMENTE
  void _restartAppSilently() {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    });
  }

// TRATAR ERRO DE FORMA SEGURA
  void _handleRestoreError(String error) {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );

      // Mostrar erro após a navegação
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Falha na restauração: $error'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 6),
            ),
          );
        }
      });
    });
  }

// backup_provider.dart - ADICIONE ESTE MÉTODO
  Future<void> safeRestoreFromFile(String filePath) async {
    try {
      // Fazer backup das configurações atuais antes da restauração
      final prefs = await SharedPreferences.getInstance();
      final currentTutorialState =
          prefs.getBool('home_tutorial_concluido') ?? true;

      //await restoreFromSpecificFile(filePath);

      // Se a restauração foi bem-sucedida mas o tutorial foi resetado,
      // garantir que o estado seja consistente
      if (!currentTutorialState) {
        await prefs.setBool('home_tutorial_concluido', false);
      }
    } catch (e) {
      print('❌ Erro no restore seguro: $e');
      rethrow;
    }
  }

// Método para mostrar recomendação de reinicialização
  void _showRestartRecommendation(BuildContext context) {
    // Usar WidgetsBinding para garantir que o contexto está estável
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('✅ Restauração Concluída'),
            content: const Text(
              'O backup foi restaurado com sucesso!\n\n'
              'O aplicativo será reiniciado para garantir que todos os dados sejam carregados corretamente.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);

                  // Aguardar um frame antes de reiniciar
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const MainScreen()),
                      (route) => false,
                    );
                  });
                },
                child: const Text('Reiniciar Agora'),
              ),
            ],
          ),
        ),
      );
    });
  }

  // MÉTODO _showDeleteConfirmation - CORRIGIDO
  void _showDeleteConfirmation(BuildContext context, BackupFileInfo backup,
      BackupProvider backupProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Backup'),
        content: Text(
            'Tem certeza que deseja deletar o backup "${_formatBackupName(backup.name)}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await backupProvider.deleteBackup(backup.path);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao deletar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _createBackup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.save, color: Colors.blue),
                title: const Text('Backup Local'),
                subtitle: const Text('Salvar backup no dispositivo'),
                onTap: () {
                  Navigator.pop(context);
                  _createLocalBackup(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.green),
                title: const Text('Compartilhar Backup'),
                subtitle: const Text('Salvar e compartilhar arquivo'),
                onTap: () {
                  Navigator.pop(context);
                  _createAndShareBackup(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectBackupFile(BuildContext context) {
    _restoreFromFile(context); // Agora usa o método real de restauração
  }

// MÉTODO AUXILIAR PARA MOSTRAR MENSAGENS
  void _showMessage(BuildContext context, String message,
      {bool isSuccess = false, bool isInfo = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isSuccess ? Colors.green : (isInfo ? Colors.orange : Colors.blue),
      ),
    );
  }
}
