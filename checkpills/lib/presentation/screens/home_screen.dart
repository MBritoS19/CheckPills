import 'package:CheckPills/presentation/screens/add_medication_screen.dart';
import 'package:CheckPills/presentation/providers/medication_provider.dart';
import 'package:CheckPills/presentation/providers/settings_provider.dart';
import 'package:CheckPills/presentation/screens/calendar_screen.dart';
import 'package:CheckPills/presentation/widgets/dose_event_card.dart'; // <- 1. IMPORTAÇÃO ADICIONADA
import 'package:CheckPills/data/datasources/database.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';

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

  void _showOutOfStockDialog(BuildContext context, Prescription prescription) {
    final provider = Provider.of<MedicationProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.secondary, size: 48),
        title: const Text('Estoque Esgotado', textAlign: TextAlign.center),
        content: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            children: <TextSpan>[
              const TextSpan(text: 'Seu estoque de '),
              TextSpan(
                  text: prescription.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              const TextSpan(text: ' acabou. Adicione mais para continuar.'),
            ],
          ),
        ),
        actions: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                child: const Text('Adicionar Estoque'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showAddStockDialog(context, prescription);
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                ),
                child: const Text('Não controlar estoque'),
                onPressed: () {
                  provider.stopTrackingStock(prescription.id);
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }

  void _showAddStockDialog(BuildContext context, Prescription prescription) {
    final stockController = TextEditingController();
    final provider = Provider.of<MedicationProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.inventory_2_outlined,
            color: Theme.of(context).colorScheme.primary, size: 48),
        title: const Text('Adicionar Estoque', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Digite a nova quantidade total em estoque para ${prescription.name}.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              autofocus: true,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'Nova quantidade',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                child: const Text('Salvar'),
                onPressed: () {
                  final newStock = int.tryParse(stockController.text);
                  if (newStock != null) {
                    provider.updatePrescriptionStock(prescription.id, newStock);
                    Navigator.of(ctx).pop();
                  }
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor:
                        Theme.of(context).colorScheme.onSecondary),
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          )
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }

  void _updateSelectedDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    Provider.of<MedicationProvider>(context, listen: false)
        .fetchDoseEventsForDay(newDate);
  }

  void _showImageDialog(
      BuildContext context, String imagePath, int prescriptionId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Hero(
            tag: 'med_image_$prescriptionId',
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
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
            highlightColor: Theme.of(context).colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child) {
            final userName = settingsProvider.settings.userName;
            return Row(
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Image.asset('assets/images/logo.jpg'),
                ),
                const SizedBox(width: 8),
                Text(userName ?? 'Bem-vindo(a)!'),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final selectedDate = await Navigator.push<DateTime>(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
              if (selectedDate != null && context.mounted) {
                _updateSelectedDate(selectedDate);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Divider(color: colorScheme.secondary, height: 1, thickness: 1),
          Container(
            color: Theme.of(context).cardTheme.color,
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
                        color: colorScheme.primary),
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
                    final prescription = result.prescription;
                    final doseEvent = result.doseEvent;
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
                          return await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    icon: Icon(Icons.delete_forever_rounded,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        size: 48),
                                    title: const Text('Confirmar Exclusão',
                                        textAlign: TextAlign.center),
                                    content: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16),
                                        children: <TextSpan>[
                                          const TextSpan(
                                              text:
                                                  'Tem a certeza de que deseja excluir a prescrição de '),
                                          TextSpan(
                                              text: prescription.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                          const TextSpan(
                                              text:
                                                  '? Esta ação não pode ser desfeita.'),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                              foregroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .onError,
                                            ),
                                            child: const Text('Sim, Excluir'),
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                          ),
                                          OutlinedButton(
                                            child: const Text('Cancelar'),
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                          ),
                                        ],
                                      )
                                    ],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  );
                                },
                              ) ??
                              false;
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
                      // 2. O ANTIGO 'CARD' FOI TOTALMENTE SUBSTITUÍDO PELO 'DOSEEVENTCARD'
                      child: DoseEventCard(
                        doseData: result,
                        onImageTap: () {
                          if (prescription.imagePath != null) {
                            _showImageDialog(context, prescription.imagePath!,
                                prescription.id);
                          }
                        },
                        onToggleStatus: () {
                          if (isTaken) {
                            provider.toggleDoseStatus(result);
                            return;
                          }
                          if (prescription.stock == -1 ||
                              prescription.stock > 0) {
                            provider.toggleDoseStatus(result);
                          } else {
                            _showOutOfStockDialog(context, prescription);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(color: colorScheme.secondary, height: 1, thickness: 1),
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
    final Color? defaultTextColor =
        Theme.of(context).textTheme.bodyLarge?.color;

    return Column(
      children: [
        Text(dayOfWeek,
            style: TextStyle(
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.w500,
                color: defaultTextColor)),
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
              color: isSelected ? Colors.white : defaultTextColor,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.035,
            ),
          ),
        ),
      ],
    );
  }
}