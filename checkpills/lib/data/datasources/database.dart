import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// Enums e Tabelas continuam como planeado
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

@DataClassName('Prescription')
class Prescriptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get doseDescription => text()();
  TextColumn get type => text()();
  IntColumn get stock => integer()();
  IntColumn get doseInterval => integer()(); // in minutes
  BoolColumn get isContinuous => boolean()();
  IntColumn get durationTreatment => integer().nullable()();
  TextColumn get unitTreatment => text().nullable()();
  DateTimeColumn get firstDoseTime => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('DoseEvent')
class DoseEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get prescriptionId =>
      integer().references(Prescriptions, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get scheduledTime => dateTime()();
  DateTimeColumn get takenTime => dateTime().nullable()();
  IntColumn get status =>
      intEnum<DoseStatus>().withDefault(const Constant(0))(); // 0 = pendente
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Classe auxiliar para juntar os dados de uma Dose e sua Prescrição
class DoseEventWithPrescription {
  final DoseEvent doseEvent;
  final Prescription prescription;

  DoseEventWithPrescription({
    required this.doseEvent,
    required this.prescription,
  });
}

// A classe AppDatabase agora vai usar DAOs
@DriftDatabase(
    tables: [Settings, Prescriptions, DoseEvents],
    daos: [SettingsDao, PrescriptionsDao, DoseEventsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

// DAO para a tabela DoseEvents
@DriftAccessor(tables: [DoseEvents, Prescriptions])
class DoseEventsDao extends DatabaseAccessor<AppDatabase>
    with _$DoseEventsDaoMixin {
  DoseEventsDao(AppDatabase db) : super(db);

  // A nossa nova função reativa para buscar as doses do dia
  Stream<List<DoseEventWithPrescription>> watchDoseEventsForDay(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final query = select(doseEvents).join([
      innerJoin(
          prescriptions, prescriptions.id.equalsExp(doseEvents.prescriptionId))
    ])
      ..where(doseEvents.scheduledTime.isBetweenValues(startOfDay, endOfDay))
      ..orderBy([OrderingTerm.asc(doseEvents.scheduledTime)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return DoseEventWithPrescription(
          doseEvent: row.readTable(doseEvents),
          prescription: row.readTable(prescriptions),
        );
      }).toList();
    });
  }

  Stream<List<DoseEventWithPrescription>> watchAllDoseEvents() {
    final query = select(doseEvents).join([
      innerJoin(
          prescriptions, prescriptions.id.equalsExp(doseEvents.prescriptionId))
    ])
      ..orderBy([OrderingTerm.asc(doseEvents.scheduledTime)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return DoseEventWithPrescription(
          doseEvent: row.readTable(doseEvents),
          prescription: row.readTable(prescriptions),
        );
      }).toList();
    });
  }

  Future<void> addDoseEvent(DoseEventsCompanion companion) =>
      into(doseEvents).insert(companion);

  Future<void> updateDoseEventStatus(
          int id, DoseStatus newStatus, DateTime? takenTime) =>
      (update(doseEvents)..where((t) => t.id.equals(id))).write(
        DoseEventsCompanion(
          status: Value(newStatus),
          takenTime: Value(takenTime),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> deleteFutureDoseEventsForPrescription(int prescriptionId) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return (delete(doseEvents)
          ..where((t) => t.prescriptionId.equals(prescriptionId))
          ..where((t) => t.scheduledTime.isBiggerOrEqualValue(startOfToday)))
        .go();
  }
}

// DAOs para as outras tabelas (mesmo que ainda não tenham funções customizadas, é uma boa prática criá-los)
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
  Future<Prescription> getPrescriptionById(int id) =>
      (select(prescriptions)..where((t) => t.id.equals(id))).getSingle();
}

@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(AppDatabase db) : super(db);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
