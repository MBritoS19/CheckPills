// File path: lib/domain/entities/medication.dart

class Medication {
  final String? id;
  final String name;
  final String dose;
  final int stock;
  final int doseIntervalInHours;
  final int totalDoses;
  final String firstDoseTime;
  final String? notes;

  const Medication({
    required this.name,
    required this.dose,
    required this.stock,
    required this.doseIntervalInHours,
    required this.totalDoses,
    required this.firstDoseTime,
    this.id,
    this.notes,
  });
}
