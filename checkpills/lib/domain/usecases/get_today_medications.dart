import 'package:checkpills/domain/entities/medication.dart';
import 'package:checkpills/domain/repositories/medication_repository.dart';

class GetTodayMedications {
  final MedicationRepository repository;

  GetTodayMedications(this.repository);

  Future<List<Medication>> call(DateTime date) async {
    return await repository.getTodayMedications(date);
  }
}
