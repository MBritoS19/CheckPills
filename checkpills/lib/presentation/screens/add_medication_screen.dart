import 'package:checkpills/core/constants/medication_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkpills/core/constants/app_constants.dart';
import 'package:checkpills/core/utils/medication_utils.dart';
import 'package:checkpills/domain/entities/medication_entity.dart';
import 'package:checkpills/presentation/providers/medication_provider.dart';
import 'package:checkpills/presentation/widgets/form_progress_bar.dart';
import 'package:checkpills/presentation/widgets/medication_type_selection.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  String? _selectedType;

  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _stockController = TextEditingController();
  final _firstDoseTimeController = TextEditingController();
  final _intervalController = TextEditingController();
  final _totalDosesController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _doseController.dispose();
    _stockController.dispose();
    _firstDoseTimeController.dispose();
    _intervalController.dispose();
    _totalDosesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Widget _buildFormPage({
    required String title,
    String? subtitle,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required double screenWidth,
    bool isLastPage = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.055,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: screenWidth * 0.02),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.grey,
              ),
            ),
          ],
          SizedBox(height: screenWidth * 0.06),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: keyboardType == TextInputType.multiline ? 3 : 1,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  void _saveMedication(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context, listen: false);

    final newMedication = MedicationEntity(
      id: MedicationUtils.generateId(),
      name: _nameController.text,
      dose: _doseController.text,
      type: _selectedType ?? MedicationConstants().defaultType,
      stock: int.tryParse(_stockController.text) ?? 0,
      firstDoseTime: _firstDoseTimeController.text,
      doseIntervalInHours: int.tryParse(_intervalController.text) ?? 0,
      totalDoses: int.tryParse(_totalDosesController.text) ?? 0,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    provider.addMedication(newMedication);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final List<Widget> formPages = [
      _buildFormPage(
        title: 'Qual o nome do medicamento?',
        controller: _nameController,
        keyboardType: TextInputType.text,
        screenWidth: screenWidth,
      ),
      _buildFormPage(
        title: 'Qual a dose?',
        subtitle: 'Ex: 1 comprimido, 500mg, 10ml',
        controller: _doseController,
        keyboardType: TextInputType.text,
        screenWidth: screenWidth,
      ),
      MedicationTypeSelection(
        selectedType: _selectedType,
        onTypeSelected: (type) {
          setState(() {
            _selectedType = type;
          });
        },
        screenWidth: screenWidth,
      ),
      _buildFormPage(
        title: 'Quantas doses você tem em estoque?',
        controller: _stockController,
        keyboardType: TextInputType.number,
        screenWidth: screenWidth,
      ),
      _buildFormPage(
        title: 'Qual o horário da primeira dose?',
        subtitle: 'Use o formato HH:MM (ex: 08:00)',
        controller: _firstDoseTimeController,
        keyboardType: TextInputType.datetime,
        screenWidth: screenWidth,
      ),
      _buildFormPage(
        title: 'Qual o intervalo entre as doses (em horas)?',
        controller: _intervalController,
        keyboardType: TextInputType.number,
        screenWidth: screenWidth,
      ),
      _buildFormPage(
        title: 'Qual o total de doses do tratamento?',
        controller: _totalDosesController,
        keyboardType: TextInputType.number,
        screenWidth: screenWidth,
      ),
      _buildFormPage(
        title: 'Alguma observação?',
        subtitle: 'Este campo é opcional',
        controller: _notesController,
        keyboardType: TextInputType.multiline,
        screenWidth: screenWidth,
        isLastPage: true,
      ),
    ];

    return SizedBox(
      height: screenHeight * 0.7,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          title: const Text('Adicionar Medicamento'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            FormProgressBar(
              totalPages: formPages.length,
              currentPage: _currentPage,
              activeColor: AppColors.primaryOrange,
              completedColor: AppColors.primaryBlue,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: formPages,
              ),
            ),
            if (_currentPage == formPages.length - 1)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenWidth * 0.02,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(screenHeight * 0.06),
                    backgroundColor: AppColors.primaryBlue,
                  ),
                  onPressed: () => _saveMedication(context),
                  child: const Text('Salvar Medicamento'),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _currentPage == 0
                        ? null
                        : () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                    child: const Text('Anterior'),
                  ),
                  ElevatedButton(
                    onPressed: _currentPage == formPages.length - 1
                        ? null
                        : () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                    child: const Text('Próximo'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
