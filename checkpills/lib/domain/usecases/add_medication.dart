import 'package:checkpills/domain/entities/medication.dart';
import 'package:checkpills/domain/repositories/medication_repository.dart';

class AddMedication {
  final MedicationRepository repository;

  AddMedication(this.repository);

  Future<void> call(Medication medication) async {
    return await repository.addMedication(medication);
  }
}
