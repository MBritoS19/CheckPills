// lib/data/datasources/database.dart

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// Enums e Tabelas
enum DoseStatus { pendente, tomada, pulada }

@DataClassName('Setting')
class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get userName => text().nullable()();
  TextColumn get standardPillType => text().nullable()();
  BoolColumn get darkMode => boolean().withDefault(const Constant(false))();
  IntColumn get refillReminder => integer().withDefault(const Constant(5))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Patient')
class Patients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Prescription')
class Prescriptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId =>
      integer().references(Patients, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get doseDescription => text()();
  TextColumn get type => text()();
  IntColumn get stock => integer()();
  IntColumn get doseInterval => integer()(); // in minutes
  BoolColumn get isContinuous => boolean()();
  IntColumn get durationTreatment => integer().nullable()();
  TextColumn get unitTreatment => text().nullable()();
  DateTimeColumn get firstDoseTime => dateTime()();
  IntColumn get remainingStock => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('DoseEvent')
class DoseEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get prescriptionId =>
      integer().references(Prescriptions, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get scheduledTime => dateTime()();
  IntColumn get status =>
      intEnum<DoseStatus>().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Classes de dados para combinar informações
class DoseEventWithPrescription {
  final DoseEvent doseEvent;
  final Prescription prescription;
  DoseEventWithPrescription(this.doseEvent, this.prescription);
}

class DoseEventWithPrescriptionAndPatient {
  final DoseEvent doseEvent;
  final Prescription prescription;
  final Patient patient;
  DoseEventWithPrescriptionAndPatient(
      this.doseEvent, this.prescription, this.patient);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(
    tables: [Settings, Prescriptions, DoseEvents, Patients],
    daos: [SettingsDao, PrescriptionsDao, DoseEventsDao, PatientsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) {
          return m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(patients);
            await m.addColumn(prescriptions, prescriptions.patientId);
          }
        },
      );

  SettingsDao get settingsDao => SettingsDao(this);
  PrescriptionsDao get prescriptionsDao => PrescriptionsDao(this);
  DoseEventsDao get doseEventsDao => DoseEventsDao(this);
  PatientsDao get patientsDao => PatientsDao(this);
}

// DAOs para as tabelas
@DriftAccessor(tables: [DoseEvents, Prescriptions, Patients])
class DoseEventsDao extends DatabaseAccessor<AppDatabase>
    with _$DoseEventsDaoMixin {
  DoseEventsDao(AppDatabase db) : super(db);

  Stream<List<DoseEventWithPrescriptionAndPatient>> watchAllDoseEvents() {
    final query = select(doseEvents).join([
      innerJoin(
        prescriptions,
        prescriptions.id.equalsExp(doseEvents.prescriptionId),
      ),
      innerJoin(
        patients,
        patients.id.equalsExp(prescriptions.patientId),
      )
    ]);

    return query.map((row) {
      return DoseEventWithPrescriptionAndPatient(
        row.readTable(doseEvents),
        row.readTable(prescriptions),
        row.readTable(patients),
      );
    }).watch();
  }

  Stream<List<DoseEventWithPrescriptionAndPatient>> watchDoseEventsForDay(
      DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final nextDay = normalizedDate.add(const Duration(days: 1));

    final query = select(doseEvents).join([
      innerJoin(
        prescriptions,
        prescriptions.id.equalsExp(doseEvents.prescriptionId),
      ),
      innerJoin(
        patients,
        patients.id.equalsExp(prescriptions.patientId),
      )
    ])
      ..where(doseEvents.scheduledTime.isBetweenValues(normalizedDate, nextDay));

    return query.map((row) {
      return DoseEventWithPrescriptionAndPatient(
        row.readTable(doseEvents),
        row.readTable(prescriptions),
        row.readTable(patients),
      );
    }).watch();
  }

  Future<int> addDoseEvent(DoseEventsCompanion companion) =>
      into(doseEvents).insert(companion);

  Future<bool> updateDoseEvent(DoseEventsCompanion companion) =>
      update(doseEvents).replace(companion);

  Future<List<DoseEvent>> getEventsForPrescription(int prescriptionId) =>
      (select(doseEvents)..where((t) => t.prescriptionId.equals(prescriptionId)))
          .get();

  Future<int> deleteEventsForPrescription(int prescriptionId) async {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return (delete(doseEvents)
          ..where((t) => t.prescriptionId.equals(prescriptionId))
          ..where((t) => t.scheduledTime.isBiggerOrEqualValue(startOfToday)))
        .go();
  }
}

@DriftAccessor(tables: [Prescriptions])
class PrescriptionsDao extends DatabaseAccessor<AppDatabase>
    with _$PrescriptionsDaoMixin {
  PrescriptionsDao(AppDatabase db) : super(db);

  Future<List<Prescription>> getAllPrescriptions() =>
      select(prescriptions).get();
  Future<int> addPrescription(PrescriptionsCompanion companion) =>
      into(prescriptions).insert(companion);
  Future<bool> updatePrescription(PrescriptionsCompanion companion) =>
      update(prescriptions).replace(companion);
  Future<int> deletePrescription(int id) =>
      (delete(prescriptions)..where((t) => t.id.equals(id))).go();
  Future<Prescription?> getPrescriptionById(int id) =>
      (select(prescriptions)..where((t) => t.id.equals(id))).getSingleOrNull();
}

@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(AppDatabase db) : super(db);

  Future<Setting?> getSettings() => (select(settings).getSingleOrNull());

  Future<int> saveSettings(SettingsCompanion entry) {
    return into(settings).insertOnConflictUpdate(entry);
  }
}

@DriftAccessor(tables: [Patients])
class PatientsDao extends DatabaseAccessor<AppDatabase>
    with _$PatientsDaoMixin {
  PatientsDao(AppDatabase db) : super(db);

  Future<List<Patient>> getAllPatients() => select(patients).get();
  Future<int> addPatient(PatientsCompanion companion) =>
      into(patients).insert(companion);
}
