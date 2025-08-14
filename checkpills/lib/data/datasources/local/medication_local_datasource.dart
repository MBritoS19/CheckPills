import 'package:checkpills/domain/entities/medication.dart';

abstract class MedicationLocalDataSource {
  Future<List<Medication>> getMedicationsByDate(DateTime date);
  Future<void> addMedication(Medication medication);
}

class MedicationLocalDataSourceImpl implements MedicationLocalDataSource {
  @override
  Future<List<Medication>> getMedicationsByDate(DateTime date) {
    // Implementação com Drift/SQLite
    throw UnimplementedError();
  }

  @override
  Future<void> addMedication(Medication medication) {
    // Implementação com Drift/SQLite
    throw UnimplementedError();
  }
}
