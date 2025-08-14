import 'package:flutter/foundation.dart';
import 'package:checkpills/domain/entities/medication.dart';
import 'package:checkpills/domain/usecases/add_medication.dart';
import 'package:checkpills/domain/usecases/get_today_medications.dart';

class MedicationHomeViewModel with ChangeNotifier {
  final GetTodayMedications getTodayMedications;
  final AddMedication addMedication;

  List<Medication> _medications = [];
  bool _isLoading = false;

  MedicationHomeViewModel({
    required this.getTodayMedications,
    required this.addMedication,
  });

  List<Medication> get medications => _medications;
  bool get isLoading => _isLoading;

  Future<void> loadMedications() async {
    _isLoading = true;
    notifyListeners();

    _medications = await getTodayMedications(DateTime.now());

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNewMedication(Medication medication) async {
    _isLoading = true;
    notifyListeners();

    await addMedication(medication);
    await loadMedications();

    _isLoading = false;
    notifyListeners();
  }
}
