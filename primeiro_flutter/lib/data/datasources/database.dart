import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

enum DoseStatus { pendente, tomada, pulada }

class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get userName => text().nullable()();
  TextColumn get standardPillType => text().nullable()();
  BoolColumn get darkMode => boolean().withDefault(const Constant(false))();
  IntColumn get refillReminder => integer().withDefault(const Constant(5))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

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
  IntColumn get doseInterval => integer()();
  BoolColumn get isContinuous => boolean()();
  IntColumn get durationTreatment => integer().nullable()();
  TextColumn get unitTreatment => text().nullable()();
  DateTimeColumn get firstDoseTime => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('DoseEvent')
class DoseEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  IntColumn get prescriptionId => integer().references(Prescriptions, #id,
      onDelete: KeyAction.cascade)();
      
  DateTimeColumn get scheduledTime => dateTime()();
  DateTimeColumn get takenTime => dateTime().nullable()();
  
  IntColumn get status => intEnum<DoseStatus>()(); 
  
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}


@DriftDatabase(tables: [Settings, Prescriptions, DoseEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // NOVO MÉTODO AQUI
  // Esta função vai buscar todos os eventos de dose para um dia específico.
  Future<List<DoseEvent>> getDoseEventsForDay(DateTime date) {
    // Definimos o início do dia (hora 00:00:00)
    final startOfDay = DateTime(date.year, date.month, date.day);
    // Definimos o final do dia (hora 23:59:59)
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    // `select(doseEvents)` inicia a consulta na tabela de DoseEvents.
    // `where(...)` é a cláusula de filtro.
    return (select(doseEvents)
          ..where((row) =>
              // Queremos as linhas onde o `scheduledTime` é MAIOR OU IGUAL ao início do dia
              row.scheduledTime.isBetween(Variable(startOfDay), Variable(endOfDay))))
        .get(); // `.get()` executa a consulta e retorna uma lista.
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}