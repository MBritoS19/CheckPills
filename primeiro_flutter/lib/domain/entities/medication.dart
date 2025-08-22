// File path: lib/domain/entities/medication.dart

class Medication {
  final String? id;
  final String name;
  final String dose;
  final String type;
  final int stock;
  final int doseIntervalInHours;
  final int totalDoses;
  // MUDANÇA AQUI: Trocamos String por DateTime
  final DateTime firstDoseTime;
  final String? notes;

  const Medication({
    required this.name,
    required this.dose,
    required this.type,
    required this.stock,
    required this.doseIntervalInHours,
    required this.totalDoses,
    // E AQUI TAMBÉM
    required this.firstDoseTime,
    this.id,
    this.notes,
  });
}
