class MedicationValidator {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe o nome do medicamento';
    }
    return null;
  }

  static String? validateDose(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe a dose do medicamento';
    }
    return null;
  }

  static String? validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe o estoque';
    }
    final stock = int.tryParse(value);
    if (stock == null || stock <= 0) {
      return 'Estoque deve ser um número maior que zero';
    }
    return null;
  }

  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe o horário';
    }
    if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
      return 'Formato inválido. Use HH:MM (ex: 08:00)';
    }
    return null;
  }

  static String? validateInterval(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe o intervalo';
    }
    final interval = int.tryParse(value);
    if (interval == null || interval <= 0) {
      return 'Intervalo deve ser um número maior que zero';
    }
    return null;
  }

  static String? validateTotalDoses(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe o total de doses';
    }
    final totalDoses = int.tryParse(value);
    if (totalDoses == null || totalDoses <= 0) {
      return 'Total de doses deve ser um número maior que zero';
    }
    return null;
  }
}
