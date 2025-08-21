class MedicationEntity {
  final String id;
  final String name;
  final String dose;
  final String type;
  final int stock;
  final int doseIntervalInHours;
  final int totalDoses;
  final String firstDoseTime;
  final String? notes;

  MedicationEntity({
    required this.id,
    required this.name,
    required this.dose,
    required this.type,
    required this.stock,
    required this.doseIntervalInHours,
    required this.totalDoses,
    required this.firstDoseTime,
    this.notes,
  });

  // Método para converter para Map (útil para persistência)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dose': dose,
      'type': type,
      'stock': stock,
      'doseIntervalInHours': doseIntervalInHours,
      'totalDoses': totalDoses,
      'firstDoseTime': firstDoseTime,
      'notes': notes,
    };
  }

  // Método para criar a partir de um Map
  factory MedicationEntity.fromMap(Map<String, dynamic> map) {
    return MedicationEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      dose: map['dose'] ?? '',
      type: map['type'] ?? '',
      stock: map['stock'] ?? 0,
      doseIntervalInHours: map['doseIntervalInHours'] ?? 0,
      totalDoses: map['totalDoses'] ?? 0,
      firstDoseTime: map['firstDoseTime'] ?? '',
      notes: map['notes'],
    );
  }

  // Cópia com alterações (útil para atualizações)
  MedicationEntity copyWith({
    String? id,
    String? name,
    String? dose,
    String? type,
    int? stock,
    int? doseIntervalInHours,
    int? totalDoses,
    String? firstDoseTime,
    String? notes,
  }) {
    return MedicationEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      type: type ?? this.type,
      stock: stock ?? this.stock,
      doseIntervalInHours: doseIntervalInHours ?? this.doseIntervalInHours,
      totalDoses: totalDoses ?? this.totalDoses,
      firstDoseTime: firstDoseTime ?? this.firstDoseTime,
      notes: notes ?? this.notes,
    );
  }
}
