import 'package:flutter/material.dart';
// Importamos o nosso novo modelo de medicamento.
// Atenção para ajustar o caminho se o nome do seu projeto for diferente de 'ola_mundo_app'.
import 'package:primeiro_flutter/domain/entities/medicamento.dart';

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  // Aqui criamos nossa lista de dados "falsos".
  // No futuro, esta lista virá do banco de dados do celular.
  final List<Medicamento> _listaDeMedicamentos = const [
    Medicamento(nome: 'Dipirona', dose: '1 comprimido', hora: '08:00'),
    Medicamento(nome: 'Paracetamol', dose: '500mg', hora: '12:00'),
    Medicamento(nome: 'Amoxicilina', dose: '10ml', hora: '14:00'),
    Medicamento(nome: 'Ibuprofeno', dose: '1 comprimido', hora: '20:00'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Este é o "Calendário simplificado" do seu design.
        title: const Text('Medicamentos de Hoje'),
      ),
      // Vamos usar um ListView.builder.
      // Ele é muito eficiente para criar listas, pois só constrói os itens
      // que estão visíveis na tela, poupando memória.
      body: ListView.builder(
        // `itemCount` diz ao ListView quantos itens existem na nossa lista.
        itemCount: _listaDeMedicamentos.length,

        // `itemBuilder` é uma função que é chamada para cada item da lista.
        // Ela recebe o `context` e o `index` (a posição do item na lista)
        // e deve retornar o widget que será exibido para aquele item.
        itemBuilder: (BuildContext context, int index) {
          // Para cada item, pegamos o medicamento correspondente na lista.
          final medicamento = _listaDeMedicamentos[index];

          // Usamos um widget `Card` para dar uma aparência mais bonita, com sombra.
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              // `ListTile` é um widget perfeito para linhas de uma lista.
              // Ele tem espaços definidos para título, subtítulo e ícones.
              leading: Text(
                medicamento.hora,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              title: Text(medicamento.nome),
              subtitle: Text(medicamento.dose),
              trailing: const Icon(
                  Icons.check_circle_outline), // Um ícone de exemplo à direita.
            ),
          );
        },
      ),
    );
  }
}
