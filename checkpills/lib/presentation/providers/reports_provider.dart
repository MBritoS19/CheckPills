import 'dart:async';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:CheckPills/presentation/providers/user_provider.dart';
import 'package:flutter/material.dart';

class ReportsProvider with ChangeNotifier {
  final AppDatabase database;
  final UserProvider userProvider;

  // Dados em cache
  Map<int, List<DoseEventWithPrescription>> _userDoseEventsCache = {};
  Map<int, List<Prescription>> _userPrescriptionsCache = {};
  List<DoseEventWithPrescription> _allDoseEvents = [];
  Map<DateTime, List<DoseEventWithPrescription>> _allEventsByDay = {};

  // Getters públicos
  List<DoseEventWithPrescription> get allDoseEvents => _allDoseEvents;
  Map<DateTime, List<DoseEventWithPrescription>> get allEventsByDay =>
      _allEventsByDay;

  ReportsProvider({required this.database, required this.userProvider}) {
    _loadAllData();
  }

  void _loadAllData() {
    // Carrega TODAS as prescrições
    _loadAllPrescriptions();
    // Carrega TODOS os eventos de dose
    _loadAllDoseEvents();
  }

  void _loadAllPrescriptions() async {
    try {
      final allPrescriptions =
          await database.prescriptionsDao.watchAllPrescriptions().first;

      // Organiza por usuário
      for (final prescription in allPrescriptions) {
        _userPrescriptionsCache.putIfAbsent(prescription.userId, () => []);
        _userPrescriptionsCache[prescription.userId]!.add(prescription);
      }

      notifyListeners();
    } catch (e) {
      ////debugPrint('Erro ao carregar prescrições: $e');
    }
  }

  void _loadAllDoseEvents() async {
    try {
      final allUsers = userProvider.allUsers;
      final allDoseEvents = <DoseEventWithPrescription>[];

      for (final user in allUsers) {
        final userDoseEvents = await _getDoseEventsForUser(user.id);
        _userDoseEventsCache[user.id] = userDoseEvents;
        allDoseEvents.addAll(userDoseEvents);
      }

      _allDoseEvents = allDoseEvents;
      _updateEventsByDay();
      notifyListeners();

      // Ouvir mudanças nos dados do usuário ativo
      _listenToUserDoseEvents();
    } catch (e) {
      ////debugPrint('Erro ao carregar eventos de dose: $e');
    }
  }

  void _listenToUserDoseEvents() {
    final activeUserId = userProvider.activeUser?.id;
    if (activeUserId != null) {
      database.doseEventsDao
          .watchAllDoseEvents(activeUserId)
          .listen((doseEvents) {
        _updateDoseEventsForUser(activeUserId, doseEvents);
        _updateEventsByDay();
        notifyListeners();
      });
    }
  }

  Future<List<DoseEventWithPrescription>> _getDoseEventsForUser(
      int userId) async {
    try {
      final query = database.doseEventsDao.watchAllDoseEvents(userId);
      final completer = Completer<List<DoseEventWithPrescription>>();

      final subscription = query.listen((events) {
        if (!completer.isCompleted) {
          completer.complete(events);
        }
      });

      // Timeout para evitar que fique esperando eternamente
      final events = await completer.future.timeout(const Duration(seconds: 5));
      subscription.cancel();
      return events;
    } catch (e) {
      ////debugPrint('Erro ao carregar eventos para usuário $userId: $e');
      return [];
    }
  }

  void _updateDoseEventsForUser(
      int userId, List<DoseEventWithPrescription> newEvents) {
    // Remove eventos antigos deste usuário
    _allDoseEvents.removeWhere((event) => event.prescription.userId == userId);
    // Adiciona novos eventos
    _allDoseEvents.addAll(newEvents);

    // Atualiza cache do usuário
    _userDoseEventsCache[userId] = newEvents;
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

  // ========== MÉTODOS PARA A TELA DE HISTÓRICO DE DOSES ==========

  /// Obtém todas as doses de um usuário específico
  List<DoseEventWithPrescription> getDosesForUser(User user) {
    return _userDoseEventsCache[user.id] ?? [];
  }

  /// Obtém doses de um usuário filtradas por período
  List<DoseEventWithPrescription> getDosesForUserInPeriod(
      User user, DateTime start, DateTime end) {
    final userDoses = getDosesForUser(user);

    return userDoses.where((dose) {
      final doseDate = dose.doseEvent.scheduledTime;
      return (doseDate.isAfter(start) || doseDate.isAtSameMomentAs(start)) &&
          (doseDate.isBefore(end) || doseDate.isAtSameMomentAs(end));
    }).toList();
  }

  /// Obtém doses de um usuário filtradas por medicamento
  List<DoseEventWithPrescription> getDosesForUserByMedication(
      User user, String medicationName) {
    final userDoses = getDosesForUser(user);

    return userDoses.where((dose) {
      return dose.prescription.name
          .toLowerCase()
          .contains(medicationName.toLowerCase());
    }).toList();
  }

  /// Obtém estatísticas de adesão para um usuário em um período
  Map<String, dynamic> getAdherenceStatsForUser(User user,
      [DateTimeRange? dateRange]) {
    final userDoses = dateRange != null
        ? getDosesForUserInPeriod(user, dateRange.start, dateRange.end)
        : getDosesForUser(user);

    final takenDoses = userDoses
        .where((dose) => dose.doseEvent.status == DoseStatus.tomada)
        .length;
    final skippedDoses = userDoses
        .where((dose) => dose.doseEvent.status == DoseStatus.pulada)
        .length;
    final pendingDoses = userDoses
        .where((dose) => dose.doseEvent.status == DoseStatus.pendente)
        .length;

    final totalDoses = takenDoses + skippedDoses + pendingDoses;
    final adherenceRate =
        totalDoses > 0 ? ((takenDoses / totalDoses) * 100).round() : 0;

    return {
      'takenDoses': takenDoses,
      'skippedDoses': skippedDoses,
      'pendingDoses': pendingDoses,
      'totalDoses': totalDoses,
      'adherenceRate': adherenceRate,
      'period': dateRange != null
          ? '${_formatDate(dateRange.start)} - ${_formatDate(dateRange.end)}'
          : 'Todo o período',
    };
  }

  /// Obtém os medicamentos mais usados por um usuário
  List<Map<String, dynamic>> getTopMedicationsForUser(User user,
      [int limit = 5]) {
    final userDoses = getDosesForUser(user);
    final medicationCounts = <Prescription, int>{};

    for (final dose in userDoses) {
      medicationCounts.update(
        dose.prescription,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    // Converter para lista e ordenar de forma segura
    final medicationList = medicationCounts.entries.map((entry) {
      return {
        'name': entry.key.name,
        'doseCount': entry.value,
        'doseDescription': entry.key.doseDescription,
      };
    }).toList();

    // Ordenação segura com verificação de tipo
    medicationList.sort((a, b) {
      try {
        final countA = a['doseCount'] as int;
        final countB = b['doseCount'] as int;
        return countB.compareTo(countA);
      } catch (e) {
        return 0; // Em caso de erro, mantém a ordem original
      }
    });

    return medicationList.take(limit).toList();
  }

  /// Obtém o histórico de doses com filtros combinados
  List<DoseEventWithPrescription> getFilteredDoseHistory({
    required User user,
    DateTimeRange? dateRange,
    String searchQuery = '',
    List<DoseStatus>? statusFilter,
  }) {
    var filteredDoses = getDosesForUser(user);

    // Filtro por período
    if (dateRange != null) {
      filteredDoses = filteredDoses.where((dose) {
        final doseDate = dose.doseEvent.scheduledTime;
        return (doseDate.isAfter(dateRange.start) ||
                doseDate.isAtSameMomentAs(dateRange.start)) &&
            (doseDate.isBefore(dateRange.end) ||
                doseDate.isAtSameMomentAs(dateRange.end));
      }).toList();
    }

    // Filtro por busca
    if (searchQuery.isNotEmpty) {
      filteredDoses = filteredDoses.where((dose) {
        return dose.prescription.name
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            dose.prescription.doseDescription
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Filtro por status
    if (statusFilter != null && statusFilter.isNotEmpty) {
      filteredDoses = filteredDoses.where((dose) {
        return statusFilter.contains(dose.doseEvent.status);
      }).toList();
    }

    // Ordena por data (mais recente primeiro)
    filteredDoses.sort((a, b) =>
        b.doseEvent.scheduledTime.compareTo(a.doseEvent.scheduledTime));

    return filteredDoses;
  }

  // ========== MÉTODOS PARA A TELA DE RELATÓRIOS ESTATÍSTICOS ==========

  /// Método para filtrar eventos por usuário (para relatórios estatísticos)
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

  /// Método para filtrar prescrições por usuário
  List<Prescription> getPrescriptionsForUser(User? user) {
    if (user == null) return [];
    return _userPrescriptionsCache[user.id] ?? [];
  }

  /// Método para obter estatísticas gerais para relatórios
  Map<String, dynamic> getGeneralStats({User? user, DateTimeRange? dateRange}) {
    final doses = user != null
        ? (dateRange != null
            ? getDosesForUserInPeriod(user, dateRange.start, dateRange.end)
            : getDosesForUser(user))
        : (dateRange != null
            ? _allDoseEvents.where((dose) {
                final doseDate = dose.doseEvent.scheduledTime;
                return (doseDate.isAfter(dateRange.start) ||
                        doseDate.isAtSameMomentAs(dateRange.start)) &&
                    (doseDate.isBefore(dateRange.end) ||
                        doseDate.isAtSameMomentAs(dateRange.end));
              }).toList()
            : _allDoseEvents);

    final takenDoses = doses
        .where((dose) => dose.doseEvent.status == DoseStatus.tomada)
        .length;
    final skippedDoses = doses
        .where((dose) => dose.doseEvent.status == DoseStatus.pulada)
        .length;
    final pendingDoses = doses
        .where((dose) => dose.doseEvent.status == DoseStatus.pendente)
        .length;

    final totalDoses = takenDoses + skippedDoses + pendingDoses;
    final adherenceRate =
        totalDoses > 0 ? ((takenDoses / totalDoses) * 100).round() : 0;

    // Contagem de medicamentos únicos
    final uniqueMedications = <String>{};
    for (final dose in doses) {
      uniqueMedications.add(dose.prescription.name);
    }

    return {
      'takenDoses': takenDoses,
      'skippedDoses': skippedDoses,
      'pendingDoses': pendingDoses,
      'totalDoses': totalDoses,
      'adherenceRate': adherenceRate,
      'uniqueMedications': uniqueMedications.length,
      'period': dateRange != null
          ? '${_formatDate(dateRange.start)} - ${_formatDate(dateRange.end)}'
          : 'Todo o período',
      'user': user?.name ?? 'Todos os usuários',
    };
  }

  /// Método para atualizar dados quando usuários mudam
  void refreshData() {
    _userDoseEventsCache.clear();
    _userPrescriptionsCache.clear();
    _allDoseEvents.clear();
    _allEventsByDay.clear();
    _loadAllData();
    notifyListeners();
  }

  // ========== MÉTODOS AUXILIARES ==========

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Método para verificar se os dados estão carregados
  bool get isDataLoaded {
    return _userDoseEventsCache.isNotEmpty &&
        _userPrescriptionsCache.isNotEmpty;
  }

  /// Método para obter progresso do carregamento
  double get loadingProgress {
    final totalUsers = userProvider.allUsers.length;
    if (totalUsers == 0) return 1.0;

    final loadedUsers = _userDoseEventsCache.length;
    return loadedUsers / totalUsers;
  }

  @override
  void dispose() {
    // Cancelar qualquer subscription pendente
    super.dispose();
  }
}
