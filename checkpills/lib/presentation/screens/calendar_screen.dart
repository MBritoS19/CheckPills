// lib/screens/calendar_screen.dart

import 'package:CheckPills/presentation/providers/medication_provider.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  List<DoseEventWithPrescription> _getEventsForDay(
      DateTime day, Map<DateTime, List<DoseEventWithPrescription>> events) {
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
        title: const Text('Calendário de Doses'),
      ),
      body: Column(
        children: [
          TableCalendar<DoseEventWithPrescription>(
            locale: 'pt_BR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: (day) => _getEventsForDay(day, allEvents),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
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
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF23AFDC),
                shape: BoxShape.circle,
              ),
              // Estilo para o marcador de evento
              markerDecoration: BoxDecoration(
                color: Color(0xFFDC5023), // Cor laranja do seu app
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          const Text('Doses do dia selecionado:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          // Lista de doses para o dia selecionado
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
