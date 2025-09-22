import 'package:CheckPills/presentation/providers/medication_provider.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

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
  DateTime _selectedFirstDoseDate = DateTime.now();

  int _selectedHour = DateTime.now().hour;
  int _selectedMinute = DateTime.now().minute;
  int _selectedIntervalHour = 8;
  int _selectedIntervalMinute = 0;
  String? _selectedType;
  String? _imagePath;
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

  @override
  void didUpdateWidget(covariant AddMedicationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se o medicamento passado para a tela mudou,
    // preenchemos os campos novamente.
    if (widget.prescription != oldWidget.prescription) {
      _prefillFields();
    }
  }

  void _prefillFields() {
    final p = widget.prescription!;
    _imagePath = p.imagePath;
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

  // Adicione este método dentro da classe _AddMedicationScreenState
  Future<void> _pickAndSaveImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedFile =
        await imagePicker.pickImage(source: source, imageQuality: 50);

    if (pickedFile == null) return;

    // Encontra a pasta de documentos do app
    final appDir = await getApplicationDocumentsDirectory();
    // Cria um nome de arquivo único
    final fileName = p.basename(pickedFile.path);
    // Define o caminho de destino para salvar a imagem
    final savedImagePath = p.join(appDir.path, fileName);

    // Copia o arquivo para o novo caminho
    final file = File(pickedFile.path);
    await file.copy(savedImagePath);

    setState(() {
      _imagePath = savedImagePath;
    });
  }

  // Adicione este método inteiro na classe

  Widget _buildStockPage({
    required double screenWidth,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Quantas doses você tem em estoque?',
                style: TextStyle(
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold)),
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
              activeColor: Theme.of(context).colorScheme.primary,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
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

  // Em: lib/presentation/screens/add_medication_screen.dart

  void _onSave() {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    String finalType;
    if (_selectedType == 'Outros') {
      finalType = _customTypeController.text;
    } else {
      finalType = _selectedType ?? 'Não definido';
    }
    final firstDoseDateTime = DateTime(
        _selectedFirstDoseDate.year,
        _selectedFirstDoseDate.month,
        _selectedFirstDoseDate.day,
        _selectedHour,
        _selectedMinute);
    final doseIntervalDuration = Duration(
        hours: _selectedIntervalHour, minutes: _selectedIntervalMinute);

    final doseDescription =
        '${_doseQuantityController.text} $_selectedDoseUnit'.trim();

    final prescriptionCompanion = PrescriptionsCompanion(
      name: Value(_nameController.text),
      imagePath: Value(_imagePath),
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
      // MODO EDIÇÃO: Adicionamos o userId ao companion antes de enviar
      final finalCompanion = prescriptionCompanion.copyWith(
        userId: Value(widget.prescription!.userId),
      );
      provider.updatePrescription(widget.prescription!.id, finalCompanion);
    } else {
      // MODO ADIÇÃO: O provider irá adicionar o userId e o createdAt
      provider.addPrescription(prescriptionCompanion);
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold)),
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Qual o tipo do medicamento?',
                style: TextStyle(
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            // NOVO CÓDIGO COM CHOICECHIP
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: types.map((type) {
                return ChoiceChip(
                  label: Text(type,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  selected: _selectedType == type,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedType = type;
                        _validatePage();
                      }
                    });
                  },
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
      ),
    );
  }

  Widget _buildDosePage({
    required double screenWidth,
    required double screenHeight,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Qual a quantidade de "${_nameController.text}" você deve tomar por vez?',
                style: TextStyle(
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold)),
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
                  flex: 3, // Ocupa 3/5 do espaço
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedDoseUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unidade',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0), // Ajuste opcional de padding
                    ),
                    items: _allDoseUnits.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        if (newValue != null) {
                          _selectedDoseUnit = newValue;
                        }
                      });
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Substitua o método inteiro por este
  // Substitua o método inteiro por este
  Widget _buildTimePickerPage({
    required double screenWidth,
    required double screenHeight,
  }) {
    // Função auxiliar para formatar a data de forma amigável
    String _formatFirstDoseDate() {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDay = DateTime(_selectedFirstDoseDate.year,
          _selectedFirstDoseDate.month, _selectedFirstDoseDate.day);

      if (selectedDay == today) {
        return 'Hoje, ${DateFormat('d \'de\' MMMM', 'pt_BR').format(_selectedFirstDoseDate)}';
      } else {
        return DateFormat('E, d \'de\' MMMM', 'pt_BR')
            .format(_selectedFirstDoseDate);
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Qual a data e horário da primeira dose?',
                style: TextStyle(
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Data da primeira dose',
                style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                // Mostra o pop-up do calendário e espera o usuário escolher uma data
                final pickedDate = await showDatePicker(
                  context: context,
                  locale: const Locale('pt', 'BR'), // Garante o idioma
                  initialDate: _selectedFirstDoseDate,
                  firstDate: DateTime
                      .now(), // Não permite escolher uma data no passado
                  lastDate: DateTime(2101),
                );

                // Se o usuário escolheu uma data, atualiza o estado
                if (pickedDate != null) {
                  setState(() {
                    _selectedFirstDoseDate = pickedDate;
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      _formatFirstDoseDate(),
                      // --- CORREÇÃO AQUI ---
                      // Removemos a cor fixa para que o texto se adapte ao tema
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.calendar_today_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Checkbox que já existia
            CheckboxListTile(
              title: const Text('Uma dose apenas'),
              value: _isSingleDose,
              onChanged: (value) {
                setState(() {
                  _isSingleDose = value!;
                  _validatePage();
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 24),
            Text('Horário da primeira dose',
                style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                // Abre o pop-up de relógio nativo
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime:
                      TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
                  helpText: 'SELECIONE O HORÁRIO',
                );

                // Se o usuário escolher um horário, atualiza o estado
                if (pickedTime != null) {
                  setState(() {
                    _selectedHour = pickedTime.hour;
                    _selectedMinute = pickedTime.minute;
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      // Formata o horário para exibir com 2 dígitos (ex: 08:05)
                      '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.access_time_outlined),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalPickerPage({
    required double screenWidth,
    required double screenHeight,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Qual o intervalo entre as doses?',
                style: TextStyle(
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: screenWidth * 0.06),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- NOVO SELETOR DE HORAS ---
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedIntervalHour,
                    decoration: const InputDecoration(
                      labelText: 'Horas',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(25, (index) {
                      return DropdownMenuItem(
                        value: index,
                        child: Text('${index.toString().padLeft(2, '0')} h'),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        if (newValue != null) {
                          _selectedIntervalHour = newValue;
                          // Regra de negócio: se escolher 24h, os minutos zeram.
                          if (newValue == 24) {
                            _selectedIntervalMinute = 0;
                          }
                          // Regra: se for 0h, o mínimo de minutos é 30.
                          if (newValue == 0 && _selectedIntervalMinute < 30) {
                            _selectedIntervalMinute = 30;
                          }
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // --- NOVO SELETOR DE MINUTOS ---
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedIntervalMinute,
                    decoration: const InputDecoration(
                      labelText: 'Minutos',
                      border: OutlineInputBorder(),
                    ),
                    // Se a hora for 24, desativa os minutos.
                    // Se for 0, limita as opções a partir de 30.
                    items: List.generate(60, (index) {
                      bool isItemDisabled =
                          (_selectedIntervalHour == 24 && index > 0) ||
                              (_selectedIntervalHour == 0 && index < 30);
                      return DropdownMenuItem(
                        value: index,
                        // Itens desativados ficam com cor diferente
                        enabled: !isItemDisabled,
                        child: Text(
                          '${index.toString().padLeft(2, '0')} min',
                          style: TextStyle(
                              color: isItemDisabled ? Colors.grey : null),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedIntervalMinute = newValue ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationPage({
    required double screenWidth,
  }) {
    final units = ['Dias', 'Semanas', 'Meses', 'Anos'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Qual a duração do tratamento?',
                style: TextStyle(
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold)),
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
              activeColor: Theme.of(context).colorScheme.primary,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // A lista de páginas permanece a mesma
    final List<Widget> formPages = [
      Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Qual o nome do medicamento?',
                  style: TextStyle(
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: screenWidth * 0.04),
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: screenWidth * 0.06),
              _buildImagePicker(),
            ],
          ))),
      _buildTypeSelectionPage(screenWidth: screenWidth),
      _buildDosePage(screenWidth: screenWidth, screenHeight: screenHeight),
      _buildStockPage(screenWidth: screenWidth),
      _buildTimePickerPage(
          screenWidth: screenWidth, screenHeight: screenHeight),
      if (!_isSingleDose) ...[
        _buildIntervalPickerPage(
            screenWidth: screenWidth, screenHeight: screenHeight),
        _buildDurationPage(screenWidth: screenWidth),
      ],
      _buildFormPage(
          title: 'Alguma observação?',
          subtitle: 'Este campo é opcional',
          controller: _notesController,
          keyboardType: TextInputType.multiline,
          screenWidth: screenWidth,
          isLastPage: true),
    ];

    // --- ESTRUTURA PRINCIPAL ALTERADA ---
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      // O Padding agora envolve um Column, não um SingleChildScrollView
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                activeColor: Theme.of(context).colorScheme.secondary,
                completedColor: Theme.of(context).colorScheme.primary),

            // NOVO: Expanded faz o PageView ocupar o espaço restante
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: formPages,
              ),
            ),

            // Botões de navegação no final
            if (_currentPage == formPages.length - 1)
              Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenWidth * 0.02),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(screenHeight * 0.06)),
                    // O restante do estilo (cores) virá do tema global.
                    onPressed: _onSave,
                    child: const Text('Salvar Medicamento'),
                  ))
            else // Mostra os botões Anterior/Próximo
              Padding(
                padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.04, // Espaço da Esquerda
                  screenWidth * 0.04, // Espaço de Cima
                  screenWidth * 0.04, // Espaço da Direita
                  screenWidth * 0.04 +
                      12, // Espaço de Baixo (original + 12 pixels extras)
                ),
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
    );
  }

  // Adicione este método dentro da classe _AddMedicationScreenState
  // Substitua o método inteiro por este
  Widget _buildImagePicker() {
    return Center(
      child: Column(
        children: [
          if (_imagePath == null)
            // Se não houver imagem, mostra um placeholder adaptado ao tema
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                // NOVO: Usa a cor do card do tema (branco no claro, cinza escuro no escuro)
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: Icon(
                Icons.image_outlined,
                size: 50,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(_imagePath!),
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Tirar Foto'),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _pickAndSaveImage(ImageSource.camera);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Escolher da Galeria'),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _pickAndSaveImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
              );
            },
            child: Text(_imagePath == null ? 'Adicionar Foto' : 'Alterar Foto'),
          ),
        ],
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
