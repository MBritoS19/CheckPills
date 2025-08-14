import 'package:flutter/material.dart';

class AddMedicationScreen extends StatelessWidget {
  const AddMedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Medicamento')),
      body: const Center(child: Text('Formulário de adição virá aqui')),
    );
  }
}
