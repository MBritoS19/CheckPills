class MedicationConstants {
  static const String defaultType = 'Não definido';

  static const Map<String, List<String>> medicationCategories = {
    'Sólidos': [
      'Comprimidos',
      'Cápsulas',
      'Pó',
      'Granulado',
      'Pastilhas',
      'Supositório'
    ],
    'Semissólidos': ['Pomada', 'Creme', 'Gel'],
    'Líquidos': ['Gotas', 'Xarope', 'Suspensão', 'Emulsão', 'Injeção'],
    'Gasosos': ['Aerossol', 'Spray'],
  };
}
