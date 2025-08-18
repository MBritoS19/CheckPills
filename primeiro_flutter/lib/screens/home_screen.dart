import 'package:flutter/material.dart';
import 'package:primeiro_flutter/domain/entities/medication.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  void _goToPreviousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
    });
  }

  void _goToNextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
    });
  }

  List<Widget> _generateWeekDays(double screenWidth) {
    List<Widget> weekDays = [];
    DateFormat weekdayFormat = DateFormat('E', 'pt_BR');
    DateTime startOfWeek =
        _selectedDate.subtract(Duration(days: _selectedDate.weekday % 7));

    for (int i = 0; i < 7; i++) {
      DateTime currentDate = startOfWeek.add(Duration(days: i));
      String dayOfWeek =
          '${weekdayFormat.format(currentDate).substring(0, 3)}.';

      weekDays.add(
        InkWell(
          onTap: () {
            setState(() {
              _selectedDate = currentDate;
            });
          },
          borderRadius: BorderRadius.circular(100),
          child: _DayItem(
            dayOfWeek: dayOfWeek,
            dayNumber: currentDate.day.toString(),
            isSelected: currentDate.day == _selectedDate.day &&
                currentDate.month == _selectedDate.month &&
                currentDate.year == _selectedDate.year,
            highlightColor: const Color(0xFF23AFDC),
            // Passamos a largura da tela para o widget filho
            screenWidth: screenWidth,
          ),
        ),
      );
    }
    return weekDays;
  }

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
    // Obtemos as dimensões da tela aqui, no início do método build.
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: const [
          Icon(Icons.medication_liquid),
          SizedBox(width: 8),
          Text('Nome do Usuário'),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(color: orangeColor, height: 1, thickness: 1),
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.symmetric(
                vertical: screenWidth * 0.02), // 2% da largura
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _goToPreviousWeek,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        // Passamos a largura da tela para a função que gera os dias
                        children: _generateWeekDays(screenWidth),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _goToNextWeek,
                    ),
                  ],
                ),
                Padding(
                  padding:
                      EdgeInsets.only(top: screenWidth * 0.02), // 2% da largura
                  child: Text(
                    DateFormat('d/MMMM/y', 'pt_BR').format(_selectedDate),
                    style: TextStyle(
                        fontSize: screenWidth * 0.04, // 4% da largura
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
                  // Margens responsivas
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04, // 4% da largura
                    vertical: screenWidth * 0.02, // 2% da largura
                  ),
                  child: ListTile(
                    leading: Text(
                      medication.firstDoseTime,
                      style: TextStyle(
                          fontSize: screenWidth * 0.04, // 4% da largura
                          fontWeight: FontWeight.bold),
                    ),
                    title: Text(medication.name),
                    subtitle: Text(medication.dose),
                    trailing: const Icon(Icons.check_circle_outline),
                  ),
                );
              },
            ),
          ),
          const Divider(color: orangeColor, height: 1, thickness: 1),
        ],
      ),
    );
  }
}

class _DayItem extends StatelessWidget {
  final String dayOfWeek;
  final String dayNumber;
  final bool isSelected;
  final Color? highlightColor;
  final double screenWidth; // Recebe a largura da tela

  const _DayItem({
    required this.dayOfWeek,
    required this.dayNumber,
    required this.screenWidth,
    this.isSelected = false,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(dayOfWeek,
            style: TextStyle(
                fontSize: screenWidth * 0.03, // 3% da largura
                fontWeight: FontWeight.w500)),
        SizedBox(height: screenWidth * 0.01), // 1% da largura
        Container(
          padding: EdgeInsets.all(screenWidth * 0.02), // 2% da largura
          decoration: BoxDecoration(
            color: isSelected ? highlightColor : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            dayNumber,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.035, // 3.5% da largura
            ),
          ),
        ),
      ],
    );
  }
}
