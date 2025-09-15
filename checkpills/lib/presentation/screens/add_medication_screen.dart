// lib/presentation/screens/add_medication_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:CheckPills/presentation/providers/medication_provider.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:CheckPills/presentation/providers/patient_provider.dart';

class AddMedicationScreen extends StatefulWidget {
  final Prescription? prescription;

  const AddMedicationScreen({
    super.key,
    this.prescription,
  });

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isPageValid = false;

  int _selectedHour = DateTime.now().hour;
  int _selectedMinute = DateTime.now().minute;
  int _selectedIntervalHour = 8;
  int _selectedIntervalMinute = 0;
  String? _selectedType;
  bool _isContinuous = false;
  String _selectedTreatmentUnit = 'Dias';
  String _selectedDoseUnit = 'unidade(s)';
  bool _dontTrackStock = false;
  bool _isSingleDose = false;

  late FixedExtentScrollController _hourIntervalController;
  late FixedExtentScrollController _minuteIntervalController;

  final _customTypeController = TextEditingController();
  final _medicationNameController = TextEditingController();
  final _doseDescriptionController = TextEditingController();
  final _stockController = TextEditingController();
  final _durationController = TextEditingController();
  final _refillReminderController = TextEditingController();

  Patient? _selectedPatient;

  @override
  void initState() {
    super.initState();
    _hourIntervalController = FixedExtentScrollController(
      initialItem: _selectedIntervalHour,
    );
    _minuteIntervalController = FixedExtentScrollController(
      initialItem: _selectedIntervalMinute,
    );

    if (widget.prescription != null) {
      final p = widget.prescription!;
      _medicationNameController.text = p.name;
      _doseDescriptionController.text = p.doseDescription;
      _selectedType = p.type;
      _stockController.text = p.stock.toString();
      _isContinuous = p.isContinuous;
      if (p.durationTreatment != null) {
        _durationController.text = p.durationTreatment.toString();
      }
      _selectedTreatmentUnit = p.unitTreatment ?? 'Dias';
      _selectedHour = p.firstDoseTime.hour;
      _selectedMinute = p.firstDoseTime.minute;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _customTypeController.dispose();
    _medicationNameController.dispose();
    _doseDescriptionController.dispose();
    _stockController.dispose();
    _durationController.dispose();
    _refillReminderController.dispose();
    _hourIntervalController.dispose();
    _minuteIntervalController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _isPageValid = _validatePage();
    });
  }

  bool _validatePage() {
    switch (_currentPage) {
      case 0:
        return _validatePage1();
      case 1:
        return _validatePage2();
      case 2:
        return _validatePage3();
      default:
        return false;
    }
  }

  bool _validatePage1() {
    return _selectedPatient != null && _medicationNameController.text.isNotEmpty;
  }

  bool _validatePage2() {
    if (_isContinuous) {
      return _stockController.text.isNotEmpty;
    } else {
      return _stockController.text.isNotEmpty &&
          _durationController.text.isNotEmpty;
    }
  }

  bool _validatePage3() {
    return _selectedType != null &&
        (_selectedType != 'Outro' || _customTypeController.text.isNotEmpty);
  }

  void _nextPage() {
    if (_validatePage()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  Future<void> _savePrescription() async {
    final medicationProvider =
        Provider.of<MedicationProvider>(context, listen: false);

    final durationTreatment =
        _isContinuous ? null : int.tryParse(_durationController.text);
    final durationUnit = _isContinuous ? null : _selectedTreatmentUnit;
    final firstDoseTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      _selectedHour,
      _selectedMinute,
    );
    final doseInterval =
        (_selectedIntervalHour * 60) + _selectedIntervalMinute;

    if (widget.prescription == null) {
      final newPrescription = PrescriptionsCompanion.insert(
        patientId: _selectedPatient!.id,
        name: _medicationNameController.text,
        doseDescription: _doseDescriptionController.text,
        type: _selectedType!,
        stock: int.parse(_stockController.text),
        doseInterval: doseInterval,
        isContinuous: _isContinuous,
        durationTreatment: Value(durationTreatment),
        unitTreatment: Value(durationUnit),
        firstDoseTime: firstDoseTime,
      );

      await medicationProvider.addPrescription(newPrescription);
    } else {
      final updatedPrescription = PrescriptionsCompanion(
        id: Value(widget.prescription!.id),
        patientId: Value(_selectedPatient!.id),
        name: Value(_medicationNameController.text),
        doseDescription: Value(_doseDescriptionController.text),
        type: Value(_selectedType!),
        stock: Value(int.parse(_stockController.text)),
        doseInterval: Value(doseInterval),
        isContinuous: Value(_isContinuous),
        durationTreatment: Value(durationTreatment),
        unitTreatment: Value(durationUnit),
        firstDoseTime: Value(firstDoseTime),
      );

      await medicationProvider.updatePrescription(updatedPrescription);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  Widget _buildPage1() {
    final patientProvider = context.watch<PatientProvider>();
    final patients = patientProvider.patientList;

    if (patients.isEmpty) {
      return const Center(
        child: Text(
          'Por favor, adicione um paciente antes de criar uma prescrição.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListView(
        children: [
          DropdownButtonFormField<Patient>(
            decoration: const InputDecoration(labelText: 'Paciente'),
            value: _selectedPatient,
            items: patients.map((patient) {
              return DropdownMenuItem<Patient>(
                value: patient,
                child: Text(patient.name),
              );
            }).toList(),
            onChanged: (Patient? newValue) {
              setState(() {
                _selectedPatient = newValue;
                _isPageValid = _validatePage1();
              });
            },
            validator: (value) =>
                value == null ? 'Por favor, selecione um paciente' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _medicationNameController,
            decoration:
                const InputDecoration(labelText: 'Nome do Medicamento'),
            onChanged: (value) {
              setState(() => _isPageValid = _validatePage1());
            },
            validator: (value) => value!.isEmpty
                ? 'Por favor, insira o nome do medicamento'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _doseDescriptionController,
            decoration: const InputDecoration(labelText: 'Dose (ex: 1 comprimido)'),
            onChanged: (value) {
              setState(() => _isPageValid = _validatePage1());
            },
            validator: (value) =>
                value!.isEmpty ? 'Por favor, insira a dose' : null,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListView(
        children: [
          SwitchListTile(
            title: const Text('Medicação de uso contínuo?'),
            value: _isContinuous,
            onChanged: (bool value) {
              setState(() {
                _isContinuous = value;
                _isPageValid = _validatePage2();
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _stockController,
            decoration: const InputDecoration(labelText: 'Estoque inicial'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() => _isPageValid = _validatePage2());
            },
          ),
          const SizedBox(height: 16),
          if (!_isContinuous)
            TextField(
              controller: _durationController,
              decoration: InputDecoration(
                labelText: 'Duração do tratamento',
                suffixIcon: DropdownButtonFormField<String>(
                  value: _selectedTreatmentUnit,
                  items: ['Dias', 'Semanas', 'Meses', 'Anos']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTreatmentUnit = newValue!;
                    });
                  },
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                  setState(() => _isPageValid = _validatePage2());
                },
            ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _refillReminderController,
                  decoration: const InputDecoration(
                    labelText: 'Lembrete de refil',
                    suffixText: 'doses restantes',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Tipo de Medicamento'),
            value: _selectedType,
            items: [
              'Comprimido',
              'Cápsula',
              'Líquido (ml)',
              'Gotas',
              'Outro',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedType = newValue;
                _isPageValid = _validatePage3();
              });
            },
            validator: (value) =>
                value == null ? 'Por favor, selecione um tipo' : null,
          ),
          const SizedBox(height: 16),
          if (_selectedType == 'Outro')
            TextField(
              controller: _customTypeController,
              decoration:
                  const InputDecoration(labelText: 'Descreva o tipo'),
              onChanged: (value) {
                setState(() => _isPageValid = _validatePage3());
              },
            ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: DateTime.now(),
              onDateTimeChanged: (DateTime newDateTime) {
                setState(() {
                  _selectedHour = newDateTime.hour;
                  _selectedMinute = newDateTime.minute;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Intervalo entre as doses',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 150,
                  child: CupertinoPicker(
                    scrollController: _hourIntervalController,
                    itemExtent: 32,
                    onSelectedItemChanged: (index) {
                      _selectedIntervalHour = index;
                    },
                    children: List.generate(
                      24,
                      (index) => Text('$index h'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 150,
                  child: CupertinoPicker(
                    scrollController: _minuteIntervalController,
                    itemExtent: 32,
                    onSelectedItemChanged: (index) {
                      _selectedIntervalMinute = index;
                    },
                    children: List.generate(
                      60,
                      (index) => Text('$index min'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(widget.prescription == null
              ? 'Adicionar Medicamento'
              : 'Editar Medicamento'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              FormProgressBar(
                totalPages: 3,
                currentPage: _currentPage,
                activeColor: const Color(0xFF23AFDC),
                completedColor: const Color(0xFF23AFDC),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: _onPageChanged,
                  children: [
                    _buildPage1(),
                    _buildPage2(),
                    _buildPage3(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      ElevatedButton(
                        onPressed: _previousPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Anterior'),
                      ),
                    ElevatedButton(
                      onPressed: _isPageValid
                          ? (_currentPage < 2 ? _nextPage : _savePrescription)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPageValid
                            ? const Color(0xFF23AFDC)
                            : Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_currentPage < 2 ? 'Próximo' : 'Salvar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FormProgressBar extends StatelessWidget {
  final int totalPages;
  final int currentPage;
  final Color activeColor;
  final Color completedColor;

  const FormProgressBar({
    super.key,
    required this.totalPages,
    required this.currentPage,
    required this.activeColor,
    required this.completedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
      child: Row(
        children: List.generate(totalPages, (index) {
          bool isCompleted = currentPage == totalPages - 1;
          bool isActive = index <= currentPage;
          Color barColor;
          if (isCompleted) {
            barColor = completedColor;
          } else if (isActive) {
            barColor = activeColor;
          } else {
            barColor = Colors.grey[300]!;
          }

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              height: 4.0,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          );
        }),
      ),
    );
  }
}
