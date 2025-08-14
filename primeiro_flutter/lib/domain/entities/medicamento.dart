// lib/domain/entities/medicamento.dart

class Medicamento {
  final String nome;
  final String dose;
  final String hora;

  // A única mudança é adicionar 'const' aqui.
  const Medicamento({
    required this.nome,
    required this.dose,
    required this.hora,
  });
}
