import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkpills/core/constants/app_constants.dart';
import 'package:checkpills/core/constants/calendar_constants.dart';
import 'package:checkpills/domain/entities/medication_entity.dart';
import 'package:checkpills/presentation/providers/medication_provider.dart';
import 'package:checkpills/presentation/widgets/calendar/calendar_view.dart';
import 'package:checkpills/presentation/widgets/calendar/month_view.dart';
import 'package:checkpills/presentation/widgets/calendar/week_view.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarViewType _currentView = CalendarViewType.month;
  DateTime _focusedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDate = DateTime.now();
              });
            },
            tooltip: 'Ir para hoje',
          ),
          PopupMenuButton<CalendarViewType>(
            onSelected: (viewType) {
              setState(() {
                _currentView = viewType;
              });
            },
            itemBuilder: (BuildContext context) {
              return CalendarViewType.values.map((viewType) {
                return PopupMenuItem<CalendarViewType>(
                  value: viewType,
                  child: Text(CalendarConstants.viewTypeLabels[viewType]!),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Consumer<MedicationProvider>(
        builder: (context, medicationProvider, child) {
          return _buildCalendarView(
            medicationProvider.medications,
            context,
          );
        },
      ),
    );
  }

  Widget _buildCalendarView(
    List<MedicationEntity> medications,
    BuildContext context,
  ) {
    switch (_currentView) {
      case CalendarViewType.month:
        return MonthView(
          focusedDate: _focusedDate,
          medications: medications,
          onDateSelected: (date) {
            setState(() {
              _focusedDate = date;
              _currentView = CalendarViewType.week;
            });
          },
        );
      case CalendarViewType.week:
        return WeekView(
          focusedDate: _focusedDate,
          medications: medications,
          onDateSelected: (date) {
            setState(() {
              _focusedDate = date;
            });
          },
        );
      case CalendarViewType.day:
        return DayView(
          focusedDate: _focusedDate,
          medications: medications,
          onDateSelected: (date) {
            setState(() {
              _focusedDate = date;
            });
          },
        );
    }
  }
}
