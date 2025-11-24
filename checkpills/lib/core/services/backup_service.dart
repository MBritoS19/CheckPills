import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:CheckPills/core/models/backup_model.dart';

class BackupService {
  final AppDatabase database;

  BackupService(this.database);

  // Criar backup completo
  Future<BackupData> createBackup() async {
    try {
      print('📦 INICIANDO CRIAÇÃO DE BACKUP...');

      final packageInfo = await PackageInfo.fromPlatform();
      print('📱 Versão do app: ${packageInfo.version}');

      final allUsers = await database.usersDao.getAllUsers();
      print('👥 Usuários encontrados: ${allUsers.length}');

      final allPrescriptions =
          await database.prescriptionsDao.watchAllPrescriptions().first;
      print('💊 Prescrições encontradas: ${allPrescriptions.length}');

      // Coletar todos os dados
      final userSettings = <UserSetting>[];
      final doseEvents = <DoseEventWithPrescription>[];

      for (final user in allUsers) {
        final settings =
            await database.userSettingsDao.getSettingsForUser(user.id);
        if (settings != null) {
          userSettings.add(settings);
        }

        final events =
            await database.doseEventsDao.watchAllDoseEvents(user.id).first;
        doseEvents.addAll(events);
      }

      print('⚙️  Configurações de usuário: ${userSettings.length}');
      print('📅 Eventos de dose: ${doseEvents.length}');

      final backupData = BackupData(
        backupDate: DateTime.now(),
        appVersion: packageInfo.version,
        users: allUsers
            .map((user) => UserBackup(
                  id: user.id,
                  name: user.name,
                  createdAt: user.createdAt,
                ))
            .toList(),
        userSettings: userSettings
            .map((settings) => UserSettingBackup(
                  userId: settings.userId,
                  standardPillType: settings.standardPillType,
                  themeMode: settings.themeMode,
                  refillReminder: settings.refillReminder,
                  createdAt: settings.createdAt,
                  updatedAt: settings.updatedAt,
                ))
            .toList(),
        prescriptions: allPrescriptions
            .map((prescription) => PrescriptionBackup(
                  id: prescription.id,
                  userId: prescription.userId,
                  name: prescription.name,
                  doseDescription: prescription.doseDescription,
                  type: prescription.type,
                  stock: prescription.stock,
                  intervalValue: prescription.intervalValue,
                  intervalUnit: prescription.intervalUnit,
                  isContinuous: prescription.isContinuous,
                  durationTreatment: prescription.durationTreatment,
                  unitTreatment: prescription.unitTreatment,
                  firstDoseTime: prescription.firstDoseTime,
                  notes: prescription.notes,
                  imagePath: prescription.imagePath,
                  enableNotifications: prescription.enableNotifications,
                  notifyMinutesBefore: prescription.notifyMinutesBefore,
                  notifyOnTime: prescription.notifyOnTime,
                  notifyAfterMinutes: prescription.notifyAfterMinutes,
                  createdAt: prescription.createdAt,
                  updatedAt: prescription.updatedAt,
                ))
            .toList(),
        doseEvents: doseEvents
            .map((event) => DoseEventBackup(
                  id: event.doseEvent.id,
                  prescriptionId: event.doseEvent.prescriptionId,
                  scheduledTime: event.doseEvent.scheduledTime,
                  takenTime: event.doseEvent.takenTime,
                  status: event.doseEvent.status.index,
                  createdAt: event.doseEvent.createdAt,
                  updatedAt: event.doseEvent.updatedAt,
                ))
            .toList(),
      );

      print('✅ BACKUP CRIADO COM SUCESSO!');
      print('📊 Estatísticas do backup:');
      print('   - Usuários: ${backupData.users.length}');
      print('   - Configurações: ${backupData.userSettings.length}');
      print('   - Prescrições: ${backupData.prescriptions.length}');
      print('   - Eventos de dose: ${backupData.doseEvents.length}');

      return backupData;
    } catch (e) {
      print('❌ ERRO AO CRIAR BACKUP: $e');
      rethrow;
    }
  }

  Future<Directory> getBackupDirectory() async {
  try {
    print('🔄 OBTENDO DIRETÓRIO DE BACKUP PERSISTENTE...');
    
    Directory directory;
    
    if (Platform.isAndroid) {
      // 🔥 CORREÇÃO: Usar Environment.DIRECTORY_DOWNLOADS (Downloads público)
      // Isso sobrevive à limpeza de dados do app
      if (await _canAccessPublicDownloads()) {
        // Tenta acessar Downloads público
        directory = await _getPublicDownloadsDirectory();
      } else {
        // Fallback para o diretório atual (que funciona sem permissões)
        directory = await getApplicationDocumentsDirectory();
      }
    } else {
      // Para iOS e outras plataformas
      directory = await getApplicationDocumentsDirectory();
    }
    
    // Cria subpasta específica para backups
    final backupDir = Directory('${directory.path}/CheckPills/Backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
      print('✅ Diretório de backups criado: ${backupDir.path}');
    }
    
    print('📁 Diretório FINAL: ${backupDir.path}');
    print('📁 É persistente?: ${!backupDir.path.contains("/Android/data/")}');
    
    return backupDir;
  } catch (e) {
    print('❌ Erro ao obter diretório de backup: $e');
    // Fallback absoluto
    final directory = await getApplicationDocumentsDirectory();
    return Directory('${directory.path}/Backups');
  }
}

// 🔥 NOVO: Verificar se podemos acessar Downloads público
Future<bool> _canAccessPublicDownloads() async {
  try {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    }
    return false;
  } catch (e) {
    return false;
  }
}

// 🔥 NOVO: Obter Downloads público
Future<Directory> _getPublicDownloadsDirectory() async {
  try {
    // No Android, o diretório de Downloads público
    final downloadsDir = Directory('/storage/emulated/0/Download');
    
    if (await downloadsDir.exists()) {
      return downloadsDir;
    }
    
    // Fallback para o diretório padrão
    return await getApplicationDocumentsDirectory();
  } catch (e) {
    print('❌ Erro ao acessar Downloads público: $e');
    return await getApplicationDocumentsDirectory();
  }
}

  Future<bool> _requestStoragePermissions() async {
  if (Platform.isAndroid) {
    try {
      print('🔐 SOLICITANDO PERMISSÕES...');
      
      // Verifica permissão atual
      var status = await Permission.storage.status;
      print('📋 Status da permissão storage: $status');
      
      // Solicita permissão
      status = await Permission.storage.request();
      print('📋 Nova status da permissão: $status');
      
      return status.isGranted;
    } catch (e) {
      print('❌ Erro nas permissões: $e');
      return false;
    }
  }
  return true;
}

  // 🔥 ATUALIZADO: Exportar backup para diretório persistente
  Future<File> exportBackupToFile() async {
    try {
      print('💾 EXPORTANDO BACKUP PARA ARQUIVO...');

      // Solicitar permissões
      await _requestStoragePermissions();

      final backupData = await createBackup();
      final jsonString = jsonEncode(backupData.toJson());

      print('📝 JSON gerado (${jsonString.length} caracteres)');

      // Usar diretório de backups persistente
      final backupDir = await getBackupDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'checkpills_backup_$timestamp.json';
      final filePath = '${backupDir.path}/$fileName';
      final file = File(filePath);

      await file.writeAsString(jsonString, flush: true);

      // Verificar se o arquivo foi realmente criado
      final exists = await file.exists();
      final size = await file.length();

      print('✅ ARQUIVO SALVO EM LOCAL PERSISTENTE: $filePath');
      print('📁 Existe: $exists, Tamanho: $size bytes');

      if (!exists || size == 0) {
        throw Exception('Arquivo de backup não foi criado corretamente');
      }

      return file;
    } catch (e) {
      print('❌ ERRO AO EXPORTAR BACKUP: $e');
      rethrow;
    }
  }

  // Compartilhar backup
  Future<void> shareBackup() async {
    try {
      print('📤 COMPARTILHANDO BACKUP...');

      final backupFile = await exportBackupToFile();

      print('📲 Iniciando compartilhamento...');
      await Share.shareXFiles(
        [XFile(backupFile.path)],
        subject: 'CheckPills Backup - ${DateTime.now().toString()}',
        text:
            'Backup completo do CheckPills - App de gestão de medicamentos\n\nData: ${DateTime.now().toString()}',
      );

      print('✅ BACKUP COMPARTILHADO COM SUCESSO!');
    } catch (e) {
      print('❌ ERRO AO COMPARTILHAR BACKUP: $e');
      rethrow;
    }
  }

  Future<List<BackupFileInfo>> getExistingBackups() async {
    try {
      final backupDir = await getBackupDirectory();
      
      print('🔍 Procurando backups em: ${backupDir.path}');
      
      if (!await backupDir.exists()) {
        print('📁 Diretório de backups não existe');
        return [];
      }

      final files = await backupDir.list().toList();
      final backupFiles = <BackupFileInfo>[];

      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final stat = await file.stat();
            final content = await file.readAsString();
            final backupData = jsonDecode(content);

            // Verificar se é um backup válido do CheckPills
            if (backupData.containsKey('backupDate') && 
                backupData.containsKey('appVersion')) {
              
              backupFiles.add(BackupFileInfo(
                file: file,
                name: file.path.split('/').last,
                path: file.path,
                size: stat.size,
                modified: stat.modified,
                backupData: backupData,
              ));
              
              print('📦 Backup encontrado: ${file.path.split('/').last}');
            }
          } catch (e) {
            print('❌ Arquivo de backup corrompido: ${file.path} - $e');
            continue;
          }
        }
      }

      // Ordenar por data (mais recente primeiro)
      backupFiles.sort((a, b) => b.modified.compareTo(a.modified));

      print('📁 Backups encontrados no diretório persistente: ${backupFiles.length}');
      return backupFiles;
    } catch (e) {
      print('❌ Erro ao listar backups: $e');
      return [];
    }
  }

  // 🔥 NOVO: Método para migrar backups antigos para o novo diretório
  Future<void> migrateOldBackups() async {
    try {
      final oldDirectory = await getApplicationDocumentsDirectory();
      final newDirectory = await getBackupDirectory();

      final oldDir = Directory(oldDirectory.path);
      
      if (!await oldDir.exists()) {
        return;
      }

      final files = await oldDir.list().toList();
      int migratedCount = 0;

      for (final file in files) {
        if (file is File && 
            file.path.endsWith('.json') && 
            file.path.contains('checkpills_backup_')) {
          
          final fileName = file.path.split('/').last;
          final newPath = '${newDirectory.path}/$fileName';
          
          // Verificar se já existe no novo diretório
          final newFile = File(newPath);
          if (!await newFile.exists()) {
            // Copiar arquivo para novo diretório
            await file.copy(newPath);
            migratedCount++;
            print('📦 Backup migrado: $fileName');
          }
        }
      }

      if (migratedCount > 0) {
        print('✅ $migratedCount backups migrados para diretório persistente');
      } else {
        print('ℹ️  Nenhum backup antigo para migrar');
      }
    } catch (e) {
      print('⚠️ Erro na migração de backups: $e');
    }
  }

  Future<void> deleteBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('✅ Backup deletado: $filePath');
      }
    } catch (e) {
      print('❌ Erro ao deletar backup: $e');
      rethrow;
    }
  }

  // Importar backup de arquivo JSON
  Future<void> importBackupFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        print('📁 Arquivo selecionado via file picker: $filePath');

        final file = File(filePath);
        final jsonString = await file.readAsString();
        final backupData = BackupData.fromJson(jsonDecode(jsonString));

        // Verificar integridade antes de restaurar
        if (!await verifyBackupIntegrity(backupData)) {
          throw Exception('Arquivo de backup corrompido ou inválido');
        }

        await _restoreBackup(backupData);
      }
    } catch (e) {
      throw Exception('Erro ao importar backup: $e');
    }
  }

  // Restaurar dados do backup
  Future<void> _restoreBackup(BackupData backupData) async {
    print('🔄 INICIANDO PROCESSO DE RESTAURAÇÃO...');

    try {
      // 🔥 CORREÇÃO: Usar transaction APENAS para dados do banco
      await database.transaction(() async {
        // 1. Limpar dados existentes do BANCO DE DADOS APENAS
        print('🧹 Limpando dados existentes do banco...');
        await database.resetDatabase();
        print('✅ Dados do banco removidos');

        // 2. Restaurar usuários
        print('👥 Restaurando ${backupData.users.length} usuários...');
        for (final userBackup in backupData.users) {
          await database.usersDao.addUser(UsersCompanion(
            id: Value(userBackup.id),
            name: Value(userBackup.name),
            createdAt: Value(userBackup.createdAt),
          ));
        }

        // 3. Restaurar configurações
        print(
            '⚙️  Restaurando ${backupData.userSettings.length} configurações...');
        for (final settingsBackup in backupData.userSettings) {
          await database.userSettingsDao.updateSettingsForUser(
            UserSettingsCompanion(
              userId: Value(settingsBackup.userId),
              standardPillType: Value(settingsBackup.standardPillType),
              themeMode: Value(settingsBackup.themeMode),
              refillReminder: Value(settingsBackup.refillReminder),
              createdAt: Value(settingsBackup.createdAt),
              updatedAt: Value(settingsBackup.updatedAt),
            ),
          );
        }

        // 4. Restaurar prescrições
        print(
            '💊 Restaurando ${backupData.prescriptions.length} prescrições...');
        for (final prescriptionBackup in backupData.prescriptions) {
          await database.prescriptionsDao.addPrescription(
            PrescriptionsCompanion(
              id: Value(prescriptionBackup.id),
              userId: Value(prescriptionBackup.userId),
              name: Value(prescriptionBackup.name),
              doseDescription: Value(prescriptionBackup.doseDescription),
              type: Value(prescriptionBackup.type),
              stock: Value(prescriptionBackup.stock),
              intervalValue: Value(prescriptionBackup.intervalValue),
              intervalUnit: Value(prescriptionBackup.intervalUnit),
              isContinuous: Value(prescriptionBackup.isContinuous),
              durationTreatment: Value(prescriptionBackup.durationTreatment),
              unitTreatment: Value(prescriptionBackup.unitTreatment),
              firstDoseTime: Value(prescriptionBackup.firstDoseTime),
              notes: Value(prescriptionBackup.notes),
              imagePath: Value(prescriptionBackup.imagePath),
              enableNotifications:
                  Value(prescriptionBackup.enableNotifications),
              notifyMinutesBefore:
                  Value(prescriptionBackup.notifyMinutesBefore),
              notifyOnTime: Value(prescriptionBackup.notifyOnTime),
              notifyAfterMinutes: Value(prescriptionBackup.notifyAfterMinutes),
              createdAt: Value(prescriptionBackup.createdAt),
              updatedAt: Value(prescriptionBackup.updatedAt),
            ),
          );
        }

        // 5. Restaurar eventos de dose
        print(
            '📅 Restaurando ${backupData.doseEvents.length} eventos de dose...');
        for (final doseEventBackup in backupData.doseEvents) {
          await database.doseEventsDao.addDoseEvent(
            DoseEventsCompanion(
              id: Value(doseEventBackup.id),
              prescriptionId: Value(doseEventBackup.prescriptionId),
              scheduledTime: Value(doseEventBackup.scheduledTime),
              takenTime: Value(doseEventBackup.takenTime),
              status: Value(DoseStatus.values[doseEventBackup.status]),
              createdAt: Value(doseEventBackup.createdAt),
              updatedAt: Value(doseEventBackup.updatedAt),
            ),
          );
        }
      });

      print('🎉 RESTAURAÇÃO DO BANCO CONCLUÍDA - AppState PRESERVADO');
    } catch (e) {
      print('❌ ERRO NA RESTAURAÇÃO DO BANCO: $e');
      rethrow;
    }
  }

  // Verificar integridade do backup - CORRIGIDO
  Future<bool> verifyBackupIntegrity(BackupData backupData) async {
    try {
      // Verificar se todos os usuários têm configurações
      final usersWithSettings =
          backupData.userSettings.map((s) => s.userId).toSet();
      final allUsers = backupData.users.map((u) => u.id).toSet();

      if (usersWithSettings.length != allUsers.length) {
        return false;
      }

      // Verificar se todas as prescrições têm usuário válido
      final validUserIds = allUsers;
      for (final prescription in backupData.prescriptions) {
        if (!validUserIds.contains(prescription.userId)) {
          return false;
        }
      }

      // Verificar se todos os dose events têm prescrição válida
      final validPrescriptionIds =
          backupData.prescriptions.map((p) => p.id).toSet();
      for (final doseEvent in backupData.doseEvents) {
        if (!validPrescriptionIds.contains(doseEvent.prescriptionId)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Obter estatísticas do backup
  Future<Map<String, dynamic>> getBackupStats(BackupData backupData) async {
    return {
      'users': backupData.users.length,
      'prescriptions': backupData.prescriptions.length,
      'doseEvents': backupData.doseEvents.length,
      'backupDate': backupData.backupDate,
      'appVersion': backupData.appVersion,
    };
  }

  Future<void> restoreFromSpecificFile(String filePath) async {
  try {
    print('🔄 INICIANDO RESTAURAÇÃO DE ARQUIVO ESPECÍFICO...');
    print('📁 Arquivo: $filePath');

    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('Arquivo de backup não encontrado: $filePath');
    }

    final jsonString = await file.readAsString();
    final backupData = BackupData.fromJson(jsonDecode(jsonString));

    if (!await verifyBackupIntegrity(backupData)) {
      throw Exception('Arquivo de backup corrompido ou inválido');
    }

    await _restoreBackup(backupData);
    print('✅ RESTAURAÇÃO CONCLUÍDA COM SUCESSO!');
  } catch (e) {
    print('❌ ERRO NA RESTAURAÇÃO: $e');
    rethrow;
  }
}

  Future<void> debugBackupDirectory() async {
  try {
    print('🔍 DIAGNÓSTICO INICIADO');
    
    // Teste 1: Diretório de documentos do app
    final appDocDir = await getApplicationDocumentsDirectory();
    print('📁 App Documents: ${appDocDir.path}');
    
    // Teste 2: Diretório de downloads
    final downloadsDir = await getDownloadsDirectory();
    print('📁 Downloads: ${downloadsDir?.path ?? "NULL"}');
    
    // Teste 3: Nosso diretório de backups
    final backupDir = await getBackupDirectory();
    print('📁 Backup Directory: ${backupDir.path}');
    
    // Teste 4: Listar arquivos existentes
    final files = await backupDir.list().toList();
    print('📊 Arquivos no diretório: ${files.length}');
    
    for (final file in files) {
      if (file is File) {
        print('   📄 ${file.path.split('/').last}');
      }
    }
    
  } catch (e) {
    print('❌ ERRO NO DIAGNÓSTICO: $e');
  }
}
}

class BackupFileInfo {
  final File file;
  final String name;
  final String path;
  final int size;
  final DateTime modified;
  final Map<String, dynamic>? backupData;

  BackupFileInfo({
    required this.file,
    required this.name,
    required this.path,
    required this.size,
    required this.modified,
    this.backupData,
  });

  // Método para obter estatísticas do backup
  Map<String, dynamic>? get stats {
    if (backupData == null) return null;

    try {
      return {
        'users': (backupData!['users'] as List).length,
        'prescriptions': (backupData!['prescriptions'] as List).length,
        'doseEvents': (backupData!['doseEvents'] as List).length,
        'backupDate': DateTime.parse(backupData!['backupDate']),
        'appVersion': backupData!['appVersion'],
      };
    } catch (e) {
      return null;
    }
  }

  // Formatar tamanho do arquivo
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Formatar data
  String get formattedDate {
    return '${modified.day}/${modified.month}/${modified.year} ${modified.hour}:${modified.minute.toString().padLeft(2, '0')}';
  }
}
