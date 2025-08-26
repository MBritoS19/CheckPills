import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:primeiro_flutter/domain/entities/medication.dart';
import 'package:primeiro_flutter/presentation/providers/medication_provider.dart';
import 'package:provider/provider.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  int _selectedHour = DateTime.now().hour;
  int _selectedMinute = DateTime.now().minute;
  int _selectedIntervalHour = 8;
  int _selectedIntervalMinute = 0;

  String? _selectedType;
  final _customTypeController = TextEditingController();

  // 1. Novas variáveis de estado para a duração do tratamento
  bool _isContinuous = false;
  final _treatmentLengthController = TextEditingController();
  String _selectedTreatmentUnit = 'Dias';

  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _stockController = TextEditingController();
  final _notesController = TextEditingController();
  // final _totalDosesController foi removido

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
    _customTypeController.dispose();
    _nameController.dispose();
    _doseController.dispose();
    _stockController.dispose();
    _treatmentLengthController.dispose(); // Adicionado
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
          Text(title,
              style: TextStyle(
                  fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            SizedBox(height: screenWidth * 0.02),
            Text(subtitle,
                style: TextStyle(
                    fontSize: screenWidth * 0.04, color: Colors.grey)),
          ],
          SizedBox(height: screenWidth * 0.06),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: keyboardType == TextInputType.multiline ? 3 : 1,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelectionPage({
    required double screenWidth,
  }) {
    const types = [
      'Comprimido',
      'Injeção',
      'Gotas',
      'Líquido',
      'Inalação',
      'Pó',
      'Outros'
    ];
    const blueColor = Color(0xFF23AFDC);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Qual o tipo do medicamento?',
              style: TextStyle(
                  fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: types.map((type) {
              final isSelected = _selectedType == type;
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedType = type;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? blueColor : Colors.grey[200],
                  foregroundColor: isSelected ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(type),
              );
            }).toList(),
          ),
          if (_selectedType == 'Outros') ...[
            const SizedBox(height: 24),
            TextFormField(
              controller: _customTypeController,
              decoration: const InputDecoration(
                labelText: 'Digite o tipo do medicamento',
                border: OutlineInputBorder(),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildTimePickerPage({
    required double screenWidth,
    required double screenHeight,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Qual o horário da primeira dose?',
              style: TextStyle(
                  fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold)),
          SizedBox(height: screenWidth * 0.06),
          SizedBox(
            height: screenHeight * 0.2,
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedHour = index;
                      });
                    },
                    scrollController:
                        FixedExtentScrollController(initialItem: _selectedHour),
                    looping: true,
                    children: List.generate(24, (index) {
                      return Center(
                          child: Text('${index.toString().padLeft(2, '0')} h'));
                    }),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedMinute = index;
                      });
                    },
                    scrollController: FixedExtentScrollController(
                        initialItem: _selectedMinute),
                    looping: true,
                    children: List.generate(60, (index) {
                      return Center(
                          child:
                              Text('${index.toString().padLeft(2, '0')} min'));
                    }),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIntervalPickerPage({
    required double screenWidth,
    required double screenHeight,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Qual o intervalo entre as doses?',
              style: TextStyle(
                  fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold)),
          SizedBox(height: screenWidth * 0.06),
          SizedBox(
            height: screenHeight * 0.2,
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedIntervalHour = index;
                      });
                    },
                    scrollController: FixedExtentScrollController(
                        initialItem: _selectedIntervalHour),
                    looping: true,
                    children: List.generate(24, (index) {
                      return Center(
                          child: Text('${index.toString().padLeft(2, '0')} h'));
                    }),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedIntervalMinute = index;
                      });
                    },
                    scrollController: FixedExtentScrollController(
                        initialItem: _selectedIntervalMinute),
                    looping: true,
                    children: List.generate(60, (index) {
                      return Center(
                          child:
                              Text('${index.toString().padLeft(2, '0')} min'));
                    }),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 2. Nova função para construir a página de duração
  Widget _buildDurationPage({
    required double screenWidth,
  }) {
    final units = ['Dias', 'Semanas', 'Meses', 'Anos'];
    const blueColor = Color(0xFF23AFDC);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Qual a duração do tratamento?',
              style: TextStyle(
                  fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold)),
          SizedBox(height: screenWidth * 0.06),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _treatmentLengthController,
                  // O campo fica desativado se `_isContinuous` for verdadeiro
                  enabled: !_isContinuous,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedTreatmentUnit,
                  // O menu também fica desativado se `_isContinuous` for verdadeiro
                  onChanged: _isContinuous
                      ? null
                      : (value) {
                          setState(() {
                            _selectedTreatmentUnit = value!;
                          });
                        },
                  items: units.map((unit) {
                    return DropdownMenuItem(value: unit, child: Text(unit));
                  }).toList(),
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          // Usamos CheckboxListTile para ter o texto e a caixa de seleção juntos
          CheckboxListTile(
            title: const Text('Uso constante'),
            value: _isContinuous,
            onChanged: (value) {
              setState(() {
                _isContinuous = value!;
                // Se o usuário marcar a caixa, limpamos os outros campos
                if (_isContinuous) {
                  _treatmentLengthController.clear();
                  _selectedTreatmentUnit = 'Dias';
                }
              });
            },
            activeColor: blueColor,
            controlAffinity:
                ListTileControlAffinity.leading, // Caixa à esquerda
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    const orangeColor = Color(0xFFDC5023);
    const blueColor = Color(0xFF23AFDC);

    final List<Widget> formPages = [
      _buildFormPage(
          title: 'Qual o nome do medicamento?',
          controller: _nameController,
          keyboardType: TextInputType.text,
          screenWidth: screenWidth),
      _buildTypeSelectionPage(screenWidth: screenWidth),
      _buildFormPage(
          title:
              'Qual a quantidade de "${_nameController.text}" você deve tomar por vez?',
          subtitle: 'Ex: 1 comprimido, 500mg, 10ml',
          controller: _doseController,
          keyboardType: TextInputType.text,
          screenWidth: screenWidth),
      _buildFormPage(
          title: 'Quantas doses você tem em estoque?',
          controller: _stockController,
          keyboardType: TextInputType.number,
          screenWidth: screenWidth),
      _buildTimePickerPage(
          screenWidth: screenWidth, screenHeight: screenHeight),
      _buildIntervalPickerPage(
          screenWidth: screenWidth, screenHeight: screenHeight),

      // A página de total de doses foi substituída pela nossa nova página de duração
      _buildDurationPage(screenWidth: screenWidth),

      _buildFormPage(
          title: 'Alguma observação?',
          subtitle: 'Este campo é opcional',
          controller: _notesController,
          keyboardType: TextInputType.multiline,
          screenWidth: screenWidth,
          isLastPage: true),
    ];

    // MUDANÇA 1: Envolvemos o widget principal com um GestureDetector.
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20.0))),
                title: const Text('Adicionar Medicamento'),
                leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
                automaticallyImplyLeading: false,
              ),
              FormProgressBar(
                  totalPages: formPages.length,
                  currentPage: _currentPage,
                  activeColor: orangeColor,
                  completedColor: blueColor),
              SizedBox(
                height: screenHeight * 0.4,
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
                      vertical: screenWidth * 0.02),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(screenHeight * 0.06),
                        backgroundColor: blueColor,
                        foregroundColor: Colors.black),
                        
                    onPressed: () {
                      final provider = Provider.of<MedicationProvider>(context,
                          listen: false);
                      String finalType;
                      if (_selectedType == 'Outros') {
                        finalType = _customTypeController.text;
                      } else {
                        finalType = _selectedType ?? 'Não definido';
                      }
                      final now = DateTime.now();
                      final firstDoseDateTime = DateTime(now.year, now.month,
                          now.day, _selectedHour, _selectedMinute);
                      final doseIntervalDuration = Duration(
                          hours: _selectedIntervalHour,
                          minutes: _selectedIntervalMinute);
                      final newMedication = Medication(
                        name: _nameController.text,
                        dose: _doseController.text,
                        type: finalType,
                        stock: int.tryParse(_stockController.text) ?? 0,
                        firstDoseTime: firstDoseDateTime,
                        doseInterval: doseIntervalDuration,

                        // 4. ATUALIZAÇÃO na lógica de salvar
                        isContinuous: _isContinuous,
                        treatmentLength: _isContinuous
                            ? null
                            : int.tryParse(_treatmentLengthController.text) ??
                                0,
                        treatmentUnit:
                            _isContinuous ? null : _selectedTreatmentUnit,

                        notes: _notesController.text,
                      );
                      provider.addMedication(newMedication);
                      Navigator.pop(context);
                    },
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
                              // MUDANÇA 2: Adicionamos o comando para fechar o teclado.
                              FocusScope.of(context).unfocus();
                              _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn);
                            },
                      child: const Text('Anterior'),
                    ),
                    ElevatedButton(
                      onPressed: _currentPage == formPages.length - 1
                          ? null
                          : () {
                              // MUDANÇA 3: E aqui também.
                              FocusScope.of(context).unfocus();
                              _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn);
                            },
                      child: const Text('Próximo'),
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
