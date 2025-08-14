class Medication {
  final String id;
  final String name;
  final String dosage;
  final MedicationType type;
  final DateTime startDate;
  final DateTime endDate;
  final List<DateTime> times;
  final String? notes;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.times,
    this.notes,
  });
}

enum MedicationType { pill, injection, drops, powder, syrup, other }
