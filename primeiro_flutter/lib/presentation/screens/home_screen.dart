import 'package:flutter/material.dart';
import 'package:primeiro_flutter/presentation/providers/medication_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:primeiro_flutter/data/datasources/database.dart';
import 'package:primeiro_flutter/presentation/widgets/dose_event_card.dart';
import 'package:primeiro_flutter/presentation/screens/add_medication_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  void _updateSelectedDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    Provider.of<MedicationProvider>(context, listen: false)
        .fetchDoseEventsForDay(newDate);
  }

  void _goToPreviousWeek() {
    _updateSelectedDate(_selectedDate.subtract(const Duration(days: 7)));
  }

  void _goToNextWeek() {
    _updateSelectedDate(_selectedDate.add(const Duration(days: 7)));
  }

  List<Widget> _generateWeekDays(double screenWidth) {
    List<Widget> weekDays = [];
    DateFormat weekdayFormat = DateFormat('E', 'pt_BR');
    DateTime startOfWeek =
        _selectedDate.subtract(Duration(days: _selectedDate.weekday % 7));

    for (int i = 0; i < 7; i++) {
      DateTime currentDate = startOfWeek.add(Duration(days: i));
      String dayOfWeek =
          weekdayFormat.format(currentDate).substring(0, 3) + '.';

      weekDays.add(
        InkWell(
          onTap: () {
            _updateSelectedDate(currentDate);
          },
          borderRadius: BorderRadius.circular(100),
          child: _DayItem(
            dayOfWeek: dayOfWeek,
            dayNumber: currentDate.day.toString(),
            isSelected: currentDate.day == _selectedDate.day &&
                currentDate.month == _selectedDate.month &&
                currentDate.year == _selectedDate.year,
            highlightColor: const Color(0xFF23AFDC),
            screenWidth: screenWidth,
          ),
        ),
      );
    }
    return weekDays;
  }

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFDC5023);
    const blueColor = Color(0xFF23AFDC);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        // A propriedade `backgroundColor` foi REMOVIDA daqui.
        // Agora a cor virá do `appTheme` que definimos no `main.dart`.
        title: Row(children: [
          SizedBox(
            height: 40,
            width: 40,
            child: Image.asset('assets/images/logo.jpg'),
          ),
          const SizedBox(width: 8),
          const Text('Nome do Usuário'),
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
            // Este cinza é para o seletor de data, então ele pode ser mantido.
            color: Colors.grey[200],
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
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
                  padding: EdgeInsets.only(top: screenWidth * 0.02),
                  child: Text(
                    DateFormat('d/MMMM/y', 'pt_BR').format(_selectedDate),
                    style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: blueColor),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<MedicationProvider>(
              builder: (context, medicationProvider, child) {
                if (medicationProvider.doseEventsForDay.isEmpty) {
                  return const Center(
                      child: Text("Nenhuma dose agendada para este dia."));
                }

                return ListView.builder(
                  itemCount: medicationProvider.doseEventsForDay.length,
                  itemBuilder: (context, index) {
                    final combinedData =
                        medicationProvider.doseEventsForDay[index];

                    return Dismissible(
                      key: Key(combinedData.prescription.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        child: const Icon(Icons.delete,
                            color: Colors.white, size: 30),
                      ),
                      confirmDismiss: (direction) async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirmação'),
                              content: const Text(
                                  'Tem certeza de que deseja excluir este medicamento?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text('Apagar'),
                                ),
                              ],
                            );
                          },
                        );
                        return confirmed ?? false;
                      },
                      onDismissed: (direction) {
                        medicationProvider
                            .deletePrescription(combinedData.prescription.id);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${combinedData.prescription.name} excluído.'),
                          ),
                        );
                      },
                      child: DoseEventCard(
                        combinedData: combinedData,
                        onEdit: () {
                          // Abre o modal de edição
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20.0),
                              ),
                            ),
                            builder: (BuildContext context) {
                              // Passa a medicação correta para a tela de edição
                              return AddMedicationScreen(
                                prescription: combinedData.prescription,
                              );
                            },
                          );
                        },
                        onToggleStatus: (doseEvent) {
                          medicationProvider.toggleDoseStatus(doseEvent);
                        },
                      ),
                    );
                  },
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
  final double screenWidth;

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
                fontSize: screenWidth * 0.03, fontWeight: FontWeight.w500)),
        SizedBox(height: screenWidth * 0.01),
        Container(
          padding: EdgeInsets.all(screenWidth * 0.02),
          decoration: BoxDecoration(
            color: isSelected ? highlightColor : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            dayNumber,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.035,
            ),
          ),
        ),
      ],
    );
  }
}
