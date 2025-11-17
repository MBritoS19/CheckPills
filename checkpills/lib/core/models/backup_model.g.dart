// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackupData _$BackupDataFromJson(Map<String, dynamic> json) => BackupData(
      backupDate: DateTime.parse(json['backupDate'] as String),
      appVersion: json['appVersion'] as String,
      users: (json['users'] as List<dynamic>)
          .map((e) => UserBackup.fromJson(e as Map<String, dynamic>))
          .toList(),
      userSettings: (json['userSettings'] as List<dynamic>)
          .map((e) => UserSettingBackup.fromJson(e as Map<String, dynamic>))
          .toList(),
      prescriptions: (json['prescriptions'] as List<dynamic>)
          .map((e) => PrescriptionBackup.fromJson(e as Map<String, dynamic>))
          .toList(),
      doseEvents: (json['doseEvents'] as List<dynamic>)
          .map((e) => DoseEventBackup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BackupDataToJson(BackupData instance) =>
    <String, dynamic>{
      'backupDate': instance.backupDate.toIso8601String(),
      'appVersion': instance.appVersion,
      'users': instance.users.map((e) => e.toJson()).toList(),
      'userSettings': instance.userSettings.map((e) => e.toJson()).toList(),
      'prescriptions': instance.prescriptions.map((e) => e.toJson()).toList(),
      'doseEvents': instance.doseEvents.map((e) => e.toJson()).toList(),
    };

UserBackup _$UserBackupFromJson(Map<String, dynamic> json) => UserBackup(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserBackupToJson(UserBackup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
    };

UserSettingBackup _$UserSettingBackupFromJson(Map<String, dynamic> json) =>
    UserSettingBackup(
      userId: json['userId'] as int,
      standardPillType: json['standardPillType'] as String?,
      themeMode: json['themeMode'] as int,
      refillReminder: json['refillReminder'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserSettingBackupToJson(UserSettingBackup instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'standardPillType': instance.standardPillType,
      'themeMode': instance.themeMode,
      'refillReminder': instance.refillReminder,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

PrescriptionBackup _$PrescriptionBackupFromJson(Map<String, dynamic> json) =>
    PrescriptionBackup(
      id: json['id'] as int,
      userId: json['userId'] as int,
      name: json['name'] as String,
      doseDescription: json['doseDescription'] as String,
      type: json['type'] as String,
      stock: json['stock'] as int,
      intervalValue: json['intervalValue'] as int,
      intervalUnit: json['intervalUnit'] as String,
      isContinuous: json['isContinuous'] as bool,
      durationTreatment: json['durationTreatment'] as int?,
      unitTreatment: json['unitTreatment'] as String?,
      firstDoseTime: DateTime.parse(json['firstDoseTime'] as String),
      notes: json['notes'] as String?,
      imagePath: json['imagePath'] as String?,
      enableNotifications: json['enableNotifications'] as bool,
      notifyMinutesBefore: json['notifyMinutesBefore'] as int?,
      notifyOnTime: json['notifyOnTime'] as bool,
      notifyAfterMinutes: json['notifyAfterMinutes'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PrescriptionBackupToJson(PrescriptionBackup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'doseDescription': instance.doseDescription,
      'type': instance.type,
      'stock': instance.stock,
      'intervalValue': instance.intervalValue,
      'intervalUnit': instance.intervalUnit,
      'isContinuous': instance.isContinuous,
      'durationTreatment': instance.durationTreatment,
      'unitTreatment': instance.unitTreatment,
      'firstDoseTime': instance.firstDoseTime.toIso8601String(),
      'notes': instance.notes,
      'imagePath': instance.imagePath,
      'enableNotifications': instance.enableNotifications,
      'notifyMinutesBefore': instance.notifyMinutesBefore,
      'notifyOnTime': instance.notifyOnTime,
      'notifyAfterMinutes': instance.notifyAfterMinutes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

DoseEventBackup _$DoseEventBackupFromJson(Map<String, dynamic> json) =>
    DoseEventBackup(
      id: json['id'] as int,
      prescriptionId: json['prescriptionId'] as int,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      takenTime: json['takenTime'] == null
          ? null
          : DateTime.parse(json['takenTime'] as String),
      status: json['status'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DoseEventBackupToJson(DoseEventBackup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'prescriptionId': instance.prescriptionId,
      'scheduledTime': instance.scheduledTime.toIso8601String(),
      'takenTime': instance.takenTime?.toIso8601String(),
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
