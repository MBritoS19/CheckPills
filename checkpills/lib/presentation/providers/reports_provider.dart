import 'dart:async'; // ADICIONE ESTE IMPORT
import 'package:CheckPills/data/datasources/database.dart';
import 'package:CheckPills/presentation/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;

class ReportsProvider with ChangeNotifier {
  final AppDatabase database;
  final UserProvider userProvider;

  // Streams
  StreamSubscription? _allPrescriptionsSubscription;
  StreamSubscription? _allDoseEventsSubscription;

  // Dados completos (todos os usuários)
  List<Prescription> _allPrescriptions = [];
  List<DoseEventWithPrescription> _allDoseEvents = [];
  Map<DateTime, List<DoseEventWithPrescription>> _allEventsByDay = {};

  // Getters públicos
  List<Prescription> get allPrescriptions => _allPrescriptions;
  List<DoseEventWithPrescription> get allDoseEvents => _allDoseEvents;
  Map<DateTime, List<DoseEventWithPrescription>> get allEventsByDay =>
      _allEventsByDay;

  ReportsProvider({required this.database, required this.userProvider}) {
    _loadAllData();
  }

  void _loadAllData() {
    // Carrega TODAS as prescrições
    _allPrescriptionsSubscription = database.prescriptionsDao
        .watchAllPrescriptions()
        .listen((prescriptions) {
      _allPrescriptions = prescriptions;
      _updateEventsByDay();
      notifyListeners();
    });

    // Carrega TODOS os eventos de dose - precisamos criar um método para isso
    // Por enquanto, vamos carregar dados de todos os usuários individualmente
    _loadAllDoseEvents();
  }

  void _loadAllDoseEvents() async {
    // Para carregar todos os eventos, precisamos iterar por todos os usuários
    final allUsers = userProvider.allUsers;
    final allDoseEvents = <DoseEventWithPrescription>[];

    for (final user in allUsers) {
      final userDoseEvents = await _getDoseEventsForUser(user.id);
      allDoseEvents.addAll(userDoseEvents);
    }

    _allDoseEvents = allDoseEvents;
    _updateEventsByDay();
    notifyListeners();

    // Também ouvimos mudanças nos dados do usuário ativo
    _allDoseEventsSubscription = database.doseEventsDao
        .watchAllDoseEvents(userProvider.activeUser?.id ?? 0)
        .listen((doseEvents) {
      // Atualiza apenas os eventos do usuário ativo
      _updateDoseEventsForUser(userProvider.activeUser?.id ?? 0, doseEvents);
      _updateEventsByDay();
      notifyListeners();
    });
  }

  Future<List<DoseEventWithPrescription>> _getDoseEventsForUser(
      int userId) async {
    final query = database.doseEventsDao.watchAllDoseEvents(userId);
    final completer = Completer<List<DoseEventWithPrescription>>();

    final subscription = query.listen((events) {
      completer.complete(events);
    });

    final events = await completer.future;
    subscription.cancel();
    return events;
  }

  void _updateDoseEventsForUser(
      int userId, List<DoseEventWithPrescription> newEvents) {
    // Remove eventos antigos deste usuário
    _allDoseEvents.removeWhere((event) => event.prescription.userId == userId);
    // Adiciona novos eventos
    _allDoseEvents.addAll(newEvents);
  }

  void _updateEventsByDay() {
    final newEventsByDay = <DateTime, List<DoseEventWithPrescription>>{};

    for (final dose in _allDoseEvents) {
      final day = DateTime.utc(
        dose.doseEvent.scheduledTime.year,
        dose.doseEvent.scheduledTime.month,
        dose.doseEvent.scheduledTime.day,
      );

      final existingDoses = newEventsByDay[day] ?? [];
      existingDoses.add(dose);
      newEventsByDay[day] = existingDoses;
    }

    _allEventsByDay = newEventsByDay;
  }

  // Método para filtrar eventos por usuário
  Map<DateTime, List<DoseEventWithPrescription>> getEventsForUser(User? user) {
    if (user == null) return {};

    final filteredEvents = <DateTime, List<DoseEventWithPrescription>>{};

    for (final entry in _allEventsByDay.entries) {
      final userEvents = entry.value
          .where((event) => event.prescription.userId == user.id)
          .toList();

      if (userEvents.isNotEmpty) {
        filteredEvents[entry.key] = userEvents;
      }
    }

    return filteredEvents;
  }

  // Método para filtrar prescrições por usuário
  List<Prescription> getPrescriptionsForUser(User? user) {
    if (user == null) return [];
    return _allPrescriptions.where((p) => p.userId == user.id).toList();
  }

  // Método para atualizar dados quando usuários mudam
  void refreshData() {
    _loadAllDoseEvents();
    notifyListeners();
  }

  @override
  void dispose() {
    _allPrescriptionsSubscription?.cancel();
    _allDoseEventsSubscription?.cancel();
    super.dispose();
  }
}
