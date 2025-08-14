import 'package:checkpills/domain/entities/medication.dart';
import 'package:checkpills/domain/repositories/medication_repository.dart';
import 'package:checkpills/data/datasources/local/medication_local_datasource.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationLocalDataSource localDataSource;

  MedicationRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Medication>> getTodayMedications(DateTime date) async {
    return await localDataSource.getMedicationsByDate(date);
  }

  @override
  Future<void> addMedication(Medication medication) async {
    return await localDataSource.addMedication(medication);
  }
}
