import 'package:checkpills/domain/entities/medication_entity.dart';
import 'package:checkpills/domain/repositories/medication_repository.dart';

class AddMedicationUseCase {
  final MedicationRepository repository;

  AddMedicationUseCase({required this.repository});

  Future<void> call(MedicationEntity medication) {
    return repository.addMedication(medication);
  }
}
