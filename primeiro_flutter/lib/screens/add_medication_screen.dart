// File path: lib/screens/add_medication_screen.dart

import 'package:flutter/material.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _stockController = TextEditingController();
  final _firstDoseTimeController = TextEditingController();
  final _intervalController = TextEditingController();
  final _totalDosesController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _stockController.dispose();
    _firstDoseTimeController.dispose();
    _intervalController.dispose();
    _totalDosesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Novo Medicamento'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome do Medicamento',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _doseController,
            decoration: const InputDecoration(
              labelText: 'Dose (ex: 1 comprimido, 500mg)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _stockController,
            decoration: const InputDecoration(
              labelText: 'Doses em Estoque',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _firstDoseTimeController,
            decoration: const InputDecoration(
              labelText: 'Hora da Primeira Dose (ex: 08:00)',
              border: OutlineInputBorder(),
              icon: Icon(Icons.access_time),
            ),
            keyboardType: TextInputType.datetime,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _intervalController,
            decoration: const InputDecoration(
              labelText: 'Horas de Intervalo entre Doses',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _totalDosesController,
            decoration: const InputDecoration(
              labelText: 'Total de Doses do Tratamento',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Observações (opcional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Salvar Medicamento'),
          ),
        ],
      ),
    );
  }
}
