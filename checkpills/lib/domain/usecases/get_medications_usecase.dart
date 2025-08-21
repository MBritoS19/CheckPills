import 'package:checkpills/domain/entities/medication_entity.dart';
import 'package:checkpills/domain/repositories/medication_repository.dart';

class GetMedicationsUseCase {
  final MedicationRepository repository;

  GetMedicationsUseCase({required this.repository});

  Future<List<MedicationEntity>> call() {
    return repository.getMedications();
  }
}
