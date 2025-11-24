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
  try {
    _isRestoring = true;
    _lastError = null;
    notifyListeners();

    print('🔄 Restaurando backup de: $filePath');
    
    // 🔥 Isso deve chamar o método do BackupService
    await _backupService.restoreFromSpecificFile(filePath);
    
    _isRestoring = false;
    notifyListeners();
    
    print('✅ Restauração concluída com sucesso');
  } catch (e) {
    _isRestoring = false;
    _lastError = 'Erro ao restaurar backup: $e';
    notifyListeners();
    print('❌ Erro na restauração: $e');
    rethrow;
  }
}

  void clearError() {
    _lastError = null;
    notifyListeners();
  }
}
