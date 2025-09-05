import 'package:flutter/material.dart';
import 'package:primeiro_flutter/data/datasources/database.dart';
import 'package:primeiro_flutter/presentation/providers/medication_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:primeiro_flutter/presentation/screens/add_medication_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectedDate(DateTime.now());
    });
  }

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

  void _navigateToEditScreen(Prescription prescription) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return AddMedicationScreen(prescription: prescription);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFDC5023);
    const blueColor = Color(0xFF23AFDC);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
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
              builder: (context, provider, child) {
                final doseEventsResults = provider.doseEventsForDay;

                if (doseEventsResults.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma dose para este dia.'),
                  );
                }

                return ListView.builder(
                  itemCount: doseEventsResults.length,
                  itemBuilder: (BuildContext context, int index) {
                    final result = doseEventsResults[index];
                    // CORREÇÃO FINAL: Usamos os nomes corretos da nossa classe auxiliar.
                    final doseEvent = result.doseEvent;
                    final prescription = result.prescription;
                    final isTaken = doseEvent.status == DoseStatus.tomada;

                    return Dismissible(
                      key: ValueKey(prescription.id),
                      background: Container(
                        color: Colors.blueAccent,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmar Exclusão'),
                                content: Text(
                                    'Tem a certeza de que deseja excluir a prescrição de ${prescription.name}? Todas as doses futuras serão removidas.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Excluir'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          _navigateToEditScreen(prescription);
                          return false;
                        }
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          provider.deletePrescription(prescription.id);
                        }
                      },
                      child: Card(
                        child: ListTile(
                          leading: Text(
                            DateFormat('HH:mm').format(doseEvent.scheduledTime),
                            style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold),
                          ),
                          title: Text(prescription.name),
                          subtitle: Text(prescription.doseDescription),
                          trailing: IconButton(
                            icon: Icon(
                              isTaken
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isTaken ? blueColor : Colors.grey,
                              size: 30,
                            ),
                            onPressed: () {
                              provider.toggleDoseStatus(doseEvent);
                            },
                          ),
                        ),
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
