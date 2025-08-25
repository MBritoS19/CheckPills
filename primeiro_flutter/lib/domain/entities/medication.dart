// File path: lib/domain/entities/medication.dart

class Medication {
  final String? id;
  final String name;
  final String dose;
  final String type;
  final int stock;
  final Duration doseInterval;
  
  // MUDANÇA AQUI: Removemos `totalDoses` e adicionamos os novos campos.
  final bool isContinuous; // Para saber se é de uso contínuo
  final int? treatmentLength; // O número (ex: 7). É opcional (`?`)
  final String? treatmentUnit; // A unidade (ex: "Dias"). É opcional (`?`)

  final DateTime firstDoseTime;
  final String? notes;

  const Medication({
    required this.name,
    required this.dose,
    required this.type,
    required this.stock,
    required this.doseInterval,
    // E AQUI TAMBÉM
    required this.isContinuous,
    this.treatmentLength,
    this.treatmentUnit,
    required this.firstDoseTime,
    this.id,
    this.notes,
  });
}