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

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  User? _selectedUser;
  bool _showAllUsers = false;
  DateTimeRange? _selectedDateRange;
  late TabController _tabController;
  String _selectedTimePeriod = '30d';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    final userProvider = context.read<UserProvider>();
    _selectedUser = userProvider.activeUser;
    _setDefaultDateRange();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setDefaultDateRange() {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    setState(() {
      _selectedDateRange = DateTimeRange(start: startDate, end: endDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final userProvider = context.watch<UserProvider>();
    
    if (_selectedUser == null) {
      _selectedUser = userProvider.activeUser;
    }

    final stats = reportsProvider.getGeneralStats(
      user: _showAllUsers ? null : _selectedUser,
      dateRange: _selectedDateRange,
    );

    final adherenceStats = _showAllUsers 
      ? reportsProvider.getGeneralStats(dateRange: _selectedDateRange)
      : reportsProvider.getAdherenceStatsForUser(
          _selectedUser!, 
          _selectedDateRange != null 
            ? DateTimeRange(start: _selectedDateRange!.start, end: _selectedDateRange!.end)
            : null
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios e Estatísticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _showFilterDialog(userProvider),
            tooltip: 'Filtrar',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showDateRangePicker,
            tooltip: 'Período',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Visão Geral', icon: Icon(Icons.dashboard)),
            Tab(text: 'Medicamentos', icon: Icon(Icons.medication)),
            Tab(text: 'Tendências', icon: Icon(Icons.trending_up)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(reportsProvider, userProvider, stats, adherenceStats),
          _buildMedicationsTab(reportsProvider, userProvider),
          _buildTrendsTab(reportsProvider, userProvider, stats),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ReportsProvider reportsProvider, UserProvider userProvider, 
      Map<String, dynamic> stats, Map<String, dynamic> adherenceStats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterHeader(userProvider),
              const SizedBox(height: 20),
              _buildMainStatisticsCards(stats, adherenceStats, isSmallScreen),
              const SizedBox(height: 20),
              _buildDosesDistributionChart(adherenceStats),
              const SizedBox(height: 20),
              _buildProgressChart(stats, isSmallScreen),
              const SizedBox(height: 20),
              _buildUpcomingDoses(reportsProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMedicationsTab(ReportsProvider reportsProvider, UserProvider userProvider) {
    final medications = _showAllUsers 
      ? reportsProvider.getPrescriptionsForUser(null)
      : reportsProvider.getPrescriptionsForUser(_selectedUser);

    final topMedications = _showAllUsers
      ? reportsProvider.getTopMedicationsForUser(_selectedUser ?? userProvider.allUsers.first)
      : reportsProvider.getTopMedicationsForUser(_selectedUser!);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(constraints.maxWidth < 600 ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterHeader(userProvider),
              const SizedBox(height: 20),
              _buildTopMedicationsCard(topMedications),
              const SizedBox(height: 20),
              _buildMedicationsList(medications),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendsTab(ReportsProvider reportsProvider, UserProvider userProvider, Map<String, dynamic> stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(constraints.maxWidth < 600 ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterHeader(userProvider),
              const SizedBox(height: 20),
              _buildWeeklyPerformance(stats),
              const SizedBox(height: 20),
              _buildComparativeStats(stats),
              const SizedBox(height: 20),
              _buildInsightsCard(stats),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterHeader(UserProvider userProvider) {
    String filterText = _showAllUsers 
      ? 'Todos os Perfis' 
      : _selectedUser?.name ?? 'Perfil não selecionado';

    String periodText = _selectedDateRange != null
      ? '${DateFormat('dd/MM/yy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yy').format(_selectedDateRange!.end)}'
      : 'Todo o período';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filtros Ativos',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        filterText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Chip(
                    label: Text(
                      periodText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Período: $periodText',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStatisticsCards(Map<String, dynamic> stats, Map<String, dynamic> adherenceStats, bool isSmallScreen) {
  final totalDoses = (stats['takenDoses'] ?? 0) + (stats['skippedDoses'] ?? 0) + (stats['pendingDoses'] ?? 0);
  final uniqueMeds = stats['uniqueMedications'] ?? 0;
  
  final crossAxisCount = isSmallScreen ? 2 : 4;
  // Voltar ao aspect ratio original
  final childAspectRatio = isSmallScreen ? 1.2 : 1.2;

  return GridView.count(
    crossAxisCount: crossAxisCount,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    childAspectRatio: childAspectRatio,
    crossAxisSpacing: isSmallScreen ? 8 : 12,
    mainAxisSpacing: isSmallScreen ? 8 : 12,
    children: [
      _buildStatCard(
        'Total de Doses',
        totalDoses.toString(),
        Icons.format_list_numbered,
        Colors.blue,
        '$uniqueMeds medicamentos',
        isSmallScreen: isSmallScreen,
      ),
      _buildStatCard(
        'Doses Tomadas',
        (stats['takenDoses'] ?? 0).toString(),
        Icons.check_circle,
        Colors.green,
        '${_calculatePercentage(stats['takenDoses'] ?? 0, totalDoses)}% do total',
        isSmallScreen: isSmallScreen,
      ),
      _buildStatCard(
        'Doses Puladas',
        (stats['skippedDoses'] ?? 0).toString(),
        Icons.cancel,
        Colors.orange,
        '${_calculatePercentage(stats['skippedDoses'] ?? 0, totalDoses)}% do total',
        isSmallScreen: isSmallScreen,
      ),
      _buildStatCard(
        'Doses Pendentes',
        (stats['pendingDoses'] ?? 0).toString(),
        Icons.schedule,
        Colors.grey,
        'A serem tomadas',
        isSmallScreen: isSmallScreen,
      ),
    ],
  );
}

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle, {bool isSmallScreen = false}) {
  return Card(
    elevation: 3,
    child: Padding(
      // Voltar ao padding original
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                // Voltar ao tamanho original do ícone
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          // Voltar aos espaçamentos originais
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildDosesDistributionChart(Map<String, dynamic> stats) {
    final taken = stats['takenDoses'] ?? 0;
    final skipped = stats['skippedDoses'] ?? 0;
    final pending = stats['pendingDoses'] ?? 0;
    final totalDoses = taken + skipped + pending;
    
    if (totalDoses == 0) {
      return _buildEmptyStateCard(
        icon: Icons.pie_chart,
        title: 'Nenhuma Dose Registrada',
        message: 'Não há dados de doses para o período selecionado.',
      );
    }

    final chartData = [
      _ChartData('Tomadas ($taken)', taken, Colors.green),
      _ChartData('Puladas ($skipped)', skipped, Colors.orange),
      if (pending > 0)
        _ChartData('Pendentes ($pending)', pending, Colors.grey),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        
        return Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Distribuição de Doses',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text('Total: $totalDoses doses'),
                      backgroundColor: Colors.blue.withOpacity(0.1),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: isSmallScreen ? 180 : 200,
                  child: SfCircularChart(
                    legend: Legend(
                      isVisible: true,
                      position: isSmallScreen ? LegendPosition.bottom : LegendPosition.right,
                      overflowMode: LegendItemOverflowMode.wrap,
                    ),
                    series: <CircularSeries>[
                      DoughnutSeries<_ChartData, String>(
                        dataSource: chartData,
                        xValueMapper: (_ChartData data, _) => data.category,
                        yValueMapper: (_ChartData data, _) => data.value,
                        pointColorMapper: (_ChartData data, _) => data.color,
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          labelPosition: ChartDataLabelPosition.outside,
                          textStyle: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressChart(Map<String, dynamic> stats, bool isSmallScreen) {
    final weeklyData = [
      _ProgressData('Seg', 8, 2, 0),
      _ProgressData('Ter', 10, 1, 0),
      _ProgressData('Qua', 7, 3, 0),
      _ProgressData('Qui', 9, 1, 0),
      _ProgressData('Sex', 8, 2, 0),
      _ProgressData('Sáb', 6, 1, 3),
      _ProgressData('Dom', 5, 0, 5),
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Desempenho Semanal',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: isSmallScreen ? 180 : 200,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                legend: Legend(
                  isVisible: true,
                  position: isSmallScreen ? LegendPosition.bottom : LegendPosition.top,
                ),
                series: <CartesianSeries>[
                  ColumnSeries<_ProgressData, String>(
                    dataSource: weeklyData,
                    xValueMapper: (_ProgressData data, _) => data.day,
                    yValueMapper: (_ProgressData data, _) => data.taken,
                    name: 'Tomadas',
                    color: Colors.green,
                  ),
                  ColumnSeries<_ProgressData, String>(
                    dataSource: weeklyData,
                    xValueMapper: (_ProgressData data, _) => data.day,
                    yValueMapper: (_ProgressData data, _) => data.skipped,
                    name: 'Puladas',
                    color: Colors.orange,
                  ),
                  ColumnSeries<_ProgressData, String>(
                    dataSource: weeklyData,
                    xValueMapper: (_ProgressData data, _) => data.day,
                    yValueMapper: (_ProgressData data, _) => data.pending,
                    name: 'Pendentes',
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildWeeklySummary(weeklyData, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummary(List<_ProgressData> weeklyData, bool isSmallScreen) {
    final totalTaken = weeklyData.fold(0, (sum, day) => sum + day.taken);
    final totalSkipped = weeklyData.fold(0, (sum, day) => sum + day.skipped);
    final totalPending = weeklyData.fold(0, (sum, day) => sum + day.pending);
    final totalDoses = totalTaken + totalSkipped + totalPending;

    return Wrap(
      spacing: isSmallScreen ? 8 : 16,
      runSpacing: 8,
      alignment: WrapAlignment.spaceAround,
      children: [
        _buildSummaryItem('Total Semana', '$totalDoses doses', Colors.blue, isSmallScreen),
        _buildSummaryItem('Tomadas', '$totalTaken doses', Colors.green, isSmallScreen),
        _buildSummaryItem('Puladas', '$totalSkipped doses', Colors.orange, isSmallScreen),
        _buildSummaryItem('Pendentes', '$totalPending doses', Colors.grey, isSmallScreen),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, bool isSmallScreen) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 9 : 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // Os métodos restantes permanecem EXATAMENTE como estavam originalmente
  Widget _buildUpcomingDoses(ReportsProvider reportsProvider) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final upcomingDoses = reportsProvider.allDoseEvents.where((dose) {
      return dose.doseEvent.status == DoseStatus.pendente &&
             dose.doseEvent.scheduledTime.isAfter(now) &&
             dose.doseEvent.scheduledTime.isBefore(tomorrow);
    }).toList();

    if (upcomingDoses.isEmpty) {
      return _buildEmptyStateCard(
        icon: Icons.schedule,
        title: 'Nenhuma Dose Pendente',
        message: 'Não há doses agendadas para as próximas horas.',
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Próximas Doses (Hoje)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text('${upcomingDoses.length} restantes'),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...upcomingDoses.take(5).map((dose) => ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.medication, color: Colors.blue, size: 20),
              ),
              title: Text(dose.prescription.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('HH:mm').format(dose.doseEvent.scheduledTime),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    dose.prescription.doseDescription,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: Text(
                'Estoque: ${dose.prescription.stock}',
                style: TextStyle(
                  fontSize: 12,
                  color: dose.prescription.stock <= 5 ? Colors.orange : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTopMedicationsCard(List<Map<String, dynamic>> topMedications) {
    if (topMedications.isEmpty) {
      return _buildEmptyStateCard(
        icon: Icons.medication,
        title: 'Nenhum Medicamento',
        message: 'Não há dados de medicamentos para o período selecionado.',
      );
    }

    final totalDoses = topMedications.fold(0, (sum, med) => sum + (med['doseCount'] as int));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Medicamentos Mais Utilizados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text('Total: $totalDoses doses'),
                  backgroundColor: Colors.purple.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...topMedications.asMap().entries.map((entry) {
              final index = entry.key;
              final med = entry.value;
              final percentage = _calculatePercentage(med['doseCount'], totalDoses);
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getMedicationColor(index),
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(med['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med['doseDescription'] ?? ''),
                    Text(
                      '$percentage% do total de doses',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${med['doseCount']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const Text(
                      'doses',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsList(List<Prescription> medications) {
    if (medications.isEmpty) {
      return _buildEmptyStateCard(
        icon: Icons.medication_liquid,
        title: 'Nenhum Medicamento',
        message: 'Não há medicamentos cadastrados para o filtro selecionado.',
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Todos os Medicamentos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text('${medications.length} medicamentos'),
                  backgroundColor: Colors.purple.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...medications.map((med) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.medication, color: Colors.purple, size: 20),
                ),
                title: Text(med.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med.doseDescription),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.inventory_2, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Estoque: ${med.stock} doses',
                          style: TextStyle(
                            fontSize: 12,
                            color: med.stock <= 5 ? Colors.orange : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (med.isContinuous)
                      Row(
                        children: [
                          Icon(Icons.autorenew, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          const Text('Tratamento contínuo', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                  ],
                ),
                trailing: Chip(
                  label: Text(med.type),
                  backgroundColor: Colors.purple.withOpacity(0.1),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyPerformance(Map<String, dynamic> stats) {
    final performanceData = [
      _PerformanceData('Segunda', 8, 2),
      _PerformanceData('Terça', 10, 1),
      _PerformanceData('Quarta', 7, 3),
      _PerformanceData('Quinta', 9, 1),
      _PerformanceData('Sexta', 8, 2),
      _PerformanceData('Sábado', 6, 1),
      _PerformanceData('Domingo', 5, 0),
    ];

    final totalTaken = performanceData.fold(0, (sum, day) => sum + day.taken);
    final totalSkipped = performanceData.fold(0, (sum, day) => sum + day.skipped);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Desempenho por Dia da Semana',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                legend: const Legend(isVisible: true),
                series: <CartesianSeries>[
                  ColumnSeries<_PerformanceData, String>(
                    dataSource: performanceData,
                    xValueMapper: (_PerformanceData data, _) => data.day,
                    yValueMapper: (_PerformanceData data, _) => data.taken,
                    name: 'Doses Tomadas',
                    color: Colors.green,
                  ),
                  ColumnSeries<_PerformanceData, String>(
                    dataSource: performanceData,
                    xValueMapper: (_PerformanceData data, _) => data.day,
                    yValueMapper: (_PerformanceData data, _) => data.skipped,
                    name: 'Doses Puladas',
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildPerformanceSummary(totalTaken, totalSkipped),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSummary(int taken, int skipped) {
    final total = taken + skipped;
    final adherenceRate = total > 0 ? ((taken / total) * 100).round() : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryItem('Total Semanal', '$total doses', Colors.blue, false),
        _buildSummaryItem('Taxa de Adesão', '$adherenceRate%', Colors.green, false),
        _buildSummaryItem('Melhor Dia', 'Terça (10 doses)', Colors.green, false),
        _buildSummaryItem('Pior Dia', 'Quarta (3 puladas)', Colors.orange, false),
      ],
    );
  }

  Widget _buildComparativeStats(Map<String, dynamic> stats) {
    final takenDoses = stats['takenDoses'] ?? 0;
    final skippedDoses = stats['skippedDoses'] ?? 0;
    final pendingDoses = stats['pendingDoses'] ?? 0;
    final uniqueMeds = stats['uniqueMedications'] ?? 1;
    
    final totalDoses = takenDoses + skippedDoses + pendingDoses;
    final adherenceRate = totalDoses > 0 ? ((takenDoses / totalDoses) * 100).round() : 0;
    
    final dailyAverage = totalDoses > 0 ? (totalDoses / 30).round() : 0;
    final dosesPerMed = uniqueMeds > 0 ? (totalDoses / uniqueMeds).round() : 0;
    final efficiency = uniqueMeds > 0 ? (takenDoses / uniqueMeds).round() : 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estatísticas do Período',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildComparativeCard('Média Diária', '$dailyAverage doses/dia', Icons.today, Colors.blue),
                _buildComparativeCard('Taxa de Sucesso', '$adherenceRate%', Icons.thumb_up, Colors.green),
                _buildComparativeCard('Doses por Medicamento', '$dosesPerMed doses', Icons.medication, Colors.purple),
                _buildComparativeCard('Eficiência', '$efficiency doses/med', Icons.analytics, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparativeCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(Map<String, dynamic> stats) {
    final takenDoses = stats['takenDoses'] ?? 0;
    final skippedDoses = stats['skippedDoses'] ?? 0;
    final pendingDoses = stats['pendingDoses'] ?? 0;
    final uniqueMeds = stats['uniqueMedications'] ?? 0;
    
    final totalDoses = takenDoses + skippedDoses + pendingDoses;
    final adherenceRate = totalDoses > 0 ? ((takenDoses / totalDoses) * 100).round() : 0;

    final insights = <String>[];
    
    if (totalDoses == 0) {
      insights.add('Não há dados de doses para o período selecionado.');
    } else {
      insights.add('Você tomou $takenDoses doses de $uniqueMeds medicamentos diferentes.');
      
      if (adherenceRate >= 90) {
        insights.add('Excelente! Sua taxa de adesão é de $adherenceRate%.');
      } else if (adherenceRate >= 75) {
        insights.add('Bom trabalho! Sua adesão está em $adherenceRate%.');
      } else {
        insights.add('Sua adesão está em $adherenceRate%. Tente manter a regularidade.');
      }
      
      if (skippedDoses > 0) {
        insights.add('$skippedDoses doses foram puladas neste período.');
      }
      
      if (pendingDoses > 0) {
        insights.add('Atenção: $pendingDoses doses estão pendentes.');
      }
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumo e Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...insights.map((insight) => ListTile(
              leading: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(
                insight,
                style: const TextStyle(fontSize: 14),
              ),
            )),
          ],
        ),
      ),
    );
  }

  int _calculatePercentage(int value, int total) {
    return total > 0 ? ((value / total) * 100).round() : 0;
  }

  Color _getMedicationColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];
    return colors[index % colors.length];
  }

  Widget _buildEmptyStateCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
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
        title: const Text('Filtrar Relatório'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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

  void _showDateRangePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Período'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildPeriodChip('7 dias', const Duration(days: 7)),
                  _buildPeriodChip('30 dias', const Duration(days: 30)),
                  _buildPeriodChip('90 dias', const Duration(days: 90)),
                  _buildPeriodChip('1 ano', const Duration(days: 365)),
                  _buildPeriodChip('Todo período', Duration.zero),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Ou selecione um período personalizado:'),
              const SizedBox(height: 16),
              _buildCustomDateRangePicker(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedDateRange = null;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDateRangePicker() {
    DateTime? startDate;
    DateTime? endDate;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            ListTile(
              title: const Text('Data Inicial'),
              subtitle: startDate != null 
                ? Text(DateFormat('dd/MM/yyyy').format(startDate!))
                : const Text('Selecione a data inicial'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  setState(() => startDate = selectedDate);
                  _updateDateRange(startDate, endDate);
                }
              },
            ),
            ListTile(
              title: const Text('Data Final'),
              subtitle: endDate != null 
                ? Text(DateFormat('dd/MM/yyyy').format(endDate!))
                : const Text('Selecione a data final'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: startDate ?? DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  setState(() => endDate = selectedDate);
                  _updateDateRange(startDate, endDate);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _updateDateRange(DateTime? start, DateTime? end) {
    if (start != null && end != null) {
      setState(() {
        _selectedDateRange = DateTimeRange(start: start, end: end);
      });
      Navigator.of(context).pop();
    }
  }

  Widget _buildPeriodChip(String label, Duration duration) {
    final isSelected = _isPeriodSelected(label, duration);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (duration == Duration.zero) {
          setState(() {
            _selectedDateRange = null;
          });
        } else {
          final endDate = DateTime.now();
          final startDate = endDate.subtract(duration);
          setState(() {
            _selectedDateRange = DateTimeRange(start: startDate, end: endDate);
          });
        }
        Navigator.of(context).pop();
      },
    );
  }

  bool _isPeriodSelected(String label, Duration duration) {
    if (duration == Duration.zero) {
      return _selectedDateRange == null;
    }

    if (_selectedDateRange == null) return false;

    final endDate = DateTime.now();
    final startDate = endDate.subtract(duration);
    
    return _selectedDateRange!.start == startDate && _selectedDateRange!.end == endDate;
  }
}

class _ChartData {
  final String category;
  final int value;
  final Color color;

  _ChartData(this.category, this.value, this.color);
}

class _ProgressData {
  final String day;
  final int taken;
  final int skipped;
  final int pending;

  _ProgressData(this.day, this.taken, this.skipped, this.pending);
}

class _PerformanceData {
  final String day;
  final int taken;
  final int skipped;

  _PerformanceData(this.day, this.taken, this.skipped);
}
