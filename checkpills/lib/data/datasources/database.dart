import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// Enums e Tabelas continuam como planejado
enum DoseStatus { pendente, tomada, pulada }

@DataClassName('User')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('UserSetting')
class UserSettings extends Table {
  // A id do usuário agora é a chave primária e a ligação com a tabela Users
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();
  
  // As configurações antigas permanecem, exceto userName que está na tabela Users
  TextColumn get standardPillType => text().nullable()();
  BoolColumn get darkMode => boolean().withDefault(const Constant(false))();
  IntColumn get refillReminder => integer().withDefault(const Constant(5))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // Define a chave primária
  @override
  Set<Column> get primaryKey => {userId};
}

@DataClassName('Prescription')
class Prescriptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();
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
  TextColumn get imagePath => text().nullable()();
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

// Combine as tabelas em um banco de dados
@DriftDatabase(tables: [
  Users, // Adicionada
  UserSettings, // Substituiu Settings
  Prescriptions,
  DoseEvents,
], daos: [
  UsersDao, // Adicionado
  UserSettingsDao, // Substituiu SettingsDao
  PrescriptionsDao,
  DoseEventsDao,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  // ADICIONE ESTAS 4 LINHAS:
  UsersDao get usersDao => UsersDao(this);
  UserSettingsDao get userSettingsDao => UserSettingsDao(this);
  PrescriptionsDao get prescriptionsDao => PrescriptionsDao(this);
  DoseEventsDao get doseEventsDao => DoseEventsDao(this);
}

// SUBSTITUA todos os seus DAOs por este bloco de código

// DAO para a nova tabela Users
@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(AppDatabase db) : super(db);
Future<List<User>> getAllUsers() => select(users).get();
  Stream<List<User>> watchAllUsers() => select(users).watch();
  Future<int> addUser(UsersCompanion entry) => into(users).insert(entry);
  Future<int> deleteUser(int id) =>
      (delete(users)..where((t) => t.id.equals(id))).go();
  Future<bool> updateUser(UsersCompanion entry) =>
      update(users).replace(entry);
}

// DAO para a nova tabela UserSettings
@DriftAccessor(tables: [UserSettings])
class UserSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$UserSettingsDaoMixin {
  UserSettingsDao(AppDatabase db) : super(db);

  Stream<UserSetting?> watchSettingsForUser(int userId) {
    return (select(userSettings)..where((t) => t.userId.equals(userId)))
        .watchSingleOrNull();
  }
  
  Future<UserSetting?> getSettingsForUser(int userId) {
    return (select(userSettings)..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
  }

  Future<void> updateSettingsForUser(UserSettingsCompanion entry) {
    return into(userSettings).insertOnConflictUpdate(entry);
  }
}

// DAO de Prescriptions MODIFICADO
@DriftAccessor(tables: [Prescriptions])
class PrescriptionsDao extends DatabaseAccessor<AppDatabase>
    with _$PrescriptionsDaoMixin {
  PrescriptionsDao(AppDatabase db) : super(db);

  // Agora requer um userId
  Stream<List<Prescription>> watchAllPrescriptionsForUser(int userId) =>
      (select(prescriptions)..where((t) => t.userId.equals(userId))).watch();

  Future<int> addPrescription(PrescriptionsCompanion companion) =>
      into(prescriptions).insert(companion);
  Future<bool> updatePrescription(PrescriptionsCompanion companion) =>
      update(prescriptions).replace(companion);
  Future<int> deletePrescription(int id) =>
      (delete(prescriptions)..where((t) => t.id.equals(id))).go();
  Future<Prescription> getPrescriptionById(int id) =>
      (select(prescriptions)..where((t) => t.id.equals(id))).getSingle();
  Future<void> updateStock(int id, int newStock) {
    return (update(prescriptions)..where((t) => t.id.equals(id))).write(
      PrescriptionsCompanion(stock: Value(newStock)),
    );
  }
}

// DAO de DoseEvents MODIFICADO
@DriftAccessor(tables: [DoseEvents, Prescriptions])
class DoseEventsDao extends DatabaseAccessor<AppDatabase>
    with _$DoseEventsDaoMixin {
  DoseEventsDao(AppDatabase db) : super(db);

  // Modificado para filtrar por userId
  Stream<List<DoseEventWithPrescription>> watchDoseEventsForDay(
      int userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final query = select(doseEvents).join([
      innerJoin(
          prescriptions, prescriptions.id.equalsExp(doseEvents.prescriptionId))
    ])
      ..where(prescriptions.userId.equals(userId)) // <- Filtro adicionado
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

  // Modificado para filtrar por userId
  Stream<List<DoseEventWithPrescription>> watchAllDoseEvents(int userId) {
    final query = select(doseEvents).join([
      innerJoin(
          prescriptions, prescriptions.id.equalsExp(doseEvents.prescriptionId))
    ])
      ..where(prescriptions.userId.equals(userId)) // <- Filtro adicionado
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

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

class DoseEventWithPrescription {
  final DoseEvent doseEvent;
  final Prescription prescription;

  DoseEventWithPrescription({
    required this.doseEvent,
    required this.prescription,
  });
}
