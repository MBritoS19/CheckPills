import 'package:checkpills/data/datasources/local/medication_local_datasource.dart';
import 'package:checkpills/domain/entities/medication_entity.dart';
import 'package:checkpills/domain/repositories/medication_repository.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationLocalDataSource localDataSource;

  MedicationRepositoryImpl({required this.localDataSource});

  @override
  Future<List<MedicationEntity>> getMedications() async {
    return await localDataSource.getMedications();
  }

  @override
  Future<void> addMedication(MedicationEntity medication) async {
    await localDataSource.addMedication(medication);
  }

  @override
  Future<void> updateMedication(MedicationEntity medication) async {
    await localDataSource.updateMedication(medication);
  }

  @override
  Future<void> deleteMedication(String id) async {
    await localDataSource.deleteMedication(id);
  }

  @override
  Future<void> initializeDefaultMedications() async {
    await localDataSource.initializeDefaultMedications();
  }
}
