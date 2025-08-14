import 'package:flutter/material.dart';

class TelaConfiguracao extends StatelessWidget {
  const TelaConfiguracao({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: const Center(
        child: Text(
          'Esta é a Tela de Configurações',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
