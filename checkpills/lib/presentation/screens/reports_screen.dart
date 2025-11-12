import 'package:CheckPills/presentation/providers/reports_provider.dart';
import 'package:CheckPills/presentation/providers/user_provider.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  User? _selectedUser;
  bool _showAllUsers = false;

  @override
  void initState() {
    super.initState();
    // Inicializa com o usuário ativo
    final userProvider = context.read<UserProvider>();
    _selectedUser = userProvider.activeUser;
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final userProvider = context.watch<UserProvider>();

    // Usa os dados completos do ReportsProvider
    final allEvents = reportsProvider.allEventsByDay;

    // Se não há usuário selecionado, usa o ativo
    if (_selectedUser == null) {
      _selectedUser = userProvider.activeUser;
    }

    // Filtra eventos baseado na seleção
    final filteredEvents = _showAllUsers
        ? allEvents // Mostra todos os usuários
        : reportsProvider
            .getEventsForUser(_selectedUser); // Usa o método do provider

    final stats = _calculateStatistics(filteredEvents, userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _showFilterDialog(userProvider),
            tooltip: 'Filtrar por Perfil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com filtro selecionado
            _buildFilterHeader(userProvider),
            const SizedBox(height: 20),

            // Estatísticas gerais
            _buildStatisticsCards(stats),
            const SizedBox(height: 20),

            // Gráfico de adesão
            _buildAdherenceChart(stats),
            const SizedBox(height: 20),

            // Lista de medicamentos mais usados
            _buildTopMedications(stats),
            const SizedBox(height: 20), // Adicionado espaçamento

            // Estatísticas por medicamento
            _buildMedicationDetails(stats),

            // Estatísticas por usuário (se mostrar todos)
            if (_showAllUsers) ...[
              const SizedBox(height: 20),
              _buildUserStatistics(stats),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterHeader(UserProvider userProvider) {
    String filterText;
    IconData filterIcon;
    Color filterColor;

    if (_showAllUsers) {
      filterText = 'Todos os Perfis';
      filterIcon = Icons.group;
      filterColor = Colors.purple;
    } else {
      filterText = _selectedUser?.name ?? 'Perfil não selecionado';
      filterIcon = Icons.person;
      filterColor = Colors.blue;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(filterIcon, color: filterColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtro Ativo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    filterText,
                    style: TextStyle(
                      fontSize: 16,
                      color: filterColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!_showAllUsers && _selectedUser != null)
                    Text(
                      'Relatório individual',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  if (_showAllUsers)
                    Text(
                      'Relatório consolidado de todos os perfis',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.filter_list, color: filterColor),
              onPressed: () => _showFilterDialog(userProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(ReportStatistics stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'Doses Tomadas',
          stats.takenDoses.toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Doses Puladas',
          stats.skippedDoses.toString(),
          Icons.skip_next,
          Colors.orange,
        ),
        _buildStatCard(
          'Taxa de Adesão',
          '${stats.adherenceRate}%',
          Icons.analytics,
          Colors.blue,
        ),
        _buildStatCard(
          'Medicamentos',
          stats.totalMedications.toString(),
          Icons.medication,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdherenceChart(ReportStatistics stats) {
    if (stats.takenDoses + stats.skippedDoses + stats.pendingDoses == 0) {
      return Card(
        elevation: 2,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Nenhuma dose encontrada para o filtro selecionado.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final chartData = [
      _ChartData('Tomadas', stats.takenDoses, Colors.green),
      _ChartData('Puladas', stats.skippedDoses, Colors.orange),
      _ChartData('Pendentes', stats.pendingDoses, Colors.grey),
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _showAllUsers
                  ? 'Distribuição Geral de Doses'
                  : 'Distribuição de Doses',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SfCircularChart(
                legend: const Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                ),
                series: <CircularSeries>[
                  DoughnutSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData data, _) => data.category,
                    yValueMapper: (_ChartData data, _) => data.value,
                    pointColorMapper: (_ChartData data, _) => data.color,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopMedications(ReportStatistics stats) {
    if (stats.topMedications.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Nenhum medicamento encontrado para o filtro selecionado.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _showAllUsers
                  ? 'Medicamentos Mais Usados (Todos os Perfis)'
                  : 'Medicamentos Mais Usados',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...stats.topMedications.map((med) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          med.name,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Chip(
                        label: Text('${med.doseCount} doses'),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationDetails(ReportStatistics stats) {
    if (stats.medicationDetails.isEmpty) {
      // Retorna Card com aviso centralizado
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Nenhum detalhe de medicamento encontrado para o filtro selecionado.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _showAllUsers
                  ? 'Detalhes por Medicamento (Todos os Perfis)'
                  : 'Detalhes por Medicamento',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...stats.medicationDetails.map((medDetail) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medDetail.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildMiniStat(
                              'Tomadas', medDetail.takenDoses, Colors.green),
                          const SizedBox(width: 12),
                          _buildMiniStat(
                              'Puladas', medDetail.skippedDoses, Colors.orange),
                          const SizedBox(width: 12),
                          _buildMiniStat(
                              'Adesão', medDetail.adherenceRate, Colors.blue,
                              isPercent: true),
                        ],
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatistics(ReportStatistics stats) {
    if (stats.userStatistics.isEmpty) {
      return const SizedBox();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estatísticas por Perfil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...stats.userStatistics.map((userStat) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userStat.userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildMiniStat(
                                  'Tomadas', userStat.takenDoses, Colors.green),
                              const SizedBox(width: 8),
                              _buildMiniStat('Puladas', userStat.skippedDoses,
                                  Colors.orange),
                              const SizedBox(width: 8),
                              _buildMiniStat(
                                  'Adesão', userStat.adherenceRate, Colors.blue,
                                  isPercent: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, int value, Color color,
      {bool isPercent = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              isPercent ? '$value%' : value.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por Perfil'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Opção "Todos os Perfis"
              ListTile(
                leading: Icon(
                  Icons.group,
                  color: _showAllUsers
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                title: const Text('Todos os Perfis'),
                subtitle:
                    const Text('Relatório consolidado de todos os usuários'),
                trailing: _showAllUsers
                    ? Icon(Icons.check,
                        color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  setState(() {
                    _showAllUsers = true;
                    _selectedUser = null;
                  });
                  Navigator.of(context).pop();
                },
              ),
              const Divider(),

              // Lista de usuários individuais
              ...userProvider.allUsers.map((user) => ListTile(
                    leading: Icon(
                      Icons.person,
                      color: (!_showAllUsers && _selectedUser?.id == user.id)
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    title: Text(user.name),
                    subtitle: const Text('Relatório individual'),
                    trailing: (!_showAllUsers && _selectedUser?.id == user.id)
                        ? Icon(Icons.check,
                            color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _showAllUsers = false;
                        _selectedUser = user;
                      });
                      Navigator.of(context).pop();
                    },
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  ReportStatistics _calculateStatistics(
      Map<DateTime, List<DoseEventWithPrescription>> filteredEvents,
      UserProvider userProvider) {
    int takenDoses = 0;
    int skippedDoses = 0;
    int pendingDoses = 0;
    final medicationCounts = <Prescription, int>{};
    final medicationDetails = <MedicationDetail>[];
    final userStatistics = <UserStatistics>[];

    // Maps para armazenar estatísticas
    final medStats = <Prescription, _MedicationStats>{};
    final userStats = <int, _UserStats>{};

    for (final events in filteredEvents.values) {
      for (final event in events) {
        final prescription = event.prescription;
        final userId = prescription.userId;

        // Inicializa estatísticas do medicamento
        medStats.putIfAbsent(
            prescription, () => _MedicationStats(prescription.name));

        // Inicializa estatísticas do usuário
        if (_showAllUsers) {
          userStats.putIfAbsent(
              userId,
              () => _UserStats(
                    _getUserName(userId, userProvider),
                  ));
        }

        // Estatísticas gerais
        switch (event.doseEvent.status) {
          case DoseStatus.tomada:
            takenDoses++;
            medStats[prescription]!.takenDoses++;
            if (_showAllUsers) userStats[userId]!.takenDoses++;
            break;
          case DoseStatus.pulada:
            skippedDoses++;
            medStats[prescription]!.skippedDoses++;
            if (_showAllUsers) userStats[userId]!.skippedDoses++;
            break;
          case DoseStatus.pendente:
            pendingDoses++;
            medStats[prescription]!.pendingDoses++;
            if (_showAllUsers) userStats[userId]!.pendingDoses++;
            break;
        }

        // Contagem total por medicamento
        medicationCounts.update(
          prescription,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }

    // Converte para lista de MedicationDetail
    medicationDetails.addAll(medStats.values.map((stats) => MedicationDetail(
          name: stats.name,
          takenDoses: stats.takenDoses,
          skippedDoses: stats.skippedDoses,
          pendingDoses: stats.pendingDoses,
          adherenceRate: stats.adherenceRate,
        )));

    // Converte para lista de UserStatistics (se mostrar todos)
    if (_showAllUsers) {
      userStatistics.addAll(userStats.values.map((stats) => UserStatistics(
            userName: stats.userName,
            takenDoses: stats.takenDoses,
            skippedDoses: stats.skippedDoses,
            pendingDoses: stats.pendingDoses,
            adherenceRate: stats.adherenceRate,
          )));
    }

    final totalDoses = takenDoses + skippedDoses + pendingDoses;
    final adherenceRate =
        totalDoses > 0 ? ((takenDoses / totalDoses) * 100).round() : 0;

    // Ordena medicamentos por frequência
    final topMedications = medicationCounts.entries
        .map((entry) => MedicationStats(
              name: entry.key.name,
              doseCount: entry.value,
            ))
        .toList()
      ..sort((a, b) => b.doseCount.compareTo(a.doseCount))
      ..take(5).toList();

    return ReportStatistics(
      takenDoses: takenDoses,
      skippedDoses: skippedDoses,
      pendingDoses: pendingDoses,
      adherenceRate: adherenceRate,
      totalMedications: medicationCounts.length,
      topMedications: topMedications,
      medicationDetails: medicationDetails,
      userStatistics: userStatistics,
    );
  }

  String _getUserName(int userId, UserProvider userProvider) {
    try {
      final user =
          userProvider.allUsers.firstWhere((user) => user.id == userId);
      return user.name;
    } catch (e) {
      return 'Usuário #$userId';
    }
  }
}

class ReportStatistics {
  final int takenDoses;
  final int skippedDoses;
  final int pendingDoses;
  final int adherenceRate;
  final int totalMedications;
  final List<MedicationStats> topMedications;
  final List<MedicationDetail> medicationDetails;
  final List<UserStatistics> userStatistics;

  ReportStatistics({
    required this.takenDoses,
    required this.skippedDoses,
    required this.pendingDoses,
    required this.adherenceRate,
    required this.totalMedications,
    required this.topMedications,
    required this.medicationDetails,
    this.userStatistics = const [],
  });
}

class MedicationStats {
  final String name;
  final int doseCount;

  MedicationStats({required this.name, required this.doseCount});
}

class MedicationDetail {
  final String name;
  final int takenDoses;
  final int skippedDoses;
  final int pendingDoses;
  final int adherenceRate;

  MedicationDetail({
    required this.name,
    required this.takenDoses,
    required this.skippedDoses,
    required this.pendingDoses,
    required this.adherenceRate,
  });
}

class UserStatistics {
  final String userName;
  final int takenDoses;
  final int skippedDoses;
  final int pendingDoses;
  final int adherenceRate;

  UserStatistics({
    required this.userName,
    required this.takenDoses,
    required this.skippedDoses,
    required this.pendingDoses,
    required this.adherenceRate,
  });
}

class _ChartData {
  final String category;
  final int value;
  final Color color;

  _ChartData(this.category, this.value, this.color);
}

class _MedicationStats {
  final String name;
  int takenDoses = 0;
  int skippedDoses = 0;
  int pendingDoses = 0;

  _MedicationStats(this.name);

  int get totalDoses => takenDoses + skippedDoses + pendingDoses;
  int get adherenceRate =>
      totalDoses > 0 ? ((takenDoses / totalDoses) * 100).round() : 0;
}

class _UserStats {
  final String userName;
  int takenDoses = 0;
  int skippedDoses = 0;
  int pendingDoses = 0;

  _UserStats(this.userName);

  int get totalDoses => takenDoses + skippedDoses + pendingDoses;
  int get adherenceRate =>
      totalDoses > 0 ? ((takenDoses / totalDoses) * 100).round() : 0;
}
