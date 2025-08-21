import 'package:flutter/foundation.dart';
import 'package:checkpills/domain/entities/medication_entity.dart';
import 'package:checkpills/domain/usecases/get_medications_usecase.dart';
import 'package:checkpills/domain/usecases/add_medication_usecase.dart';
import 'package:checkpills/domain/repositories/medication_repository.dart';

class MedicationProvider with ChangeNotifier {
  final GetMedicationsUseCase getMedicationsUseCase;
  final AddMedicationUseCase addMedicationUseCase;
  final MedicationRepository repository;

  List<MedicationEntity> _medications = [];
  bool _isLoading = false;
  String? _error;

  MedicationProvider({
    required this.getMedicationsUseCase,
    required this.addMedicationUseCase,
    required this.repository,
  });

  List<MedicationEntity> get medications => _medications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    await repository.initializeDefaultMedications();
    await loadMedications();
  }

  Future<void> loadMedications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _medications = await getMedicationsUseCase();
    } catch (e) {
      _error = 'Erro ao carregar medicamentos: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMedication(MedicationEntity medication) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await addMedicationUseCase(medication);
      await loadMedications(); // Recarrega a lista após adicionar
    } catch (e) {
      _error = 'Erro ao adicionar medicamento: $e';
      if (kDebugMode) {
        print(_error);
      }
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
