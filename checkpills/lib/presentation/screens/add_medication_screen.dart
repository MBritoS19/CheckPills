import 'package:CheckPills/presentation/providers/medication_provider.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
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
  int _intervalValue = 8;
  String _selectedIntervalUnit = 'Horas';
  String? _selectedType;
  String? _imagePath;
  bool _isContinuous = false;
  String _selectedTreatmentUnit = 'Dias';
  String _selectedDoseUnit = 'unidade(s)';
  bool _dontTrackStock = false;
  bool _isSingleDose = false;

  final _customTypeController = TextEditingController();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _notesController = TextEditingController();
  final _treatmentLengthController = TextEditingController();
  final _doseQuantityController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _doseQuantityFocusNode = FocusNode();
  final _stockFocusNode = FocusNode();
  final _treatmentLengthFocusNode = FocusNode();
  final _customTypeFocusNode = FocusNode();
  final _notesFocusNode = FocusNode();

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

  static const List<String> _medicationTypes = [
    'Comprimido',
    'Injeção',
    'Gotas',
    'Líquido',
    'Inalação',
    'Pó',
    'Outros'
  ];

  @override
  void initState() {
    super.initState();

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

  // ADICIONE ESTES DOIS MÉTODOS

  void _showImageSourceSheet() {
    HapticFeedback.lightImpact();
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
  }

  void _removeImage() {
    HapticFeedback.lightImpact();
    setState(() {
      _imagePath = null;
    });
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
    if (_medicationTypes.contains(p.type)) {
      _selectedType = p.type;
    } else {
      // Se não for, é um tipo customizado
      _selectedType = 'Outros';
      _customTypeController.text = p.type;
    }
    if (p.intervalValue == 0) {
      _isSingleDose = true;
    }
    if (p.stock == -1) {
      _dontTrackStock = true;
    } else {
      _dontTrackStock = false;
      _stockController.text = p.stock.toString();
    }
    _selectedFirstDoseDate = p.firstDoseTime;
    _selectedHour = p.firstDoseTime.hour;
    _selectedMinute = p.firstDoseTime.minute;
    _intervalValue = p.intervalValue;
    _selectedIntervalUnit = p.intervalUnit;
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

    _pageController.dispose();
    _customTypeController.dispose();
    _nameController.dispose();
    _stockController.dispose();
    _treatmentLengthController.dispose();
    _notesController.dispose();
    _doseQuantityController.dispose();
    _nameFocusNode.dispose();
    _doseQuantityFocusNode.dispose();
    _stockFocusNode.dispose();
    _treatmentLengthFocusNode.dispose();
    _customTypeFocusNode.dispose();
    _notesFocusNode.dispose();
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
        final quantity = int.tryParse(_doseQuantityController.text);
        isValid = quantity != null && quantity > 0;
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

  // MÉTODO _handleFocusRequest ATUALIZADO
  void _handleFocusRequest(int pageIndex) {
    Future.delayed(const Duration(milliseconds: 400), () {
      // Recria a lista de páginas para saber o total atual
      final formPages = _buildFormPages();

      // VERIFICAÇÃO ADICIONADA: Se o alvo for a última página, foca nas Observações
      if (pageIndex == formPages.length - 1) {
        _notesFocusNode.requestFocus();
        return; // Encerra a função aqui
      }

      // A lógica para as outras páginas continua a mesma
      switch (pageIndex) {
        case 1: // Indo para a página de Tipo
          if (_selectedType == 'Outros') _customTypeFocusNode.requestFocus();
          break;
        case 2: // Indo para a página de Dose
          _doseQuantityFocusNode.requestFocus();
          break;
        case 3: // Indo para a página de Estoque
          _stockFocusNode.requestFocus();
          break;
        case 6: // Se não for dose única, a página 6 é a Duração
          if (!_isSingleDose) _treatmentLengthFocusNode.requestFocus();
          break;
      }
    });
  }

  // NOVO MÉTODO COMPLETO
  List<Widget> _buildFormPages() {
    final screenWidth = MediaQuery.of(context).size.width;

    // A lista de páginas é exatamente a mesma que estava no seu método build
    return [
      // Página 0: Nome e Imagem
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
                focusNode: _nameFocusNode,
                keyboardType: TextInputType.text,
                maxLength: 50,
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  counterText: "",
                ),
              ),
              SizedBox(height: screenWidth * 0.06),
              _buildImagePicker(),
            ],
          ))),
      // Página 1: Tipo
      _buildTypeSelectionPage(screenWidth: screenWidth),
      // Página 2: Dose
      _buildDosePage(screenWidth: screenWidth),
      // Página 3: Estoque
      _buildStockPage(screenWidth: screenWidth),
      // Página 4: Data/Hora
      _buildTimePickerPage(screenWidth: screenWidth),
      // Páginas Condicionais
      if (!_isSingleDose) ...[
        // Página 5: Intervalo
        _buildIntervalPickerPage(screenWidth: screenWidth),
        // Página 6: Duração
        _buildDurationPage(screenWidth: screenWidth),
      ],
      // Última Página: Observações
      _buildFormPage(
          title: 'Alguma observação?',
          subtitle: 'Este campo é opcional',
          controller: _notesController,
          focusNode: _notesFocusNode,
          keyboardType: TextInputType.multiline,
          screenWidth: screenWidth,
          isLastPage: true,
          maxLength: 500,
          inputFormatters: [LengthLimitingTextInputFormatter(500)]),
    ];
  }

  // VERSÃO FINAL COM VALIDAÇÃO
  void _showIntervalPickerModal() {
    final formKey = GlobalKey<FormState>(); // Chave para controlar o formulário
    int tempValue = _intervalValue;
    String tempUnit = _selectedIntervalUnit;
    final List<String> unitsRow1 = ['Horas', 'Dias'];
    final List<String> unitsRow2 = ['Semanas', 'Meses'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 24,
              ),
              // Adicionamos um Form para gerenciar a validação
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Definir Intervalo",
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      initialValue: tempValue.toString(),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                      // 1. Apenas dígitos são permitidos
                      maxLength: 3,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: const InputDecoration(
                        labelText: "A cada",
                        border: OutlineInputBorder(),
                        counterText: "",
                      ),
                      // 2. Validação do valor
                      validator: (value) {
                        // O validator continua o mesmo e funciona em conjunto
                        if (value == null || value.isEmpty) {
                          return 'Obrigatório';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number <= 0) {
                          return 'Deve ser  0';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        // Salva o valor quando o formulário for válido
                        tempValue = int.parse(value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    Column(
                      // Centraliza o bloco de botões horizontalmente, caso o pai não seja full-width
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // PRIMEIRA LINHA DE BOTÕES
                        Row(
                          // Usa Row para garantir que o SegmentedButton ocupe o máximo de largura possível
                          children: [
                            Expanded(
                              // Força o SegmentedButton a preencher a largura total da Row
                              child: SegmentedButton<String>(
                                segments: unitsRow1
                                    .map((unit) => ButtonSegment<String>(
                                        value: unit, label: Text(unit)))
                                    .toList(),

                                // Estilo 1: Personalização do tema (opcional)
                                style: SegmentedButton.styleFrom(
                                  // Borda mais arredondada (se quiser)
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),

                                emptySelectionAllowed: true,
                                selected: unitsRow1.contains(tempUnit)
                                    ? {tempUnit}
                                    : {},
                                onSelectionChanged: (Set<String> newSelection) {
                                  HapticFeedback.lightImpact();
                                  modalSetState(() {
                                    tempUnit = newSelection.first;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // SEGUNDA LINHA DE BOTÕES
                        Row(
                          // Usa Row para garantir que o SegmentedButton ocupe o máximo de largura possível
                          children: [
                            Expanded(
                              // Força o SegmentedButton a preencher a largura total da Row
                              child: SegmentedButton<String>(
                                segments: unitsRow2
                                    .map((unit) => ButtonSegment<String>(
                                        value: unit, label: Text(unit)))
                                    .toList(),

                                // Estilo 1: Personalização do tema (opcional)
                                style: SegmentedButton.styleFrom(
                                  // Borda mais arredondada (se quiser)
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),

                                emptySelectionAllowed: true,
                                selected: unitsRow2.contains(tempUnit)
                                    ? {tempUnit}
                                    : {},
                                onSelectionChanged: (Set<String> newSelection) {
                                  HapticFeedback.lightImpact();
                                  modalSetState(() {
                                    tempUnit = newSelection.first;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50)),
                      onPressed: () {
                        // 3. Verifica se o formulário é válido antes de fechar
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save(); // Aciona o onSaved

                          setState(() {
                            _intervalValue = tempValue;
                            _selectedIntervalUnit = tempUnit;
                          });
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text("Confirmar"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

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

  // NOVO MÉTODO COM DESIGN UNIFICADO
  Widget _buildStockPage({
    required double screenWidth,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Quantas doses você tem em estoque?',
              style: TextStyle(
                  fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // PASSO 1.1: Container Principal com Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // PASSO 1.3: Organização Interna
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: TextFormField(
                    controller: _stockController,
                    focusNode: _stockFocusNode,
                    enabled: !_dontTrackStock,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Quantidade em estoque',
                      counterText: "",
                    ),
                  ),
                ),

                // PASSO 1.2: Modernização do Controle com SwitchListTile
                SwitchListTile(
                  title: const Text('Não controlar estoque'),
                  value: _dontTrackStock,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _dontTrackStock = value;
                      if (_dontTrackStock) {
                        _stockController.clear();
                        FocusScope.of(context).unfocus();
                      }
                      _validatePage();
                    });
                  },
                ),
              ],
            ),
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
      intervalValue: Value(_isSingleDose ? 0 : _intervalValue),
      intervalUnit: Value(_isSingleDose ? 'Dias' : _selectedIntervalUnit),
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
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    FocusNode? focusNode,
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
              maxLength: maxLength,
              inputFormatters: inputFormatters,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              focusNode: focusNode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelectionPage({
    required double screenWidth,
  }) {
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
              children: _medicationTypes.map((type) {
                return ChoiceChip(
                  label: Text(type,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  selected: _selectedType == type,
                  onSelected: (bool selected) {
                    HapticFeedback.lightImpact();
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
                focusNode: _customTypeFocusNode,
                maxLength: 30,
                inputFormatters: [LengthLimitingTextInputFormatter(30)],
                decoration: const InputDecoration(
                  labelText: 'Digite o tipo do medicamento',
                  border: OutlineInputBorder(),
                  counterText: "",
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
                    focusNode: _doseQuantityFocusNode,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      counterText: "", // Esconde o contador padrão
                    ),
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

  // NOVO MÉTODO COM LAYOUT APRIMORADO
  Widget _buildTimePickerPage({
    required double screenWidth,
  }) {
    // Função auxiliar para formatar a data de forma amigável
    String _formatFirstDoseDate() {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDay = DateTime(_selectedFirstDoseDate.year,
          _selectedFirstDoseDate.month, _selectedFirstDoseDate.day);

      if (selectedDay == today) {
        return 'Hoje';
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
            const SizedBox(height: 24),

            // PASSO 1: Agrupamento Visual com Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // PASSO 2 e 3: Layout em Linha e Área de Toque
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        locale: const Locale('pt', 'BR'),
                        initialDate: _selectedFirstDoseDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedFirstDoseDate = pickedDate;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Data",
                                  style: Theme.of(context).textTheme.bodySmall),
                              Text(_formatFirstDoseDate(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  InkWell(
                    onTap: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                            hour: _selectedHour, minute: _selectedMinute),
                        helpText: 'SELECIONE O HORÁRIO',
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _selectedHour = pickedTime.hour;
                          _selectedMinute = pickedTime.minute;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_outlined),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Horário",
                                  style: Theme.of(context).textTheme.bodySmall),
                              Text(
                                '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // PASSO 4: Posicionamento do Checkbox
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
          ],
        ),
      ),
    );
  }

  // NOVO MÉTODO COM DESIGN UNIFICADO
  Widget _buildIntervalPickerPage({
    required double screenWidth,
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
          const SizedBox(height: 24),

          // Aplicando o mesmo design de Card da tela de Data/Hora
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              // A linha inteira agora chama o modal que já tínhamos pronto
              onTap: _showIntervalPickerModal,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Intervalo",
                            style: Theme.of(context).textTheme.bodySmall),
                        Text(
                          'A cada $_intervalValue $_selectedIntervalUnit',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
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

  // NOVO MÉTODO COM DESIGN UNIFICADO E VALIDAÇÃO
  Widget _buildDurationPage({
    required double screenWidth,
  }) {
    final units = ['Dias', 'Semanas', 'Meses', 'Anos'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Qual a duração do tratamento?',
              style: TextStyle(
                  fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _treatmentLengthController,
                          focusNode: _treatmentLengthFocusNode,
                          enabled: !_isContinuous,
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Duração',
                            border: OutlineInputBorder(),
                            counterText: "",
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedTreatmentUnit,
                          onChanged: _isContinuous
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedTreatmentUnit = value!;
                                  });
                                },
                          items: units.map((unit) {
                            return DropdownMenuItem(
                                value: unit, child: Text(unit));
                          }).toList(),
                          decoration: const InputDecoration(
                              labelText: 'Unidade',
                              border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                ),

                // Substituindo o Checkbox pelo Switch para consistência
                SwitchListTile(
                  title: const Text('Uso constante'),
                  value: _isContinuous,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _isContinuous = value;
                      if (_isContinuous) {
                        _treatmentLengthController.clear();
                      }
                      _validatePage();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // A lista de páginas permanece a mesma
    final List<Widget> formPages = _buildFormPages();

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
              // NOVO CONTEÚDO PARA O 'IF'
              Padding(
                padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.04,
                  screenWidth * 0.04,
                  screenWidth * 0.04,
                  screenWidth * 0.04 + 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Botão Anterior
                    ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        FocusScope.of(context).unfocus();
                        _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn);
                      },
                      child: const Text('Anterior'),
                    ),
                    // Botão Salvar (com mais destaque)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondary,
                      ),
                      onPressed: _onSave,
                      child: const Text('Salvar Medicamento'),
                    ),
                  ],
                ),
              )
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

                              _handleFocusRequest(_currentPage + 1);

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

  Widget _buildImagePicker() {
    return AspectRatio(
      aspectRatio: 1.0, // Garante que o widget seja sempre um quadrado
      child: GestureDetector(
        // Se não houver imagem, o toque abre o seletor
        onTap: _imagePath == null ? _showImageSourceSheet : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _imagePath == null
                // Cenário A: Sem Imagem (Placeholder)
                ? Center(
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      size: 50,
                      color:
                          Theme.of(context).iconTheme.color?.withOpacity(0.6),
                    ),
                  )
                // Cenário B: Com Imagem (Stack com overlays)
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(_imagePath!),
                        fit: BoxFit.cover,
                      ),
                      // Gradiente para garantir a visibilidade dos ícones
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.center,
                          ),
                        ),
                      ),
                      // Botões de Ação Sobrepostos
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.white),
                                onPressed: _showImageSourceSheet,
                                tooltip: 'Alterar Imagem',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.white),
                                onPressed: _removeImage,
                                tooltip: 'Remover Imagem',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
