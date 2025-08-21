import 'package:flutter/material.dart';
import 'package:checkpills/data/datasources/medication_local_datasource_impl.dart';
import 'package:checkpills/data/repositories/medication_repository_impl.dart';
import 'package:checkpills/domain/usecases/get_medications_usecase.dart';
import 'package:checkpills/domain/usecases/add_medication_usecase.dart';
import 'package:checkpills/presentation/providers/medication_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar dependências
  final localDataSource = MedicationLocalDataSourceImpl();
  final repository = MedicationRepositoryImpl(localDataSource: localDataSource);
  final getMedicationsUseCase = GetMedicationsUseCase(repository: repository);
  final addMedicationUseCase = AddMedicationUseCase(repository: repository);

  // Inicializar dados padrão
  await repository.initializeDefaultMedications();

  runApp(
    ChangeNotifierProvider(
      create: (context) => MedicationProvider(
        getMedicationsUseCase: getMedicationsUseCase,
        addMedicationUseCase: addMedicationUseCase,
        repository: repository,
      )..initialize(),
      child: const MyApp(),
    ),
  );
}
