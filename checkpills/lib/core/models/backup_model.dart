import 'package:json_annotation/json_annotation.dart';

part 'backup_model.g.dart';

@JsonSerializable()
class BackupData {
  final DateTime backupDate;
  final String appVersion;
  final List<UserBackup> users;
  final List<UserSettingBackup> userSettings;
  final List<PrescriptionBackup> prescriptions;
  final List<DoseEventBackup> doseEvents;

  BackupData({
    required this.backupDate,
    required this.appVersion,
    required this.users,
    required this.userSettings,
    required this.prescriptions,
    required this.doseEvents,
  });

  factory BackupData.fromJson(Map<String, dynamic> json) => 
      _$BackupDataFromJson(json);
      
  Map<String, dynamic> toJson() => _$BackupDataToJson(this);
}

@JsonSerializable()
class UserBackup {
  final int id;
  final String name;
  final DateTime createdAt;

  UserBackup({required this.id, required this.name, required this.createdAt});

  factory UserBackup.fromJson(Map<String, dynamic> json) => 
      _$UserBackupFromJson(json);
      
  Map<String, dynamic> toJson() => _$UserBackupToJson(this);
}

@JsonSerializable()
class UserSettingBackup {
  final int userId;
  final String? standardPillType;
  final int themeMode;
  final int refillReminder;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettingBackup({
    required this.userId,
    this.standardPillType,
    required this.themeMode,
    required this.refillReminder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSettingBackup.fromJson(Map<String, dynamic> json) => 
      _$UserSettingBackupFromJson(json);
      
  Map<String, dynamic> toJson() => _$UserSettingBackupToJson(this);
}

@JsonSerializable()
class PrescriptionBackup {
  final int id;
  final int userId;
  final String name;
  final String doseDescription;
  final String type;
  final int stock;
  final int intervalValue;
  final String intervalUnit;
  final bool isContinuous;
  final int? durationTreatment;
  final String? unitTreatment;
  final DateTime firstDoseTime;
  final String? notes;
  final String? imagePath;
  final bool enableNotifications;
  final int? notifyMinutesBefore;
  final bool notifyOnTime;
  final int? notifyAfterMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PrescriptionBackup({
    required this.id,
    required this.userId,
    required this.name,
    required this.doseDescription,
    required this.type,
    required this.stock,
    required this.intervalValue,
    required this.intervalUnit,
    required this.isContinuous,
    this.durationTreatment,
    this.unitTreatment,
    required this.firstDoseTime,
    this.notes,
    this.imagePath,
    required this.enableNotifications,
    this.notifyMinutesBefore,
    required this.notifyOnTime,
    this.notifyAfterMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PrescriptionBackup.fromJson(Map<String, dynamic> json) => 
      _$PrescriptionBackupFromJson(json);
      
  Map<String, dynamic> toJson() => _$PrescriptionBackupToJson(this);
}

@JsonSerializable()
class DoseEventBackup {
  final int id;
  final int prescriptionId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  DoseEventBackup({
    required this.id,
    required this.prescriptionId,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DoseEventBackup.fromJson(Map<String, dynamic> json) => 
      _$DoseEventBackupFromJson(json);
      
  Map<String, dynamic> toJson() => _$DoseEventBackupToJson(this);
}
