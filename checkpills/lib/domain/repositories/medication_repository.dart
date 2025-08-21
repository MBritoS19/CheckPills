import 'package:checkpills/domain/entities/medication_entity.dart';

abstract class MedicationRepository {
  Future<List<MedicationEntity>> getMedications();
  Future<void> addMedication(MedicationEntity medication);
  Future<void> updateMedication(MedicationEntity medication);
  Future<void> deleteMedication(String id);
  Future<void> initializeDefaultMedications();
}
