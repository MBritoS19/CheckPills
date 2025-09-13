import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:CheckPills/presentation/providers/medication_provider.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' hide Column;

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
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _notesController = TextEditingController();
  final _treatmentLengthController = TextEditingController();
  final _doseQuantityController = TextEditingController();

  final Map<String, String> _medicationTypeToUnitMap = {
    'Comprimido': 'comprimido(s)',
    'Cápsula': 'unidade(s)',
    'Injeção': 'ml',
    'Gotas': 'gota(s)',
    'Líquido': 'ml',
    'Xarope': 'ml',
    'Inalação': 'dose(s)',
    'Pó': 'mg',
    'Outros': 'unidade(s)',
  };
  final List<String> _allDoseUnits = [
    'unidade(s)',
    'comprimido(s)',
    'cápsula(s)',
    'gota(s)',
    'ml',
    'mg',
    'g',
    'L',
    'dose(s)'
  ];

  @override
  void initState() {
    super.initState();

    _hourIntervalController =
        FixedExtentScrollController(initialItem: _selectedIntervalHour);
    _minuteIntervalController =
        FixedExtentScrollController(initialItem: _selectedIntervalMinute);

    if (widget.prescription != null) {
      _prefillFields();
    }

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
        _validatePage();
      });
    });

    _nameController.addListener(_validatePage);
    _stockController.addListener(_validatePage);
    _customTypeController.addListener(_validatePage);
    _treatmentLengthController.addListener(_validatePage);
    _doseQuantityController.addListener(_validatePage);
    _validatePage();
  }

  void _prefillFields() {
    final p = widget.prescription!;
    _nameController.text = p.name;
    final doseParts = p.doseDescription.split(' ');
    if (doseParts.isNotEmpty) {
      _doseQuantityController.text = doseParts.first;
      if (doseParts.length > 1) {
        _selectedDoseUnit = doseParts.sublist(1).join(' ');
      }
    }
    _selectedType = p.type;
    if (p.doseInterval == 0) {
      _isSingleDose = true;
    }
    if (p.stock == -1) {
      _dontTrackStock = true;
    } else {
      _dontTrackStock = false;
      _stockController.text = p.stock.toString();
    }
    _selectedHour = p.firstDoseTime.hour;
    _selectedMinute = p.firstDoseTime.minute;
    final interval = Duration(minutes: p.doseInterval);
    _selectedIntervalHour = interval.inHours;
    _selectedIntervalMinute = interval.inMinutes.remainder(60);
    _isContinuous = p.isContinuous;
    if (!p.isContinuous) {
      _treatmentLengthController.text = p.durationTreatment?.toString() ?? '';
      _selectedTreatmentUnit = p.unitTreatment ?? 'Dias';
    }
    _notesController.text = p.notes ?? '';
  }

  @override
  void dispose() {
    _nameController.removeListener(_validatePage);
    _stockController.removeListener(_validatePage);
    _customTypeController.removeListener(_validatePage);
    _treatmentLengthController.removeListener(_validatePage);
    _doseQuantityController.removeListener(_validatePage);

    _hourIntervalController.dispose();
    _minuteIntervalController.dispose();
    _pageController.dispose();
    _customTypeController.dispose();
    _nameController.dispose();
    _stockController.dispose();
    _treatmentLengthController.dispose();
    _notesController.dispose();
    _doseQuantityController.dispose();
    super.dispose();
  }

  void _validatePage() {
    bool isValid = false;
    switch (_currentPage) {
      case 0:
        isValid = _nameController.text.isNotEmpty;
        break;
      case 1:
        isValid = _selectedType != null;
        if (_selectedType == 'Outros') {
          isValid = _customTypeController.text.isNotEmpty;
        }
        break;
      case 2: // Validação com o novo controller
        isValid = _doseQuantityController.text.isNotEmpty;
        break;
      case 3:
        isValid = _dontTrackStock || _stockController.text.isNotEmpty;
        break;
      case 4:
      case 5:
        isValid = true;
        break;
      case 6:
        isValid = _isContinuous || _treatmentLengthController.text.isNotEmpty;
        break;
      case 7:
        isValid = true;
        break;
      default:
        isValid = false;
    }
    if (mounted) {
      setState(() {
        _isPageValid = isValid;
      });
    }
  }

  // Adicione este método inteiro na classe

  Widget _buildStockPage({
    required double screenWidth,
  }) {
    const blueColor = Color(0xFF23AFDC);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Quantas doses você tem em estoque?',
              style: TextStyle(
                  fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold)),
          SizedBox(height: screenWidth * 0.06),
          TextFormField(
            controller: _stockController,
            enabled:
                !_dontTrackStock, // Desabilitado se o checkbox estiver marcado
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              fillColor:
                  _dontTrackStock ? Colors.grey[200] : Colors.transparent,
              filled: true,
            ),
          ),
          CheckboxListTile(
            title: const Text('Não controlar estoque'),
            value: _dontTrackStock,
            onChanged: (value) {
              setState(() {
                _dontTrackStock = value!;
                if (_dontTrackStock) {
                  _stockController.clear(); // Limpa o campo ao marcar
                  FocusScope.of(context).unfocus();
                }
                _validatePage(); // Revalida a página
              });
            },
            activeColor: blueColor,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  void _preselectDoseUnit() {
    if (_selectedType != null &&
        _medicationTypeToUnitMap.containsKey(_selectedType)) {
      setState(() {
        _selectedDoseUnit = _medicationTypeToUnitMap[_selectedType]!;
      });
    }
  }

  void _onSave() {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    String finalType;
    if (_selectedType == 'Outros') {
      finalType = _customTypeController.text;
    } else {
      finalType = _selectedType ?? 'Não definido';
    }
    final now = DateTime.now();
    final firstDoseDateTime =
        DateTime(now.year, now.month, now.day, _selectedHour, _selectedMinute);
    final doseIntervalDuration = Duration(
        hours: _selectedIntervalHour, minutes: _selectedIntervalMinute);

    final doseDescription =
        '${_doseQuantityController.text} $_selectedDoseUnit'.trim();

    final prescriptionCompanion = PrescriptionsCompanion(
      name: Value(_nameController.text),
      doseDescription: Value(doseDescription),
      type: Value(finalType),
      stock: Value(
          _dontTrackStock ? -1 : (int.tryParse(_stockController.text) ?? 0)),
      firstDoseTime: Value(firstDoseDateTime),
      doseInterval: Value(_isSingleDose ? 0 : doseIntervalDuration.inMinutes),
      isContinuous: Value(_isSingleDose ? false : _isContinuous),
      durationTreatment: Value(_isSingleDose
          ? 1
          : (_isContinuous
              ? null
              : int.tryParse(_treatmentLengthController.text) ?? 0)),
      unitTreatment: Value(_isSingleDose
          ? 'Dias'
          : (_isContinuous ? null : _selectedTreatmentUnit)),
      notes: Value(_notesController.text),
      updatedAt: Value(DateTime.now()),
    );

    if (widget.prescription != null) {
      provider.updatePrescription(
          widget.prescription!.id, prescriptionCompanion);
    } else {
      provider.addPrescription(prescriptionCompanion.copyWith(
        createdAt: Value(DateTime.now()),
      ));
    }
    Navigator.pop(context);
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
                    _validatePage();
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

  Widget _buildDosePage({
    required double screenWidth,
    required double screenHeight,
  }) {
    // Encontra o índice inicial para o carrossel de unidades
    final initialUnitIndex = _allDoseUnits.indexOf(_selectedDoseUnit);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              'Qual a quantidade de "${_nameController.text}" você deve tomar por vez?',
              style: TextStyle(
                  fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold)),
          SizedBox(height: screenWidth * 0.06),
          Row(
            children: [
              // Campo de texto para a quantidade
              Expanded(
                flex: 2, // Ocupa 2/3 do espaço
                child: TextFormField(
                  controller: _doseQuantityController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 16),
              // Carrossel para a unidade
              Expanded(
                flex: 3, // Ocupa 3/3 do espaço
                child: SizedBox(
                  height: screenHeight * 0.1, // Altura do carrossel
                  child: CupertinoPicker(
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedDoseUnit = _allDoseUnits[index];
                      });
                    },
                    scrollController: FixedExtentScrollController(
                        initialItem:
                            initialUnitIndex != -1 ? initialUnitIndex : 0),
                    children: _allDoseUnits.map((unit) {
                      return Center(child: Text(unit));
                    }).toList(),
                  ),
                ),
              ),
            ],
          )
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

  // Substitua o método inteiro por este
  // Substitua o método inteiro por este
  Widget _buildIntervalPickerPage({
    required double screenWidth,
    required double screenHeight,
  }) {
    const blueColor = Color(0xFF23AFDC);
    const animationDuration = Duration(milliseconds: 300);
    const animationCurve = Curves.easeOut;

    // Condição para desabilitar o seletor de minutos
    final isMinutePickerDisabled = _isSingleDose || _selectedIntervalHour == 24;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Qual o intervalo entre as doses?',
              style: TextStyle(
                  fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold)),
          SizedBox(height: screenWidth * 0.04),
          CheckboxListTile(
            title: const Text('Uma dose apenas'),
            value: _isSingleDose,
            onChanged: (value) {
              setState(() {
                _isSingleDose = value!;
                _validatePage();
              });
            },
            activeColor: blueColor,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          SizedBox(height: screenWidth * 0.04),
          Opacity(
            opacity: _isSingleDose ? 0.5 : 1.0,
            child: AbsorbPointer(
              absorbing: _isSingleDose,
              child: SizedBox(
                height: screenHeight * 0.2,
                child: Row(
                  children: [
                    // Seletor de Horas
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 40,
                        scrollController: _hourIntervalController,
                        onSelectedItemChanged: (newHour) {
                          setState(() {
                            _selectedIntervalHour = newHour;

                            // Regra 2: Se hora for 24, trava minutos em 0
                            if (newHour == 24) {
                              if (_selectedIntervalMinute != 0) {
                                _selectedIntervalMinute = 0;
                                _minuteIntervalController.animateToItem(0,
                                    duration: animationDuration,
                                    curve: animationCurve);
                              }
                            }
                            // Regra 1: Se hora for 0 e minutos < 30, ajusta para 30
                            else if (newHour == 0 &&
                                _selectedIntervalMinute < 30) {
                              _selectedIntervalMinute = 30;
                              _minuteIntervalController.animateToItem(30,
                                  duration: animationDuration,
                                  curve: animationCurve);
                            }
                          });
                        },
                        looping: true,
                        // Aumenta o número de itens para 25 (0 a 24)
                        children: List.generate(25, (index) {
                          return Center(
                              child: Text(
                                  '${index.toString().padLeft(2, '0')} h'));
                        }),
                      ),
                    ),
                    // Seletor de Minutos
                    Expanded(
                      child: Opacity(
                        opacity: isMinutePickerDisabled ? 0.5 : 1.0,
                        child: AbsorbPointer(
                          absorbing: isMinutePickerDisabled,
                          child: CupertinoPicker(
                            itemExtent: 40,
                            scrollController: _minuteIntervalController,
                            onSelectedItemChanged: (newMinute) {
                              setState(() {
                                int targetMinute = newMinute;
                                // Regra 1: Se hora for 0 e tentar selecionar < 30, força 30
                                if (_selectedIntervalHour == 0 &&
                                    newMinute < 30) {
                                  targetMinute = 30;
                                }
                                _selectedIntervalMinute = targetMinute;

                                // Se a seleção foi invalidada, anima de volta
                                if (targetMinute != newMinute) {
                                  _minuteIntervalController.animateToItem(
                                      targetMinute,
                                      duration: animationDuration,
                                      curve: animationCurve);
                                }
                              });
                            },
                            looping: true,
                            children: List.generate(60, (index) {
                              return Center(
                                  child: Text(
                                      '${index.toString().padLeft(2, '0')} min'));
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                  enabled: !_isContinuous,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  // CORREÇÃO: `value` trocado por `initialValue`
                  initialValue: _selectedTreatmentUnit,
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
          CheckboxListTile(
            title: const Text('Uso constante'),
            value: _isContinuous,
            onChanged: (value) {
              setState(() {
                _isContinuous = value!;
                if (_isContinuous) {
                  _treatmentLengthController.clear();
                  _selectedTreatmentUnit = 'Dias';
                }
                _validatePage(); // Revalida a página ao mudar o checkbox
              });
            },
            activeColor: blueColor,
            controlAffinity: ListTileControlAffinity.leading,
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
      _buildDosePage(screenWidth: screenWidth, screenHeight: screenHeight),
      _buildStockPage(screenWidth: screenWidth),
      _buildTimePickerPage(
          screenWidth: screenWidth, screenHeight: screenHeight),
      _buildIntervalPickerPage(
          screenWidth: screenWidth, screenHeight: screenHeight),
      if (!_isSingleDose) _buildDurationPage(screenWidth: screenWidth),
      _buildFormPage(
          title: 'Alguma observação?',
          subtitle: 'Este campo é opcional',
          controller: _notesController,
          keyboardType: TextInputType.multiline,
          screenWidth: screenWidth,
          isLastPage: true),
    ];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
                title: Text(widget.prescription != null
                    ? 'Editar Medicamento'
                    : 'Adicionar Medicamento'),
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
                    onPressed: _onSave,
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
                              FocusScope.of(context).unfocus();
                              _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn);
                            },
                      child: const Text('Anterior'),
                    ),
                    ElevatedButton(
                      onPressed: (_isPageValid &&
                              _currentPage < formPages.length - 1)
                          ? () {
                              FocusScope.of(context).unfocus();
                              // Se estamos na página de tipo (índice 1),
                              // pré-selecionamos a unidade ANTES de navegar.
                              if (_currentPage == 1) {
                                _preselectDoseUnit();
                              }
                              _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn);
                            }
                          : null,
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
