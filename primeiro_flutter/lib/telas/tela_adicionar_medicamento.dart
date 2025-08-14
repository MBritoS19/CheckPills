import 'package:flutter/material.dart';

class TelaAdicionarMedicamento extends StatefulWidget {
  // Como é um StatefulWidget, o construtor dele é simples.
  const TelaAdicionarMedicamento({super.key});

  @override
  // A "mágica" acontece na classe State associada a ele.
  State<TelaAdicionarMedicamento> createState() =>
      _TelaAdicionarMedicamentoState();
}

class _TelaAdicionarMedicamentoState extends State<TelaAdicionarMedicamento> {
  // Para cada campo de texto, criamos um "Controlador".
  // Ele serve para ler o que o usuário digita e para controlar o texto do campo.
  final _nomeController = TextEditingController();
  final _doseController = TextEditingController();
  final _horaController = TextEditingController();

  // É uma boa prática "limpar" os controladores quando o widget é destruído
  // para libertar a memória.
  @override
  void dispose() {
    _nomeController.dispose();
    _doseController.dispose();
    _horaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Novo Medicamento'),
      ),
      // Usamos `Padding` para dar um espaçamento nas bordas do formulário.
      // O `ListView` garante que a tela seja rolável em aparelhos pequenos.
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // TextFormField é um campo de texto otimizado para formulários.
          TextFormField(
            controller: _nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome do Medicamento',
              border: OutlineInputBorder(),
            ),
          ),
          // Usamos um SizedBox para dar um espaçamento vertical entre os campos.
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
            controller: _horaController,
            decoration: const InputDecoration(
              labelText: 'Hora (ex: 08:00)',
              border: OutlineInputBorder(),
              icon: Icon(Icons.access_time), // Ícone para ajudar o usuário.
            ),
            keyboardType:
                TextInputType.datetime, // Mostra um teclado otimizado.
          ),
          const SizedBox(height: 32),
          // O botão para submeter o formulário.
          ElevatedButton(
            onPressed: () {
              // Por enquanto, o botão não fará nada.
              // Apenas fechará a tela ao ser pressionado.
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
