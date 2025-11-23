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

  bool _isLoading = false;

  List<BackupFileInfo> get backups => _backups;
  bool get isBackingUp => _isBackingUp;
  bool get isRestoring => _isRestoring;
  String? get lastError => _lastError;

  BackupProvider(AppDatabase database)
      : _backupService = BackupService(database) {
    _loadBackups();
  }

  Future<void> initialize() async {
  try {
    print('🔄 Inicializando BackupProvider...');
    
    // 🔥 CORREÇÃO: Remover a linha que causa erro
    // await debugBackupDirectory(); // ⚠️ REMOVA ESTA LINHA
    
    // 🔥 CORREÇÃO: Fazer diagnóstico através do BackupService
    await _backupService.debugBackupDirectory();
    
    await loadExistingBackups();
    print('✅ BackupProvider inicializado com sucesso');
  } catch (e) {
    print('❌ Erro na inicialização do BackupProvider: $e');
    _lastError = 'Erro na inicialização: $e';
    notifyListeners();
  }
}

  Future<void> loadExistingBackups() async {
    try {
      _isLoading = true; // 🔥 AGORA ESTÁ DEFINIDO
      notifyListeners();

      final backups = await _backupService.getExistingBackups();
      _backups = backups;
      
      _isLoading = false; // 🔥 AGORA ESTÁ DEFINIDO
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false; // 🔥 AGORA ESTÁ DEFINIDO
      _lastError = 'Erro ao carregar backups: $e';
      notifyListeners();
      rethrow;
    }
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
    try {
      _isBackingUp = true;
      _lastError = null;
      notifyListeners();

      await _backupService.exportBackupToFile();
      await loadExistingBackups(); // Recarregar lista após criar backup
      
      _isBackingUp = false;
      notifyListeners();
    } catch (e) {
      _isBackingUp = false;
      _lastError = 'Erro ao criar backup: $e';
      notifyListeners();
      rethrow;
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
