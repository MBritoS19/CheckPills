import 'package:flutter/material.dart';
import 'package:CheckPills/core/services/backup_service.dart';
import 'package:CheckPills/data/datasources/database.dart';

class BackupProvider with ChangeNotifier {
  final BackupService _backupService; // Já está declarado como final
  
  // Inicialize a lista vazia
  List<BackupFileInfo> _backups = [];
  
  bool _isBackingUp = false;
  bool _isRestoring = false;
  String? _lastError;

  List<BackupFileInfo> get backups => _backups;
  bool get isBackingUp => _isBackingUp;
  bool get isRestoring => _isRestoring;
  String? get lastError => _lastError;

  // Construtor corrigido - inicialize _backupService diretamente
  BackupProvider(AppDatabase database) 
    : _backupService = BackupService(database) { // Inicialização no construtor
    _loadBackups();
  }

  // Carregar lista de backups
  Future<void> _loadBackups() async {
    try {
      _backups = await _backupService.getExistingBackups();
      notifyListeners();
    } catch (e) {
      print('❌ Erro ao carregar backups: $e');
    }
  }

  // Atualizar lista de backups
  Future<void> refreshBackups() async {
    await _loadBackups();
  }

  // Deletar backup
  Future<void> deleteBackup(String filePath) async {
    try {
      await _backupService.deleteBackup(filePath);
      await _loadBackups(); // Recarregar lista
    } catch (e) {
      _lastError = 'Erro ao deletar backup: $e';
      rethrow;
    }
  }

  // MÉTODO createLocalBackup
  Future<void> createLocalBackup() async {
    _isBackingUp = true;
    _lastError = null;
    notifyListeners();
    
    try {
      await _backupService.exportBackupToFile();
      await _loadBackups(); // 🔥 ATUALIZAR LISTA APÓS CRIAR BACKUP
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
      await _loadBackups(); // 🔥 ATUALIZAR LISTA APÓS CRIAR BACKUP
    } catch (e) {
      _lastError = 'Falha no backup: $e';
      rethrow;
    } finally {
      _isBackingUp = false;
      notifyListeners();
    }
  }

  Future<void> restoreFromBackup() async {
  _isRestoring = true;
  _lastError = null;
  notifyListeners();
  
  try {
    await _backupService.importBackupFromFile(); // Usa o file picker
  } catch (e) {
    _lastError = 'Falha na restauração: $e';
    rethrow;
  } finally {
    _isRestoring = false;
    notifyListeners();
  }
}

  Future<void> restoreFromSpecificFile(String filePath) async {
  _isRestoring = true;
  _lastError = null;
  notifyListeners();
  
  try {
    await _backupService.restoreFromSpecificFile(filePath); // Restauração direta
    
    // Recarregar lista de backups após restauração
    await _loadBackups();
    
  } catch (e) {
    _lastError = 'Falha na restauração: $e';
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
