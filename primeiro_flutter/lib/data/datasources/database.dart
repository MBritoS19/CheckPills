import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ENUM: Como discutimos, criamos um enum para os status da dose.
// Isso torna o nosso código mais seguro e legível.
enum DoseStatus { pendente, tomada, pulada }

// TABELA 1: Settings
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

// TABELA 2: Prescriptions
@DataClassName('Prescription') // Nomeia a classe de dados que será gerada
class Prescriptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get doseDescription => text()();
  TextColumn get type => text()();
  IntColumn get stock => integer()();
  IntColumn get doseInterval => integer()(); // Guardado em minutos
  BoolColumn get isContinuous => boolean()();
  IntColumn get durationTreatment => integer().nullable()();
  TextColumn get unitTreatment => text().nullable()();
  DateTimeColumn get firstDoseTime => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

// TABELA 3: DoseEvents
@DataClassName('DoseEvent')
class DoseEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // CHAVE ESTRANGEIRA: Liga este evento a uma prescrição.
  IntColumn get prescriptionId => integer().references(Prescriptions, #id,
      // REGRA DE EXCLUSÃO: Se uma prescrição for apagada,
      // todas as doses ligadas a ela também serão (exclusão em cascata).
      onDelete: KeyAction.cascade)();
      
  DateTimeColumn get scheduledTime => dateTime()();
  DateTimeColumn get takenTime => dateTime().nullable()();
  
  // Usamos .intEnum() para dizer ao Drift para guardar o nosso enum como um inteiro.
  IntColumn get status => intEnum<DoseStatus>()(); 
  
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}


@DriftDatabase(tables: [Settings, Prescriptions, DoseEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}