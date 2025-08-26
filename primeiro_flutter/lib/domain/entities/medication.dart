// File path: lib/domain/entities/medication.dart

class Medication {
  final String? id;
  final String name;
  final String dose;
  final String type;
  final int stock;
  final Duration doseInterval;
  
  // MUDANÇA AQUI: Renomeado de `isContinuous` para corresponder ao provider
  final bool isContinuous;
  // Renomeado de `treatmentLength` para `durationTreatment`
  final int? durationTreatment;
  // Renomeado de `treatmentUnit` para `unitTreatment`
  final String? unitTreatment;

  final DateTime firstDoseTime;
  final String? notes;

  const Medication({
    required this.name,
    required this.dose,
    required this.type,
    required this.stock,
    required this.doseInterval,
    required this.isContinuous,
    this.durationTreatment, // Nome atualizado
    this.unitTreatment,   // Nome atualizado
    required this.firstDoseTime,
    this.id,
    this.notes,
  });
}