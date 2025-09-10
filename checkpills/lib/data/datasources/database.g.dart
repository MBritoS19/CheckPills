// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _userNameMeta =
      const VerificationMeta('userName');
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
      'user_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _standardPillTypeMeta =
      const VerificationMeta('standardPillType');
  @override
  late final GeneratedColumn<String> standardPillType = GeneratedColumn<String>(
      'standard_pill_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _darkModeMeta =
      const VerificationMeta('darkMode');
  @override
  late final GeneratedColumn<bool> darkMode = GeneratedColumn<bool>(
      'dark_mode', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dark_mode" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _refillReminderMeta =
      const VerificationMeta('refillReminder');
  @override
  late final GeneratedColumn<int> refillReminder = GeneratedColumn<int>(
      'refill_reminder', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userName,
        standardPillType,
        darkMode,
        refillReminder,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_name')) {
      context.handle(_userNameMeta,
          userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta));
    }
    if (data.containsKey('standard_pill_type')) {
      context.handle(
          _standardPillTypeMeta,
          standardPillType.isAcceptableOrUnknown(
              data['standard_pill_type']!, _standardPillTypeMeta));
    }
    if (data.containsKey('dark_mode')) {
      context.handle(_darkModeMeta,
          darkMode.isAcceptableOrUnknown(data['dark_mode']!, _darkModeMeta));
    }
    if (data.containsKey('refill_reminder')) {
      context.handle(
          _refillReminderMeta,
          refillReminder.isAcceptableOrUnknown(
              data['refill_reminder']!, _refillReminderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_name']),
      standardPillType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}standard_pill_type']),
      darkMode: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dark_mode'])!,
      refillReminder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}refill_reminder'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final String? userName;
  final String? standardPillType;
  final bool darkMode;
  final int refillReminder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Setting(
      {required this.id,
      this.userName,
      this.standardPillType,
      required this.darkMode,
      required this.refillReminder,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || userName != null) {
      map['user_name'] = Variable<String>(userName);
    }
    if (!nullToAbsent || standardPillType != null) {
      map['standard_pill_type'] = Variable<String>(standardPillType);
    }
    map['dark_mode'] = Variable<bool>(darkMode);
    map['refill_reminder'] = Variable<int>(refillReminder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      userName: userName == null && nullToAbsent
          ? const Value.absent()
          : Value(userName),
      standardPillType: standardPillType == null && nullToAbsent
          ? const Value.absent()
          : Value(standardPillType),
      darkMode: Value(darkMode),
      refillReminder: Value(refillReminder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      userName: serializer.fromJson<String?>(json['userName']),
      standardPillType: serializer.fromJson<String?>(json['standardPillType']),
      darkMode: serializer.fromJson<bool>(json['darkMode']),
      refillReminder: serializer.fromJson<int>(json['refillReminder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userName': serializer.toJson<String?>(userName),
      'standardPillType': serializer.toJson<String?>(standardPillType),
      'darkMode': serializer.toJson<bool>(darkMode),
      'refillReminder': serializer.toJson<int>(refillReminder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Setting copyWith(
          {int? id,
          Value<String?> userName = const Value.absent(),
          Value<String?> standardPillType = const Value.absent(),
          bool? darkMode,
          int? refillReminder,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Setting(
        id: id ?? this.id,
        userName: userName.present ? userName.value : this.userName,
        standardPillType: standardPillType.present
            ? standardPillType.value
            : this.standardPillType,
        darkMode: darkMode ?? this.darkMode,
        refillReminder: refillReminder ?? this.refillReminder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      userName: data.userName.present ? data.userName.value : this.userName,
      standardPillType: data.standardPillType.present
          ? data.standardPillType.value
          : this.standardPillType,
      darkMode: data.darkMode.present ? data.darkMode.value : this.darkMode,
      refillReminder: data.refillReminder.present
          ? data.refillReminder.value
          : this.refillReminder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('userName: $userName, ')
          ..write('standardPillType: $standardPillType, ')
          ..write('darkMode: $darkMode, ')
          ..write('refillReminder: $refillReminder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userName, standardPillType, darkMode,
      refillReminder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.userName == this.userName &&
          other.standardPillType == this.standardPillType &&
          other.darkMode == this.darkMode &&
          other.refillReminder == this.refillReminder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<String?> userName;
  final Value<String?> standardPillType;
  final Value<bool> darkMode;
  final Value<int> refillReminder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.userName = const Value.absent(),
    this.standardPillType = const Value.absent(),
    this.darkMode = const Value.absent(),
    this.refillReminder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.userName = const Value.absent(),
    this.standardPillType = const Value.absent(),
    this.darkMode = const Value.absent(),
    this.refillReminder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<String>? userName,
    Expression<String>? standardPillType,
    Expression<bool>? darkMode,
    Expression<int>? refillReminder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userName != null) 'user_name': userName,
      if (standardPillType != null) 'standard_pill_type': standardPillType,
      if (darkMode != null) 'dark_mode': darkMode,
      if (refillReminder != null) 'refill_reminder': refillReminder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SettingsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? userName,
      Value<String?>? standardPillType,
      Value<bool>? darkMode,
      Value<int>? refillReminder,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return SettingsCompanion(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      standardPillType: standardPillType ?? this.standardPillType,
      darkMode: darkMode ?? this.darkMode,
      refillReminder: refillReminder ?? this.refillReminder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (standardPillType.present) {
      map['standard_pill_type'] = Variable<String>(standardPillType.value);
    }
    if (darkMode.present) {
      map['dark_mode'] = Variable<bool>(darkMode.value);
    }
    if (refillReminder.present) {
      map['refill_reminder'] = Variable<int>(refillReminder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('userName: $userName, ')
          ..write('standardPillType: $standardPillType, ')
          ..write('darkMode: $darkMode, ')
          ..write('refillReminder: $refillReminder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PrescriptionsTable extends Prescriptions
    with TableInfo<$PrescriptionsTable, Prescription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrescriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _doseDescriptionMeta =
      const VerificationMeta('doseDescription');
  @override
  late final GeneratedColumn<String> doseDescription = GeneratedColumn<String>(
      'dose_description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
      'stock', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _doseIntervalMeta =
      const VerificationMeta('doseInterval');
  @override
  late final GeneratedColumn<int> doseInterval = GeneratedColumn<int>(
      'dose_interval', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isContinuousMeta =
      const VerificationMeta('isContinuous');
  @override
  late final GeneratedColumn<bool> isContinuous = GeneratedColumn<bool>(
      'is_continuous', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_continuous" IN (0, 1))'));
  static const VerificationMeta _durationTreatmentMeta =
      const VerificationMeta('durationTreatment');
  @override
  late final GeneratedColumn<int> durationTreatment = GeneratedColumn<int>(
      'duration_treatment', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _unitTreatmentMeta =
      const VerificationMeta('unitTreatment');
  @override
  late final GeneratedColumn<String> unitTreatment = GeneratedColumn<String>(
      'unit_treatment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _firstDoseTimeMeta =
      const VerificationMeta('firstDoseTime');
  @override
  late final GeneratedColumn<DateTime> firstDoseTime =
      GeneratedColumn<DateTime>('first_dose_time', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        doseDescription,
        type,
        stock,
        doseInterval,
        isContinuous,
        durationTreatment,
        unitTreatment,
        firstDoseTime,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prescriptions';
  @override
  VerificationContext validateIntegrity(Insertable<Prescription> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dose_description')) {
      context.handle(
          _doseDescriptionMeta,
          doseDescription.isAcceptableOrUnknown(
              data['dose_description']!, _doseDescriptionMeta));
    } else if (isInserting) {
      context.missing(_doseDescriptionMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('stock')) {
      context.handle(
          _stockMeta, stock.isAcceptableOrUnknown(data['stock']!, _stockMeta));
    } else if (isInserting) {
      context.missing(_stockMeta);
    }
    if (data.containsKey('dose_interval')) {
      context.handle(
          _doseIntervalMeta,
          doseInterval.isAcceptableOrUnknown(
              data['dose_interval']!, _doseIntervalMeta));
    } else if (isInserting) {
      context.missing(_doseIntervalMeta);
    }
    if (data.containsKey('is_continuous')) {
      context.handle(
          _isContinuousMeta,
          isContinuous.isAcceptableOrUnknown(
              data['is_continuous']!, _isContinuousMeta));
    } else if (isInserting) {
      context.missing(_isContinuousMeta);
    }
    if (data.containsKey('duration_treatment')) {
      context.handle(
          _durationTreatmentMeta,
          durationTreatment.isAcceptableOrUnknown(
              data['duration_treatment']!, _durationTreatmentMeta));
    }
    if (data.containsKey('unit_treatment')) {
      context.handle(
          _unitTreatmentMeta,
          unitTreatment.isAcceptableOrUnknown(
              data['unit_treatment']!, _unitTreatmentMeta));
    }
    if (data.containsKey('first_dose_time')) {
      context.handle(
          _firstDoseTimeMeta,
          firstDoseTime.isAcceptableOrUnknown(
              data['first_dose_time']!, _firstDoseTimeMeta));
    } else if (isInserting) {
      context.missing(_firstDoseTimeMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Prescription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Prescription(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      doseDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}dose_description'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      stock: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock'])!,
      doseInterval: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dose_interval'])!,
      isContinuous: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_continuous'])!,
      durationTreatment: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_treatment']),
      unitTreatment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit_treatment']),
      firstDoseTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}first_dose_time'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PrescriptionsTable createAlias(String alias) {
    return $PrescriptionsTable(attachedDatabase, alias);
  }
}

class Prescription extends DataClass implements Insertable<Prescription> {
  final int id;
  final String name;
  final String doseDescription;
  final String type;
  final int stock;
  final int doseInterval;
  final bool isContinuous;
  final int? durationTreatment;
  final String? unitTreatment;
  final DateTime firstDoseTime;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Prescription(
      {required this.id,
      required this.name,
      required this.doseDescription,
      required this.type,
      required this.stock,
      required this.doseInterval,
      required this.isContinuous,
      this.durationTreatment,
      this.unitTreatment,
      required this.firstDoseTime,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['dose_description'] = Variable<String>(doseDescription);
    map['type'] = Variable<String>(type);
    map['stock'] = Variable<int>(stock);
    map['dose_interval'] = Variable<int>(doseInterval);
    map['is_continuous'] = Variable<bool>(isContinuous);
    if (!nullToAbsent || durationTreatment != null) {
      map['duration_treatment'] = Variable<int>(durationTreatment);
    }
    if (!nullToAbsent || unitTreatment != null) {
      map['unit_treatment'] = Variable<String>(unitTreatment);
    }
    map['first_dose_time'] = Variable<DateTime>(firstDoseTime);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PrescriptionsCompanion toCompanion(bool nullToAbsent) {
    return PrescriptionsCompanion(
      id: Value(id),
      name: Value(name),
      doseDescription: Value(doseDescription),
      type: Value(type),
      stock: Value(stock),
      doseInterval: Value(doseInterval),
      isContinuous: Value(isContinuous),
      durationTreatment: durationTreatment == null && nullToAbsent
          ? const Value.absent()
          : Value(durationTreatment),
      unitTreatment: unitTreatment == null && nullToAbsent
          ? const Value.absent()
          : Value(unitTreatment),
      firstDoseTime: Value(firstDoseTime),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Prescription.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Prescription(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      doseDescription: serializer.fromJson<String>(json['doseDescription']),
      type: serializer.fromJson<String>(json['type']),
      stock: serializer.fromJson<int>(json['stock']),
      doseInterval: serializer.fromJson<int>(json['doseInterval']),
      isContinuous: serializer.fromJson<bool>(json['isContinuous']),
      durationTreatment: serializer.fromJson<int?>(json['durationTreatment']),
      unitTreatment: serializer.fromJson<String?>(json['unitTreatment']),
      firstDoseTime: serializer.fromJson<DateTime>(json['firstDoseTime']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'doseDescription': serializer.toJson<String>(doseDescription),
      'type': serializer.toJson<String>(type),
      'stock': serializer.toJson<int>(stock),
      'doseInterval': serializer.toJson<int>(doseInterval),
      'isContinuous': serializer.toJson<bool>(isContinuous),
      'durationTreatment': serializer.toJson<int?>(durationTreatment),
      'unitTreatment': serializer.toJson<String?>(unitTreatment),
      'firstDoseTime': serializer.toJson<DateTime>(firstDoseTime),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Prescription copyWith(
          {int? id,
          String? name,
          String? doseDescription,
          String? type,
          int? stock,
          int? doseInterval,
          bool? isContinuous,
          Value<int?> durationTreatment = const Value.absent(),
          Value<String?> unitTreatment = const Value.absent(),
          DateTime? firstDoseTime,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Prescription(
        id: id ?? this.id,
        name: name ?? this.name,
        doseDescription: doseDescription ?? this.doseDescription,
        type: type ?? this.type,
        stock: stock ?? this.stock,
        doseInterval: doseInterval ?? this.doseInterval,
        isContinuous: isContinuous ?? this.isContinuous,
        durationTreatment: durationTreatment.present
            ? durationTreatment.value
            : this.durationTreatment,
        unitTreatment:
            unitTreatment.present ? unitTreatment.value : this.unitTreatment,
        firstDoseTime: firstDoseTime ?? this.firstDoseTime,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Prescription copyWithCompanion(PrescriptionsCompanion data) {
    return Prescription(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      doseDescription: data.doseDescription.present
          ? data.doseDescription.value
          : this.doseDescription,
      type: data.type.present ? data.type.value : this.type,
      stock: data.stock.present ? data.stock.value : this.stock,
      doseInterval: data.doseInterval.present
          ? data.doseInterval.value
          : this.doseInterval,
      isContinuous: data.isContinuous.present
          ? data.isContinuous.value
          : this.isContinuous,
      durationTreatment: data.durationTreatment.present
          ? data.durationTreatment.value
          : this.durationTreatment,
      unitTreatment: data.unitTreatment.present
          ? data.unitTreatment.value
          : this.unitTreatment,
      firstDoseTime: data.firstDoseTime.present
          ? data.firstDoseTime.value
          : this.firstDoseTime,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Prescription(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('doseDescription: $doseDescription, ')
          ..write('type: $type, ')
          ..write('stock: $stock, ')
          ..write('doseInterval: $doseInterval, ')
          ..write('isContinuous: $isContinuous, ')
          ..write('durationTreatment: $durationTreatment, ')
          ..write('unitTreatment: $unitTreatment, ')
          ..write('firstDoseTime: $firstDoseTime, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      doseDescription,
      type,
      stock,
      doseInterval,
      isContinuous,
      durationTreatment,
      unitTreatment,
      firstDoseTime,
      notes,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Prescription &&
          other.id == this.id &&
          other.name == this.name &&
          other.doseDescription == this.doseDescription &&
          other.type == this.type &&
          other.stock == this.stock &&
          other.doseInterval == this.doseInterval &&
          other.isContinuous == this.isContinuous &&
          other.durationTreatment == this.durationTreatment &&
          other.unitTreatment == this.unitTreatment &&
          other.firstDoseTime == this.firstDoseTime &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PrescriptionsCompanion extends UpdateCompanion<Prescription> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> doseDescription;
  final Value<String> type;
  final Value<int> stock;
  final Value<int> doseInterval;
  final Value<bool> isContinuous;
  final Value<int?> durationTreatment;
  final Value<String?> unitTreatment;
  final Value<DateTime> firstDoseTime;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PrescriptionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.doseDescription = const Value.absent(),
    this.type = const Value.absent(),
    this.stock = const Value.absent(),
    this.doseInterval = const Value.absent(),
    this.isContinuous = const Value.absent(),
    this.durationTreatment = const Value.absent(),
    this.unitTreatment = const Value.absent(),
    this.firstDoseTime = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PrescriptionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String doseDescription,
    required String type,
    required int stock,
    required int doseInterval,
    required bool isContinuous,
    this.durationTreatment = const Value.absent(),
    this.unitTreatment = const Value.absent(),
    required DateTime firstDoseTime,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : name = Value(name),
        doseDescription = Value(doseDescription),
        type = Value(type),
        stock = Value(stock),
        doseInterval = Value(doseInterval),
        isContinuous = Value(isContinuous),
        firstDoseTime = Value(firstDoseTime);
  static Insertable<Prescription> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? doseDescription,
    Expression<String>? type,
    Expression<int>? stock,
    Expression<int>? doseInterval,
    Expression<bool>? isContinuous,
    Expression<int>? durationTreatment,
    Expression<String>? unitTreatment,
    Expression<DateTime>? firstDoseTime,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (doseDescription != null) 'dose_description': doseDescription,
      if (type != null) 'type': type,
      if (stock != null) 'stock': stock,
      if (doseInterval != null) 'dose_interval': doseInterval,
      if (isContinuous != null) 'is_continuous': isContinuous,
      if (durationTreatment != null) 'duration_treatment': durationTreatment,
      if (unitTreatment != null) 'unit_treatment': unitTreatment,
      if (firstDoseTime != null) 'first_dose_time': firstDoseTime,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PrescriptionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? doseDescription,
      Value<String>? type,
      Value<int>? stock,
      Value<int>? doseInterval,
      Value<bool>? isContinuous,
      Value<int?>? durationTreatment,
      Value<String?>? unitTreatment,
      Value<DateTime>? firstDoseTime,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return PrescriptionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      doseDescription: doseDescription ?? this.doseDescription,
      type: type ?? this.type,
      stock: stock ?? this.stock,
      doseInterval: doseInterval ?? this.doseInterval,
      isContinuous: isContinuous ?? this.isContinuous,
      durationTreatment: durationTreatment ?? this.durationTreatment,
      unitTreatment: unitTreatment ?? this.unitTreatment,
      firstDoseTime: firstDoseTime ?? this.firstDoseTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (doseDescription.present) {
      map['dose_description'] = Variable<String>(doseDescription.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (doseInterval.present) {
      map['dose_interval'] = Variable<int>(doseInterval.value);
    }
    if (isContinuous.present) {
      map['is_continuous'] = Variable<bool>(isContinuous.value);
    }
    if (durationTreatment.present) {
      map['duration_treatment'] = Variable<int>(durationTreatment.value);
    }
    if (unitTreatment.present) {
      map['unit_treatment'] = Variable<String>(unitTreatment.value);
    }
    if (firstDoseTime.present) {
      map['first_dose_time'] = Variable<DateTime>(firstDoseTime.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrescriptionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('doseDescription: $doseDescription, ')
          ..write('type: $type, ')
          ..write('stock: $stock, ')
          ..write('doseInterval: $doseInterval, ')
          ..write('isContinuous: $isContinuous, ')
          ..write('durationTreatment: $durationTreatment, ')
          ..write('unitTreatment: $unitTreatment, ')
          ..write('firstDoseTime: $firstDoseTime, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DoseEventsTable extends DoseEvents
    with TableInfo<$DoseEventsTable, DoseEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DoseEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _prescriptionIdMeta =
      const VerificationMeta('prescriptionId');
  @override
  late final GeneratedColumn<int> prescriptionId = GeneratedColumn<int>(
      'prescription_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES prescriptions (id) ON DELETE CASCADE'));
  static const VerificationMeta _scheduledTimeMeta =
      const VerificationMeta('scheduledTime');
  @override
  late final GeneratedColumn<DateTime> scheduledTime =
      GeneratedColumn<DateTime>('scheduled_time', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _takenTimeMeta =
      const VerificationMeta('takenTime');
  @override
  late final GeneratedColumn<DateTime> takenTime = GeneratedColumn<DateTime>(
      'taken_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<DoseStatus, int> status =
      GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(0))
          .withConverter<DoseStatus>($DoseEventsTable.$converterstatus);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        prescriptionId,
        scheduledTime,
        takenTime,
        status,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dose_events';
  @override
  VerificationContext validateIntegrity(Insertable<DoseEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('prescription_id')) {
      context.handle(
          _prescriptionIdMeta,
          prescriptionId.isAcceptableOrUnknown(
              data['prescription_id']!, _prescriptionIdMeta));
    } else if (isInserting) {
      context.missing(_prescriptionIdMeta);
    }
    if (data.containsKey('scheduled_time')) {
      context.handle(
          _scheduledTimeMeta,
          scheduledTime.isAcceptableOrUnknown(
              data['scheduled_time']!, _scheduledTimeMeta));
    } else if (isInserting) {
      context.missing(_scheduledTimeMeta);
    }
    if (data.containsKey('taken_time')) {
      context.handle(_takenTimeMeta,
          takenTime.isAcceptableOrUnknown(data['taken_time']!, _takenTimeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DoseEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DoseEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      prescriptionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}prescription_id'])!,
      scheduledTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}scheduled_time'])!,
      takenTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}taken_time']),
      status: $DoseEventsTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DoseEventsTable createAlias(String alias) {
    return $DoseEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DoseStatus, int, int> $converterstatus =
      const EnumIndexConverter<DoseStatus>(DoseStatus.values);
}

class DoseEvent extends DataClass implements Insertable<DoseEvent> {
  final int id;
  final int prescriptionId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final DoseStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DoseEvent(
      {required this.id,
      required this.prescriptionId,
      required this.scheduledTime,
      this.takenTime,
      required this.status,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['prescription_id'] = Variable<int>(prescriptionId);
    map['scheduled_time'] = Variable<DateTime>(scheduledTime);
    if (!nullToAbsent || takenTime != null) {
      map['taken_time'] = Variable<DateTime>(takenTime);
    }
    {
      map['status'] =
          Variable<int>($DoseEventsTable.$converterstatus.toSql(status));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DoseEventsCompanion toCompanion(bool nullToAbsent) {
    return DoseEventsCompanion(
      id: Value(id),
      prescriptionId: Value(prescriptionId),
      scheduledTime: Value(scheduledTime),
      takenTime: takenTime == null && nullToAbsent
          ? const Value.absent()
          : Value(takenTime),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DoseEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DoseEvent(
      id: serializer.fromJson<int>(json['id']),
      prescriptionId: serializer.fromJson<int>(json['prescriptionId']),
      scheduledTime: serializer.fromJson<DateTime>(json['scheduledTime']),
      takenTime: serializer.fromJson<DateTime?>(json['takenTime']),
      status: $DoseEventsTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'prescriptionId': serializer.toJson<int>(prescriptionId),
      'scheduledTime': serializer.toJson<DateTime>(scheduledTime),
      'takenTime': serializer.toJson<DateTime?>(takenTime),
      'status': serializer
          .toJson<int>($DoseEventsTable.$converterstatus.toJson(status)),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DoseEvent copyWith(
          {int? id,
          int? prescriptionId,
          DateTime? scheduledTime,
          Value<DateTime?> takenTime = const Value.absent(),
          DoseStatus? status,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DoseEvent(
        id: id ?? this.id,
        prescriptionId: prescriptionId ?? this.prescriptionId,
        scheduledTime: scheduledTime ?? this.scheduledTime,
        takenTime: takenTime.present ? takenTime.value : this.takenTime,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DoseEvent copyWithCompanion(DoseEventsCompanion data) {
    return DoseEvent(
      id: data.id.present ? data.id.value : this.id,
      prescriptionId: data.prescriptionId.present
          ? data.prescriptionId.value
          : this.prescriptionId,
      scheduledTime: data.scheduledTime.present
          ? data.scheduledTime.value
          : this.scheduledTime,
      takenTime: data.takenTime.present ? data.takenTime.value : this.takenTime,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DoseEvent(')
          ..write('id: $id, ')
          ..write('prescriptionId: $prescriptionId, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('takenTime: $takenTime, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, prescriptionId, scheduledTime, takenTime,
      status, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DoseEvent &&
          other.id == this.id &&
          other.prescriptionId == this.prescriptionId &&
          other.scheduledTime == this.scheduledTime &&
          other.takenTime == this.takenTime &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DoseEventsCompanion extends UpdateCompanion<DoseEvent> {
  final Value<int> id;
  final Value<int> prescriptionId;
  final Value<DateTime> scheduledTime;
  final Value<DateTime?> takenTime;
  final Value<DoseStatus> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DoseEventsCompanion({
    this.id = const Value.absent(),
    this.prescriptionId = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.takenTime = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DoseEventsCompanion.insert({
    this.id = const Value.absent(),
    required int prescriptionId,
    required DateTime scheduledTime,
    this.takenTime = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : prescriptionId = Value(prescriptionId),
        scheduledTime = Value(scheduledTime);
  static Insertable<DoseEvent> custom({
    Expression<int>? id,
    Expression<int>? prescriptionId,
    Expression<DateTime>? scheduledTime,
    Expression<DateTime>? takenTime,
    Expression<int>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (prescriptionId != null) 'prescription_id': prescriptionId,
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
      if (takenTime != null) 'taken_time': takenTime,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DoseEventsCompanion copyWith(
      {Value<int>? id,
      Value<int>? prescriptionId,
      Value<DateTime>? scheduledTime,
      Value<DateTime?>? takenTime,
      Value<DoseStatus>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return DoseEventsCompanion(
      id: id ?? this.id,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (prescriptionId.present) {
      map['prescription_id'] = Variable<int>(prescriptionId.value);
    }
    if (scheduledTime.present) {
      map['scheduled_time'] = Variable<DateTime>(scheduledTime.value);
    }
    if (takenTime.present) {
      map['taken_time'] = Variable<DateTime>(takenTime.value);
    }
    if (status.present) {
      map['status'] =
          Variable<int>($DoseEventsTable.$converterstatus.toSql(status.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DoseEventsCompanion(')
          ..write('id: $id, ')
          ..write('prescriptionId: $prescriptionId, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('takenTime: $takenTime, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $PrescriptionsTable prescriptions = $PrescriptionsTable(this);
  late final $DoseEventsTable doseEvents = $DoseEventsTable(this);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final PrescriptionsDao prescriptionsDao =
      PrescriptionsDao(this as AppDatabase);
  late final DoseEventsDao doseEventsDao = DoseEventsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [settings, prescriptions, doseEvents];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('prescriptions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('dose_events', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<String?> userName,
  Value<String?> standardPillType,
  Value<bool> darkMode,
  Value<int> refillReminder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<String?> userName,
  Value<String?> standardPillType,
  Value<bool> darkMode,
  Value<int> refillReminder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userName => $composableBuilder(
      column: $table.userName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get standardPillType => $composableBuilder(
      column: $table.standardPillType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get darkMode => $composableBuilder(
      column: $table.darkMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get refillReminder => $composableBuilder(
      column: $table.refillReminder,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userName => $composableBuilder(
      column: $table.userName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get standardPillType => $composableBuilder(
      column: $table.standardPillType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get darkMode => $composableBuilder(
      column: $table.darkMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get refillReminder => $composableBuilder(
      column: $table.refillReminder,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<String> get standardPillType => $composableBuilder(
      column: $table.standardPillType, builder: (column) => column);

  GeneratedColumn<bool> get darkMode =>
      $composableBuilder(column: $table.darkMode, builder: (column) => column);

  GeneratedColumn<int> get refillReminder => $composableBuilder(
      column: $table.refillReminder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> userName = const Value.absent(),
            Value<String?> standardPillType = const Value.absent(),
            Value<bool> darkMode = const Value.absent(),
            Value<int> refillReminder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SettingsCompanion(
            id: id,
            userName: userName,
            standardPillType: standardPillType,
            darkMode: darkMode,
            refillReminder: refillReminder,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> userName = const Value.absent(),
            Value<String?> standardPillType = const Value.absent(),
            Value<bool> darkMode = const Value.absent(),
            Value<int> refillReminder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            id: id,
            userName: userName,
            standardPillType: standardPillType,
            darkMode: darkMode,
            refillReminder: refillReminder,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;
typedef $$PrescriptionsTableCreateCompanionBuilder = PrescriptionsCompanion
    Function({
  Value<int> id,
  required String name,
  required String doseDescription,
  required String type,
  required int stock,
  required int doseInterval,
  required bool isContinuous,
  Value<int?> durationTreatment,
  Value<String?> unitTreatment,
  required DateTime firstDoseTime,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$PrescriptionsTableUpdateCompanionBuilder = PrescriptionsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> doseDescription,
  Value<String> type,
  Value<int> stock,
  Value<int> doseInterval,
  Value<bool> isContinuous,
  Value<int?> durationTreatment,
  Value<String?> unitTreatment,
  Value<DateTime> firstDoseTime,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$PrescriptionsTableReferences
    extends BaseReferences<_$AppDatabase, $PrescriptionsTable, Prescription> {
  $$PrescriptionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DoseEventsTable, List<DoseEvent>>
      _doseEventsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.doseEvents,
              aliasName: $_aliasNameGenerator(
                  db.prescriptions.id, db.doseEvents.prescriptionId));

  $$DoseEventsTableProcessedTableManager get doseEventsRefs {
    final manager = $$DoseEventsTableTableManager($_db, $_db.doseEvents)
        .filter((f) => f.prescriptionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_doseEventsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PrescriptionsTableFilterComposer
    extends Composer<_$AppDatabase, $PrescriptionsTable> {
  $$PrescriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get doseDescription => $composableBuilder(
      column: $table.doseDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stock => $composableBuilder(
      column: $table.stock, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get doseInterval => $composableBuilder(
      column: $table.doseInterval, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isContinuous => $composableBuilder(
      column: $table.isContinuous, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationTreatment => $composableBuilder(
      column: $table.durationTreatment,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unitTreatment => $composableBuilder(
      column: $table.unitTreatment, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get firstDoseTime => $composableBuilder(
      column: $table.firstDoseTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> doseEventsRefs(
      Expression<bool> Function($$DoseEventsTableFilterComposer f) f) {
    final $$DoseEventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.doseEvents,
        getReferencedColumn: (t) => t.prescriptionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DoseEventsTableFilterComposer(
              $db: $db,
              $table: $db.doseEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PrescriptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrescriptionsTable> {
  $$PrescriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get doseDescription => $composableBuilder(
      column: $table.doseDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stock => $composableBuilder(
      column: $table.stock, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get doseInterval => $composableBuilder(
      column: $table.doseInterval,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isContinuous => $composableBuilder(
      column: $table.isContinuous,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationTreatment => $composableBuilder(
      column: $table.durationTreatment,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unitTreatment => $composableBuilder(
      column: $table.unitTreatment,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get firstDoseTime => $composableBuilder(
      column: $table.firstDoseTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PrescriptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrescriptionsTable> {
  $$PrescriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get doseDescription => $composableBuilder(
      column: $table.doseDescription, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<int> get doseInterval => $composableBuilder(
      column: $table.doseInterval, builder: (column) => column);

  GeneratedColumn<bool> get isContinuous => $composableBuilder(
      column: $table.isContinuous, builder: (column) => column);

  GeneratedColumn<int> get durationTreatment => $composableBuilder(
      column: $table.durationTreatment, builder: (column) => column);

  GeneratedColumn<String> get unitTreatment => $composableBuilder(
      column: $table.unitTreatment, builder: (column) => column);

  GeneratedColumn<DateTime> get firstDoseTime => $composableBuilder(
      column: $table.firstDoseTime, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> doseEventsRefs<T extends Object>(
      Expression<T> Function($$DoseEventsTableAnnotationComposer a) f) {
    final $$DoseEventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.doseEvents,
        getReferencedColumn: (t) => t.prescriptionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DoseEventsTableAnnotationComposer(
              $db: $db,
              $table: $db.doseEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PrescriptionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PrescriptionsTable,
    Prescription,
    $$PrescriptionsTableFilterComposer,
    $$PrescriptionsTableOrderingComposer,
    $$PrescriptionsTableAnnotationComposer,
    $$PrescriptionsTableCreateCompanionBuilder,
    $$PrescriptionsTableUpdateCompanionBuilder,
    (Prescription, $$PrescriptionsTableReferences),
    Prescription,
    PrefetchHooks Function({bool doseEventsRefs})> {
  $$PrescriptionsTableTableManager(_$AppDatabase db, $PrescriptionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrescriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrescriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrescriptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> doseDescription = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> stock = const Value.absent(),
            Value<int> doseInterval = const Value.absent(),
            Value<bool> isContinuous = const Value.absent(),
            Value<int?> durationTreatment = const Value.absent(),
            Value<String?> unitTreatment = const Value.absent(),
            Value<DateTime> firstDoseTime = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PrescriptionsCompanion(
            id: id,
            name: name,
            doseDescription: doseDescription,
            type: type,
            stock: stock,
            doseInterval: doseInterval,
            isContinuous: isContinuous,
            durationTreatment: durationTreatment,
            unitTreatment: unitTreatment,
            firstDoseTime: firstDoseTime,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String doseDescription,
            required String type,
            required int stock,
            required int doseInterval,
            required bool isContinuous,
            Value<int?> durationTreatment = const Value.absent(),
            Value<String?> unitTreatment = const Value.absent(),
            required DateTime firstDoseTime,
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PrescriptionsCompanion.insert(
            id: id,
            name: name,
            doseDescription: doseDescription,
            type: type,
            stock: stock,
            doseInterval: doseInterval,
            isContinuous: isContinuous,
            durationTreatment: durationTreatment,
            unitTreatment: unitTreatment,
            firstDoseTime: firstDoseTime,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PrescriptionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({doseEventsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (doseEventsRefs) db.doseEvents],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (doseEventsRefs)
                    await $_getPrefetchedData<Prescription, $PrescriptionsTable,
                            DoseEvent>(
                        currentTable: table,
                        referencedTable: $$PrescriptionsTableReferences
                            ._doseEventsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PrescriptionsTableReferences(db, table, p0)
                                .doseEventsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.prescriptionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PrescriptionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PrescriptionsTable,
    Prescription,
    $$PrescriptionsTableFilterComposer,
    $$PrescriptionsTableOrderingComposer,
    $$PrescriptionsTableAnnotationComposer,
    $$PrescriptionsTableCreateCompanionBuilder,
    $$PrescriptionsTableUpdateCompanionBuilder,
    (Prescription, $$PrescriptionsTableReferences),
    Prescription,
    PrefetchHooks Function({bool doseEventsRefs})>;
typedef $$DoseEventsTableCreateCompanionBuilder = DoseEventsCompanion Function({
  Value<int> id,
  required int prescriptionId,
  required DateTime scheduledTime,
  Value<DateTime?> takenTime,
  Value<DoseStatus> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$DoseEventsTableUpdateCompanionBuilder = DoseEventsCompanion Function({
  Value<int> id,
  Value<int> prescriptionId,
  Value<DateTime> scheduledTime,
  Value<DateTime?> takenTime,
  Value<DoseStatus> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$DoseEventsTableReferences
    extends BaseReferences<_$AppDatabase, $DoseEventsTable, DoseEvent> {
  $$DoseEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PrescriptionsTable _prescriptionIdTable(_$AppDatabase db) =>
      db.prescriptions.createAlias($_aliasNameGenerator(
          db.doseEvents.prescriptionId, db.prescriptions.id));

  $$PrescriptionsTableProcessedTableManager get prescriptionId {
    final $_column = $_itemColumn<int>('prescription_id')!;

    final manager = $$PrescriptionsTableTableManager($_db, $_db.prescriptions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_prescriptionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DoseEventsTableFilterComposer
    extends Composer<_$AppDatabase, $DoseEventsTable> {
  $$DoseEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledTime => $composableBuilder(
      column: $table.scheduledTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get takenTime => $composableBuilder(
      column: $table.takenTime, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DoseStatus, DoseStatus, int> get status =>
      $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$PrescriptionsTableFilterComposer get prescriptionId {
    final $$PrescriptionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.prescriptionId,
        referencedTable: $db.prescriptions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PrescriptionsTableFilterComposer(
              $db: $db,
              $table: $db.prescriptions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DoseEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $DoseEventsTable> {
  $$DoseEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledTime => $composableBuilder(
      column: $table.scheduledTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get takenTime => $composableBuilder(
      column: $table.takenTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$PrescriptionsTableOrderingComposer get prescriptionId {
    final $$PrescriptionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.prescriptionId,
        referencedTable: $db.prescriptions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PrescriptionsTableOrderingComposer(
              $db: $db,
              $table: $db.prescriptions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DoseEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DoseEventsTable> {
  $$DoseEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledTime => $composableBuilder(
      column: $table.scheduledTime, builder: (column) => column);

  GeneratedColumn<DateTime> get takenTime =>
      $composableBuilder(column: $table.takenTime, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DoseStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PrescriptionsTableAnnotationComposer get prescriptionId {
    final $$PrescriptionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.prescriptionId,
        referencedTable: $db.prescriptions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PrescriptionsTableAnnotationComposer(
              $db: $db,
              $table: $db.prescriptions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DoseEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DoseEventsTable,
    DoseEvent,
    $$DoseEventsTableFilterComposer,
    $$DoseEventsTableOrderingComposer,
    $$DoseEventsTableAnnotationComposer,
    $$DoseEventsTableCreateCompanionBuilder,
    $$DoseEventsTableUpdateCompanionBuilder,
    (DoseEvent, $$DoseEventsTableReferences),
    DoseEvent,
    PrefetchHooks Function({bool prescriptionId})> {
  $$DoseEventsTableTableManager(_$AppDatabase db, $DoseEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DoseEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DoseEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DoseEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> prescriptionId = const Value.absent(),
            Value<DateTime> scheduledTime = const Value.absent(),
            Value<DateTime?> takenTime = const Value.absent(),
            Value<DoseStatus> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DoseEventsCompanion(
            id: id,
            prescriptionId: prescriptionId,
            scheduledTime: scheduledTime,
            takenTime: takenTime,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int prescriptionId,
            required DateTime scheduledTime,
            Value<DateTime?> takenTime = const Value.absent(),
            Value<DoseStatus> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              DoseEventsCompanion.insert(
            id: id,
            prescriptionId: prescriptionId,
            scheduledTime: scheduledTime,
            takenTime: takenTime,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DoseEventsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({prescriptionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (prescriptionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.prescriptionId,
                    referencedTable:
                        $$DoseEventsTableReferences._prescriptionIdTable(db),
                    referencedColumn:
                        $$DoseEventsTableReferences._prescriptionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DoseEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DoseEventsTable,
    DoseEvent,
    $$DoseEventsTableFilterComposer,
    $$DoseEventsTableOrderingComposer,
    $$DoseEventsTableAnnotationComposer,
    $$DoseEventsTableCreateCompanionBuilder,
    $$DoseEventsTableUpdateCompanionBuilder,
    (DoseEvent, $$DoseEventsTableReferences),
    DoseEvent,
    PrefetchHooks Function({bool prescriptionId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$PrescriptionsTableTableManager get prescriptions =>
      $$PrescriptionsTableTableManager(_db, _db.prescriptions);
  $$DoseEventsTableTableManager get doseEvents =>
      $$DoseEventsTableTableManager(_db, _db.doseEvents);
}

mixin _$SettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SettingsTable get settings => attachedDatabase.settings;
}
mixin _$PrescriptionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $PrescriptionsTable get prescriptions => attachedDatabase.prescriptions;
}
mixin _$DoseEventsDaoMixin on DatabaseAccessor<AppDatabase> {
  $PrescriptionsTable get prescriptions => attachedDatabase.prescriptions;
  $DoseEventsTable get doseEvents => attachedDatabase.doseEvents;
}
