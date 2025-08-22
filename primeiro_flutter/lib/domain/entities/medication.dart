// File path: lib/domain/entities/medication.dart

class Medication {
  final String? id;
  final String name;
  final String dose;
  final String type;
  final int stock;
  // MUDANÇA AQUI: Trocamos o int por Duration
  final Duration doseInterval;
  final int totalDoses;
  final DateTime firstDoseTime;
  final String? notes;

  const Medication({
    required this.name,
    required this.dose,
    required this.type,
    required this.stock,
    // E AQUI TAMBÉM
    required this.doseInterval,
    required this.totalDoses,
    required this.firstDoseTime,
    this.id,
    this.notes,
  });
}
