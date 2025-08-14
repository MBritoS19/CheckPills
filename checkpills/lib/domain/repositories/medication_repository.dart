import 'package:checkpills/domain/entities/medication.dart';

abstract class MedicationRepository {
  Future<List<Medication>> getTodayMedications(DateTime date);
  Future<void> addMedication(Medication medication);
}
