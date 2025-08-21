import 'package:checkpills/data/datasources/local/medication_local_datasource.dart';
import 'package:checkpills/domain/entities/medication_entity.dart';

class MedicationLocalDataSourceImpl implements MedicationLocalDataSource {
  final List<MedicationEntity> _medications = [];

  @override
  Future<List<MedicationEntity>> getMedications() async {
    return List<MedicationEntity>.from(_medications);
  }

  @override
  Future<void> addMedication(MedicationEntity medication) async {
    _medications.add(medication);
  }

  @override
  Future<void> updateMedication(MedicationEntity medication) async {
    final index = _medications.indexWhere((m) => m.id == medication.id);
    if (index != -1) {
      _medications[index] = medication;
    }
  }

  @override
  Future<void> deleteMedication(String id) async {
    _medications.removeWhere((m) => m.id == id);
  }

  @override
  Future<void> initializeDefaultMedications() async {
    if (_medications.isEmpty) {
      _medications.addAll([
        MedicationEntity(
          id: '1',
          name: 'Dipirona',
          dose: '1 comprimido',
          type: 'Comprimido',
          stock: 30,
          doseIntervalInHours: 8,
          totalDoses: 90,
          firstDoseTime: '08:00',
        ),
        MedicationEntity(
          id: '2',
          name: 'Paracetamol',
          dose: '500mg',
          type: 'Gotas',
          stock: 20,
          doseIntervalInHours: 6,
          totalDoses: 60,
          firstDoseTime: '12:00',
          notes: 'Tomar após a refeição',
        ),
      ]);
    }
  }
}
