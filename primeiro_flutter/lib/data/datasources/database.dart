// lib/data/datasources/database.dart

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

  IntColumn get prescriptionId =>
      integer().references(Prescriptions, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get scheduledTime => dateTime()();
  DateTimeColumn get takenTime => dateTime().nullable()();

  IntColumn get status => intEnum<DoseStatus>()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(tables: [Settings, Prescriptions, DoseEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // REMOÇÃO DO CÓDIGO DUPLICADO
  @override
  int get schemaVersion => 1;

  // Esta função vai buscar todos os eventos de dose para um dia específico.
  Future<List<DoseEventWithPrescription>> getDoseEventsForDay(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final query = select(doseEvents).join([
      innerJoin(
        prescriptions,
        prescriptions.id.equalsExp(doseEvents.prescriptionId),
      )
    ]);

    query.where(doseEvents.scheduledTime
        .isBetween(Variable(startOfDay), Variable(endOfDay)));

    return query.map((row) {
      return DoseEventWithPrescription(
        doseEvent: row.readTable(doseEvents),
        prescription: row.readTable(prescriptions),
      );
    }).get();
  }

  // ADICIONADO: Função para atualizar a prescrição
  Future<void> updatePrescription(
      int id, PrescriptionsCompanion newPrescription) {
    return (update(prescriptions)..where((t) => t.id.equals(id)))
        .write(newPrescription);
  }

  Future<Prescription?> getPrescriptionById(int id) {
    return (select(prescriptions)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  // CORRIGIDO: Agora a função exclui eventos a partir do início do dia atual.
  Future<void> deleteDoseEventsForPrescription(int id, DateTime cutOffDate) {
    return (delete(doseEvents)
          ..where((t) => t.prescriptionId.equals(id))
          ..where((t) => t.scheduledTime.isBiggerOrEqualValue(cutOffDate)))
        .go();
  }

  Future<void> deletePrescription(int id) {
    return (delete(prescriptions)..where((t) => t.id.equals(id))).go();
  }

  Future<void> toggleDoseStatus(int doseId, DoseStatus status,
      {DateTime? takenTime}) {
    return (update(doseEvents)..where((t) => t.id.equals(doseId))).write(
      DoseEventsCompanion(
        status: Value(status),
        takenTime: Value(takenTime),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
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
