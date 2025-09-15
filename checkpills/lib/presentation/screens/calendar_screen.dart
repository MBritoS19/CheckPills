// lib/screens/calendar_screen.dart

import 'package:CheckPills/data/datasources/database.dart';
import 'package:CheckPills/presentation/providers/medication_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // Função para buscar os eventos de um dia específico
  List<DoseEventWithPrescriptionAndPatient> _getEventsForDay(
      DateTime day,
      Map<DateTime, List<DoseEventWithPrescriptionAndPatient>> events) {
    // Normaliza a data para ignorar a hora
    final dayUtc = DateTime.utc(day.year, day.month, day.day);
    return events[dayUtc] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    // Assiste às mudanças no provider
    final provider = context.watch<MedicationProvider>();
    final allEvents = provider.eventsByDay;

    final selectedDayEvents = _getEventsForDay(_selectedDay!, allEvents);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'pt_BR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: (day) => _getEventsForDay(day, allEvents),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange[400],
                      ),
                      width: 10,
                      height: 10,
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: selectedDayEvents.length,
              itemBuilder: (context, index) {
                final doseData = selectedDayEvents[index];
                final time = DateFormat('HH:mm')
                    .format(doseData.doseEvent.scheduledTime);
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: Text(time,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    title: Text(doseData.prescription.name),
                    subtitle: Text(doseData.prescription.doseDescription),
                  ),
                );
              },
            ),
          ),
          // Botão para navegar para a Home
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Ver este dia na Home'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFF23AFDC),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Fecha a tela e retorna o dia selecionado
                Navigator.pop(context, _selectedDay);
              },
            ),
          ),
        ],
      ),
    );
  }
}
