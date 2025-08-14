import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importação essencial
import 'package:checkpills/core/theme/app_theme.dart';
import 'package:checkpills/presentation/screens/medication_home_screen.dart';
import 'package:checkpills/data/datasources/local/medication_local_datasource.dart';
import 'package:checkpills/data/repositories/medication_repository_impl.dart';
import 'package:checkpills/domain/repositories/medication_repository.dart';
import 'package:checkpills/domain/usecases/get_today_medications.dart';
import 'package:checkpills/domain/usecases/add_medication.dart';
import 'package:checkpills/presentation/view_models/medication_home_viewmodel.dart';

void main() {
  // 1. Configuração inicial
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicialização de dependências
  final MedicationLocalDataSource localDataSource =
      MedicationLocalDataSourceImpl();
  final MedicationRepository repository = MedicationRepositoryImpl(
    localDataSource: localDataSource,
  );
  final GetTodayMedications getTodayMedications = GetTodayMedications(
    repository,
  );
  final AddMedication addMedication = AddMedication(repository);

  // 3. Execução do app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MedicationHomeViewModel(
            getTodayMedications: getTodayMedications,
            addMedication: addMedication,
          )..loadMedications(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Med',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MedicationHomeScreen(),
    );
  }
}
