import 'package:flutter/material.dart';
import 'package:primeiro_flutter/domain/entities/medication.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DateTime _selectedDate = DateTime.now();

  final List<Medication> _medicationList = const [
    Medication(
      name: 'Dipirona',
      dose: '1 comprimido',
      stock: 30,
      doseIntervalInHours: 8,
      totalDoses: 90,
      firstDoseTime: '08:00',
    ),
    Medication(
      name: 'Paracetamol',
      dose: '500mg',
      stock: 20,
      doseIntervalInHours: 6,
      totalDoses: 60,
      firstDoseTime: '12:00',
      notes: 'Tomar após a refeição',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFDC5023);
    const blueColor = Color(0xFF23AFDC);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.medication_liquid),
            SizedBox(width: 8),
            Text('Nome do Usuário'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(
            color: orangeColor,
            height: 1,
            thickness: 1,
          ),

          // NOVO COMPONENTE DE SELEÇÃO DE SEMANA
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                // Linha principal com setas e dias
                Row(
                  children: [
                    // Seta da Esquerda
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {/* Lógica para semana anterior */},
                    ),

                    // Usamos `Expanded` para que a lista de dias ocupe
                    // todo o espaço disponível entre as duas setas.
                    const Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _DayItem(
                              dayOfWeek: 'dom.',
                              dayNumber: '10',
                              isSelected: false),
                          _DayItem(
                              dayOfWeek: 'seg.',
                              dayNumber: '11',
                              isSelected: false),
                          _DayItem(
                              dayOfWeek: 'ter.',
                              dayNumber: '12',
                              isSelected: false),
                          _DayItem(
                              dayOfWeek: 'qua.',
                              dayNumber: '13',
                              isSelected: false),
                          _DayItem(
                              dayOfWeek: 'qui.',
                              dayNumber: '14',
                              isSelected: false),
                          _DayItem(
                              dayOfWeek: 'sex.',
                              dayNumber: '15',
                              isSelected: true,
                              highlightColor: blueColor),
                          _DayItem(
                              dayOfWeek: 'sáb.',
                              dayNumber: '16',
                              isSelected: false),
                        ],
                      ),
                    ),

                    // Seta da Direita
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {/* Lógica para próxima semana */},
                    ),
                  ],
                ),

                // Linha com a data completa selecionada
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('d/MMMM/y', 'pt_BR').format(_selectedDate),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: blueColor),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _medicationList.length,
              itemBuilder: (BuildContext context, int index) {
                final medication = _medicationList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    leading: Text(
                      medication.firstDoseTime,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    title: Text(medication.name),
                    subtitle: Text(medication.dose),
                    trailing: const Icon(Icons.check_circle_outline),
                  ),
                );
              },
            ),
          ),
          const Divider(
            color: orangeColor,
            height: 1,
            thickness: 1,
          ),
        ],
      ),
    );
  }
}

// Widget interno para criar cada item de dia da semana.
class _DayItem extends StatelessWidget {
  final String dayOfWeek;
  final String dayNumber;
  final bool isSelected;
  final Color? highlightColor; // Cor do destaque opcional

  const _DayItem({
    required this.dayOfWeek,
    required this.dayNumber,
    this.isSelected = false,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(dayOfWeek,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? highlightColor : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            dayNumber,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
