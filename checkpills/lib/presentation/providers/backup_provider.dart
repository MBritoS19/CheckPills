import 'package:flutter/material.dart';
import 'package:CheckPills/core/services/backup_service.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupProvider with ChangeNotifier {
  final BackupService _backupService;

  List<BackupFileInfo> _backups = [];
  bool _isBackingUp = false;
  bool _isRestoring = false;
  String? _lastError;

  List<BackupFileInfo> get backups => _backups;
  bool get isBackingUp => _isBackingUp;
  bool get isRestoring => _isRestoring;
  String? get lastError => _lastError;

  BackupProvider(AppDatabase database)
      : _backupService = BackupService(database) {
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    try {
      _backups = await _backupService.getExistingBackups();
      notifyListeners();
    } catch (e) {
      print('❌ Erro ao carregar backups: $e');
    }
  }

  Future<void> refreshBackups() async {
    await _loadBackups();
  }

  Future<void> deleteBackup(String filePath) async {
    try {
      await _backupService.deleteBackup(filePath);
      await _loadBackups();
    } catch (e) {
      _lastError = 'Erro ao deletar backup: $e';
      rethrow;
    }
  }

  Future<void> createLocalBackup() async {
    _isBackingUp = true;
    _lastError = null;
    notifyListeners();

    try {
      await _backupService.exportBackupToFile();
      await _loadBackups();
    } catch (e) {
      _lastError = 'Falha no backup local: $e';
      rethrow;
    } finally {
      _isBackingUp = false;
      notifyListeners();
    }
  }

  Future<void> createAndShareBackup() async {
    _isBackingUp = true;
    _lastError = null;
    notifyListeners();

    try {
      await _backupService.shareBackup();
      await _loadBackups();
    } catch (e) {
      _lastError = 'Falha no backup: $e';
      rethrow;
    } finally {
      _isBackingUp = false;
      notifyListeners();
    }
  }

  // 🔥 MÉTODO QUE ESTAVA FALTANDO - ADICIONAR ESTE
  Future<void> restoreFromSpecificFile(String filePath) async {
    _isRestoring = true;
    _lastError = null;
    notifyListeners();

    try {
      print('🔄 INICIANDO RESTAURAÇÃO SEGURA...');

      // 🔥 CORREÇÃO CRÍTICA: Salvar estado ANTES de qualquer operação
      final prefs = await SharedPreferences.getInstance();
      final bool wasTutorialCompleted =
          prefs.getBool('home_tutorial_concluido') ?? true;
      final bool wasOnboardingCompleted =
          prefs.getBool('onboarding_concluido') ?? true;

      print('💾 Estado pré-restauração:');
      print('   - Tutorial concluído: $wasTutorialCompleted');
      print('   - Onboarding concluído: $wasOnboardingCompleted');

      // 🔥 CORREÇÃO: Fazer a restauração dos dados do banco
      await _backupService.restoreFromSpecificFile(filePath);

      // 🔥 CORREÇÃO: RESTAURAR ESTADO IMEDIATAMENTE após o restore
      await prefs.setBool('home_tutorial_concluido', wasTutorialCompleted);
      await prefs.setBool('onboarding_concluido', wasOnboardingCompleted);

      // 🔥 CORREÇÃO: NÃO limpar estado do ShowcaseView - isso causa o erro
      print('🔧 Estado do ShowcaseView PRESERVADO');

      // Recarregar lista de backups
      await _loadBackups();

      print('✅ RESTAURAÇÃO CONCLUÍDA COM SUCESSO');
    } catch (e) {
      _lastError = 'Falha na restauração: $e';
      print('❌ ERRO NA RESTAURAÇÃO: $e');
      rethrow;
    } finally {
      _isRestoring = false;
      notifyListeners();
    }
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }
}
