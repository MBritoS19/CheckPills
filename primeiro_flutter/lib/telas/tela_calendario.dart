import 'package:flutter/material.dart';

class TelaCalendario extends StatelessWidget {
  const TelaCalendario({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário'),
      ),
      body: const Center(
        child: Text(
          'Esta é a Tela do Calendário',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
