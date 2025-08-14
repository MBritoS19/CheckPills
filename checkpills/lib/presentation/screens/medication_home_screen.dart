import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkpills/presentation/view_models/medication_home_viewmodel.dart';
import 'package:checkpills/presentation/widgets/medication_card.dart';
import 'package:checkpills/presentation/screens/add_medication_screen.dart'; // Novo import

class MedicationHomeScreen extends StatelessWidget {
  const MedicationHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CheckPills'),
        backgroundColor: Colors.blue,
      ),
      body: Consumer<MedicationHomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: viewModel.medications.length,
            itemBuilder: (context, index) => MedicationCard(
              name: viewModel.medications[index].name,
              dosage: viewModel.medications[index].dosage,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMedicationScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
