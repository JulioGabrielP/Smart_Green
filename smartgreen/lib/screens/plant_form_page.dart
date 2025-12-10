import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/plant.dart';
import '../services/plant_service.dart';
import '../services/store_product_service.dart';
import '../models/store_product.dart';
import 'dart:async';
import '../globals.dart';
import '../widgets/custom_button.dart';

class PlantFormPage
    extends
        StatefulWidget {
  final Plant? existingPlant;
  const PlantFormPage({
    super.key,
    this.existingPlant,
  });

  @override
  State<
    PlantFormPage
  >
  createState() =>
      _PlantFormPageState();
}

class _PlantFormPageState
    extends
        State<
          PlantFormPage
        > {
  final _formKey =
      GlobalKey<
        FormState
      >();
  final _service =
      PlantService();

  final _nameController =
      TextEditingController();
  final _idController =
      TextEditingController(); // Controlador do ID da planta
  final _vasoIdController =
      TextEditingController(); // Controlador do ID do vaso
  final _tempMinController =
      TextEditingController();
  final _tempMaxController =
      TextEditingController();
  final _umidMinController =
      TextEditingController();
  final _umidMaxController =
      TextEditingController();
  String? _tempMaxError;
  String? _umidMaxError;
  final FocusNode _nameFocus =
      FocusNode();
  final StoreProductService _storeService =
      StoreProductService();
  List<
    StoreProduct
  >
  _suggestions =
      <
        StoreProduct
      >[];
  bool _loadingSuggestions =
      false;
  bool _isSaving =
      false;
  Timer? _debounce;
  static const List<
    String
  >
  _lightOptions = <
    String
  >[
    'Sol Pleno',
    'Meia Sombra',
    'Sombra',
  ];
  String? _selectedLight;
  String? _normalizeLight(
    String? v,
  ) {
    if (v ==
        null)
      return null;
    final s = v.trim().toLowerCase();
    if (s ==
            'sol pleno' ||
        s ==
            'sol_pleno')
      return 'Sol Pleno';
    if (s ==
            'meia sombra' ||
        s ==
            'meia_sombra')
      return 'Meia Sombra';
    if (s ==
        'sombra')
      return 'Sombra';
    return _lightOptions.contains(
          v,
        )
        ? v
        : null;
  }

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(
      () {
        if (!_nameFocus.hasFocus) {
          setState(
            () =>
                _suggestions =
                    <
                      StoreProduct
                    >[],
          );
        }
      },
    );
    final p = widget.existingPlant;
    if (p !=
        null) {
      _nameController.text = p.name;
      _idController.text = p.id; // Preenche o ID da planta se for edição
      _vasoIdController.text =
          p.vasoId ??
          ''; // Preenche o ID do vaso se existir
      _tempMinController.text =
          p.temperaturaMin?.toString() ??
          '';
      _tempMaxController.text =
          p.temperaturaMax?.toString() ??
          '';
      _umidMinController.text =
          p.umidadeMin?.toString() ??
          '';
      _umidMaxController.text =
          p.umidadeMax?.toString() ??
          '';
      _selectedLight =
          _normalizeLight(
            p.exposicaoSolar,
          ) ??
          _lightOptions.first;
      _selectedDate =
          p.dataPlantio ??
          DateTime.now();
    } else {
      _selectedDate =
          DateTime.now();
      _selectedLight =
          _lightOptions.first;
    }
    // Validação cruzada inline
    void revalidateTemp() {
      final tmin = int.tryParse(
        _tempMinController.text.trim(),
      );
      final tmax = int.tryParse(
        _tempMaxController.text.trim(),
      );
      final err =
          (tmin !=
                      null &&
                  tmax !=
                      null &&
                  tmax <=
                      tmin)
              ? 'Temperatura Máx deve ser maior que a Mín'
              : null;
      if (_tempMaxError !=
          err) {
        setState(
          () =>
              _tempMaxError =
                  err,
        );
      }
    }

    void revalidateUmid() {
      final umin = int.tryParse(
        _umidMinController.text.trim(),
      );
      final umax = int.tryParse(
        _umidMaxController.text.trim(),
      );
      final err =
          (umin !=
                      null &&
                  umax !=
                      null &&
                  umax <=
                      umin)
              ? 'Umidade Máx deve ser maior que a Mín'
              : null;
      if (_umidMaxError !=
          err) {
        setState(
          () =>
              _umidMaxError =
                  err,
        );
      }
    }

    _tempMinController.addListener(
      revalidateTemp,
    );
    _tempMaxController.addListener(
      revalidateTemp,
    );
    _umidMinController.addListener(
      revalidateUmid,
    );
    _umidMaxController.addListener(
      revalidateUmid,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameFocus.dispose();
    _nameController.dispose();
    _idController.dispose(); // Descarte do controller do ID da planta
    _vasoIdController.dispose(); // Descarte do controller do ID do vaso
    _tempMinController.dispose();
    _tempMaxController.dispose();
    _umidMinController.dispose();
    _umidMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final isEditing =
        widget.existingPlant !=
        null;
    final cs =
        Theme.of(
          context,
        ).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Editar Planta'
              : 'Nova Planta',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            16,
          ),
          child: Form(
            key:
                _formKey,
            autovalidateMode:
                AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                // SEÇÃO 1: Identificação da Planta
                _buildSectionTitle(
                  cs,
                  Icons.eco,
                  'Identificação',
                ),
                const SizedBox(
                  height:
                      12,
                ),
                _buildIdentificationCard(
                  cs,
                ),
                const SizedBox(
                  height:
                      24,
                ),

                // SEÇÃO 2: Condições Ideais
                _buildSectionTitle(
                  cs,
                  Icons.tune,
                  'Condições Ideais',
                ),
                const SizedBox(
                  height:
                      12,
                ),
                _buildConditionsCard(
                  cs,
                ),
                const SizedBox(
                  height:
                      24,
                ),

                // SEÇÃO 3: Data de Plantio
                _buildSectionTitle(
                  cs,
                  Icons.calendar_today,
                  'Data de Plantio',
                ),
                const SizedBox(
                  height:
                      12,
                ),
                _buildDateCard(
                  cs,
                ),
                const SizedBox(
                  height:
                      32,
                ),

                // Botão de Salvar
                CustomButton(
                  label:
                      _isSaving
                          ? 'Salvando...'
                          : 'Salvar Planta',
                  icon:
                      _isSaving
                          ? null
                          : Icons.save,
                  onPressed:
                      _isSaving
                          ? null
                          : _handleSave,
                  backgroundColor:
                      cs.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // SEÇÃO 1: Card de Identificação
  Widget _buildIdentificationCard(
    ColorScheme cs,
  ) {
    return Card(
      elevation:
          0,
      color:
          cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
        side: BorderSide(
          color: cs.outline.withValues(
            alpha:
                0.2,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Column(
          children: [
            // Campo Nome
            TextFormField(
              controller:
                  _nameController,
              focusNode:
                  _nameFocus,
              decoration: InputDecoration(
                labelText:
                    'Nome da Planta',
                hintText:
                    'Ex: Tomate Cereja',
                prefixIcon: Icon(
                  Icons.local_florist,
                  color:
                      cs.primary,
                ),
                helperText:
                    'Digite pelo menos 3 letras para sugestões',
                helperMaxLines:
                    2,
              ),
              onChanged: (
                value,
              ) {
                _debounce?.cancel();
                if (value.trim().length <
                    3) {
                  setState(
                    () =>
                        _suggestions =
                            <
                              StoreProduct
                            >[],
                  );
                  return;
                }
                _debounce = Timer(
                  const Duration(
                    milliseconds:
                        300,
                  ),
                  () async {
                    setState(
                      () =>
                          _loadingSuggestions =
                              true,
                    );
                    try {
                      final results = await _storeService.searchByCategoryAndQuery(
                        category:
                            'Planta/Semente',
                        query:
                            value,
                        limit:
                            8,
                      );
                      if (mounted) {
                        setState(
                          () {
                            _suggestions =
                                results;
                          },
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(
                          () =>
                              _loadingSuggestions =
                                  false,
                        );
                      }
                    }
                  },
                );
              },
              validator: (
                value,
              ) {
                if (value ==
                        null ||
                    value.trim().isEmpty) {
                  return 'Informe o nome da planta';
                }
                final nameRegex = RegExp(
                  r'^[A-Za-zÀ-ÿ\s]+$',
                );
                if (!nameRegex.hasMatch(
                  value,
                )) {
                  return 'Use apenas letras e acentos';
                }
                return null;
              },
            ),

            const SizedBox(
              height:
                  12,
            ),

            // Campo ID da Planta
            TextFormField(
              controller:
                  _idController,
              decoration: InputDecoration(
                labelText:
                    'ID da Planta',
                hintText:
                    'Ex: SENSOR_01',
                prefixIcon: Icon(
                  Icons.qr_code,
                  color:
                      cs.primary,
                ),
                helperText:
                    'Identificador único da planta',
              ),
              validator: (
                value,
              ) {
                if (value ==
                        null ||
                    value.trim().isEmpty) {
                  return 'Informe o ID da planta';
                }
                return null;
              },
            ),

            const SizedBox(
              height:
                  12,
            ),

            // Campo ID do Vaso
            TextFormField(
              controller:
                  _vasoIdController,
              decoration: InputDecoration(
                labelText:
                    'ID do Vaso',
                hintText:
                    'Ex: VASO_01',
                prefixIcon: Icon(
                  Icons.account_tree,
                  color:
                      cs.primary,
                ),
                helperText:
                    'Identificador único do vaso para integração IoT',
              ),
              validator: (
                value,
              ) {
                if (value ==
                        null ||
                    value.trim().isEmpty) {
                  return 'Informe o ID do vaso';
                }
                return null;
              },
            ),

            const SizedBox(
              height:
                  12,
            ),

            // Loading Indicator
            if (_loadingSuggestions)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical:
                      8,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      height:
                          16,
                      width:
                          16,
                      child: CircularProgressIndicator(
                        strokeWidth:
                            2,
                        color:
                            cs.primary,
                      ),
                    ),
                    const SizedBox(
                      width:
                          12,
                    ),
                    Text(
                      'Buscando sugestões...',
                      style: TextStyle(
                        color: cs.onSurface.withValues(
                          alpha:
                              0.6,
                        ),
                        fontSize:
                            12,
                      ),
                    ),
                  ],
                ),
              ),

            // Sugestões de Produtos (Autocomplete)
            if (_suggestions.isNotEmpty)
              _buildSuggestionsCard(
                cs,
              ),
          ],
        ),
      ),
    );
  }

  // Card de Sugestões (Autocomplete)
  Widget _buildSuggestionsCard(
    ColorScheme cs,
  ) {
    return Card(
      elevation:
          2,
      margin: const EdgeInsets.only(
        top:
            8,
      ),
      color:
          cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              8,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size:
                      16,
                  color:
                      cs.primary,
                ),
                const SizedBox(
                  width:
                      8,
                ),
                Text(
                  'Sugestões',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                    fontSize:
                        12,
                    color: cs.onSurface.withValues(
                      alpha:
                          0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height:
                1,
          ),
          ListView.separated(
            shrinkWrap:
                true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount:
                _suggestions.length,
            separatorBuilder:
                (
                  _,
                  __,
                ) => Divider(
                  height:
                      1,
                  color: cs.outline.withValues(
                    alpha:
                        0.1,
                  ),
                ),
            itemBuilder: (
              context,
              index,
            ) {
              final s = _suggestions[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal:
                      16,
                  vertical:
                      4,
                ),
                leading:
                    s.imageURL.isNotEmpty
                        ? CircleAvatar(
                          backgroundColor:
                              cs.primaryContainer,
                          backgroundImage: NetworkImage(
                            s.imageURL,
                          ),
                        )
                        : CircleAvatar(
                          backgroundColor:
                              cs.primaryContainer,
                          child: Icon(
                            Icons.local_florist,
                            color:
                                cs.primary,
                          ),
                        ),
                title: Text(
                  s.nome,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w500,
                    fontSize:
                        14,
                  ),
                ),
                subtitle: Text(
                  s.cientificName,
                  style: TextStyle(
                    fontSize:
                        12,
                    color: cs.onSurface.withValues(
                      alpha:
                          0.6,
                    ),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size:
                      14,
                  color:
                      cs.primary,
                ),
                onTap: () {
                  // Preenche os campos
                  _nameController.text = s.nome;
                  if (s.temperaturaMin !=
                      null) {
                    _tempMinController.text = s.temperaturaMin!.round().toString();
                  }
                  if (s.temperaturaMax !=
                      null) {
                    _tempMaxController.text = s.temperaturaMax!.round().toString();
                  }
                  if (s.umidadeMinima !=
                      null) {
                    _umidMinController.text = s.umidadeMinima!.round().toString();
                  }
                  if (s.umidadeMax !=
                      null) {
                    _umidMaxController.text = s.umidadeMax!.round().toString();
                  }
                  _selectedLight =
                      _normalizeLight(
                        s.tempoSol,
                      ) ??
                      _selectedLight;
                  setState(
                    () {
                      _suggestions =
                          <
                            StoreProduct
                          >[];
                    },
                  );
                  FocusScope.of(
                    context,
                  ).unfocus();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // SEÇÃO 2: Card de Condições Ideais
  Widget _buildConditionsCard(
    ColorScheme cs,
  ) {
    return Card(
      elevation:
          0,
      color:
          cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
        side: BorderSide(
          color: cs.outline.withValues(
            alpha:
                0.2,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Temperatura
            Row(
              children: [
                Icon(
                  Icons.thermostat,
                  size:
                      18,
                  color:
                      cs.primary,
                ),
                const SizedBox(
                  width:
                      8,
                ),
                Text(
                  'Temperatura (°C)',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                    fontSize:
                        13,
                    color: cs.onSurface.withValues(
                      alpha:
                          0.7,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height:
                  12,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller:
                        _tempMinController,
                    decoration: InputDecoration(
                      labelText:
                          'Mínima',
                      hintText:
                          '15',
                      prefixIcon: Icon(
                        Icons.arrow_downward,
                        size:
                            18,
                        color:
                            cs.primary,
                      ),
                      helperText:
                          'Entre -50 e 70 °C',
                    ),
                    keyboardType:
                        TextInputType.number,
                    validator: (
                      value,
                    ) {
                      final v = int.tryParse(
                        value ??
                            '',
                      );
                      if (v ==
                          null) {
                        return 'Número inválido';
                      }
                      if (v <
                              -50 ||
                          v >
                              70) {
                        return 'Mín: -50 a 70 °C';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  width:
                      12,
                ),
                Expanded(
                  child: TextFormField(
                    controller:
                        _tempMaxController,
                    decoration: InputDecoration(
                      labelText:
                          'Máxima',
                      hintText:
                          '30',
                      prefixIcon: Icon(
                        Icons.arrow_upward,
                        size:
                            18,
                        color:
                            cs.primary,
                      ),
                      helperText:
                          'Entre -50 e 70 °C',
                    ),
                    keyboardType:
                        TextInputType.number,
                    validator: (
                      value,
                    ) {
                      final v = int.tryParse(
                        value ??
                            '',
                      );
                      if (v ==
                          null) {
                        return 'Número inválido';
                      }
                      if (v <
                              -50 ||
                          v >
                              70) {
                        return 'Máx: -50 a 70 °C';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            if (_tempMaxError !=
                null)
              Padding(
                padding: const EdgeInsets.only(
                  top:
                      8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size:
                          16,
                      color:
                          cs.error,
                    ),
                    const SizedBox(
                      width:
                          8,
                    ),
                    Expanded(
                      child: Text(
                        _tempMaxError!,
                        style: TextStyle(
                          color:
                              cs.error,
                          fontSize:
                              12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(
              height:
                  24,
            ),

            // Umidade
            Row(
              children: [
                Icon(
                  Icons.opacity,
                  size:
                      18,
                  color:
                      cs.primary,
                ),
                const SizedBox(
                  width:
                      8,
                ),
                Text(
                  'Umidade (%)',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                    fontSize:
                        13,
                    color: cs.onSurface.withValues(
                      alpha:
                          0.7,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height:
                  12,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller:
                        _umidMinController,
                    decoration: InputDecoration(
                      labelText:
                          'Mínima',
                      hintText:
                          '40',
                      prefixIcon: Icon(
                        Icons.arrow_downward,
                        size:
                            18,
                        color:
                            cs.primary,
                      ),
                      helperText:
                          'Entre 0 e 100%',
                    ),
                    keyboardType:
                        TextInputType.number,
                    validator: (
                      value,
                    ) {
                      final v = int.tryParse(
                        value ??
                            '',
                      );
                      if (v ==
                          null) {
                        return 'Número inválido';
                      }
                      if (v <
                              0 ||
                          v >
                              100) {
                        return 'Mín: 0 a 100%';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  width:
                      12,
                ),
                Expanded(
                  child: TextFormField(
                    controller:
                        _umidMaxController,
                    decoration: InputDecoration(
                      labelText:
                          'Máxima',
                      hintText:
                          '80',
                      prefixIcon: Icon(
                        Icons.arrow_upward,
                        size:
                            18,
                        color:
                            cs.primary,
                      ),
                      helperText:
                          'Entre 0 e 100%',
                    ),
                    keyboardType:
                        TextInputType.number,
                    validator: (
                      value,
                    ) {
                      final v = int.tryParse(
                        value ??
                            '',
                      );
                      if (v ==
                          null) {
                        return 'Número inválido';
                      }
                      if (v <
                              0 ||
                          v >
                              100) {
                        return 'Máx: 0 a 100%';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            if (_umidMaxError !=
                null)
              Padding(
                padding: const EdgeInsets.only(
                  top:
                      8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size:
                          16,
                      color:
                          cs.error,
                    ),
                    const SizedBox(
                      width:
                          8,
                    ),
                    Expanded(
                      child: Text(
                        _umidMaxError!,
                        style: TextStyle(
                          color:
                              cs.error,
                          fontSize:
                              12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(
              height:
                  24,
            ),

            // Exposição Solar
            Row(
              children: [
                Icon(
                  Icons.wb_sunny,
                  size:
                      18,
                  color:
                      cs.primary,
                ),
                const SizedBox(
                  width:
                      8,
                ),
                Text(
                  'Exposição Solar',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                    fontSize:
                        13,
                    color: cs.onSurface.withValues(
                      alpha:
                          0.7,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height:
                  12,
            ),
            DropdownButtonFormField<
              String
            >(
              initialValue:
                  _selectedLight,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.light_mode,
                  color:
                      cs.primary,
                ),
                helperText:
                    'Quantidade de luz solar necessária',
              ),
              items:
                  _lightOptions
                      .map(
                        (
                          e,
                        ) => DropdownMenuItem(
                          value:
                              e,
                          child: Text(
                            e,
                          ),
                        ),
                      )
                      .toList(),
              onChanged:
                  (
                    v,
                  ) => setState(
                    () =>
                        _selectedLight =
                            v,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // SEÇÃO 3: Card de Data de Plantio
  Widget _buildDateCard(
    ColorScheme cs,
  ) {
    return Card(
      elevation:
          0,
      color:
          cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12,
        ),
        side: BorderSide(
          color: cs.outline.withValues(
            alpha:
                0.2,
          ),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          12,
        ),
        onTap: () async {
          final date = await showDatePicker(
            context:
                context,
            initialDate:
                _selectedDate ??
                DateTime.now(),
            firstDate: DateTime(
              2000,
            ),
            lastDate: DateTime(
              2100,
            ),
          );
          if (date !=
              null) {
            setState(
              () =>
                  _selectedDate =
                      date,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(
            16,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(
                  12,
                ),
                decoration: BoxDecoration(
                  color:
                      cs.primaryContainer,
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
                child: Icon(
                  Icons.event,
                  color:
                      cs.primary,
                  size:
                      24,
                ),
              ),
              const SizedBox(
                width:
                    16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data de Plantio',
                      style: TextStyle(
                        fontSize:
                            12,
                        color: cs.onSurface.withValues(
                          alpha:
                              0.6,
                        ),
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height:
                          4,
                    ),
                    Text(
                      DateFormat(
                        'dd/MM/yyyy',
                      ).format(
                        _selectedDate ??
                            DateTime.now(),
                      ),
                      style: TextStyle(
                        fontSize:
                            18,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size:
                    16,
                color: cs.onSurface.withValues(
                  alpha:
                      0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: Título de Seção
  Widget _buildSectionTitle(
    ColorScheme cs,
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size:
              20,
          color:
              cs.primary,
        ),
        const SizedBox(
          width:
              8,
        ),
        Text(
          title,
          style: TextStyle(
            fontSize:
                16,
            fontWeight:
                FontWeight.bold,
            color:
                cs.onSurface,
          ),
        ),
      ],
    );
  }

  // Lógica de Salvamento (mantida intacta)
  Future<
    void
  >
  _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final user =
        currentUser;
    if (user ==
            null ||
        (user.id ==
                null ||
            user.id!.isEmpty)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Faça login para salvar a planta.',
          ),
        ),
      );
      return;
    }

    // Validação cruzada
    final tmin = int.tryParse(
      _tempMinController.text.trim(),
    );
    final tmax = int.tryParse(
      _tempMaxController.text.trim(),
    );
    if (tmin !=
            null &&
        tmax !=
            null &&
        tmax <=
            tmin) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Temperatura Máx deve ser maior que a Mín',
          ),
        ),
      );
      return;
    }
    final umin = int.tryParse(
      _umidMinController.text.trim(),
    );
    final umax = int.tryParse(
      _umidMaxController.text.trim(),
    );
    if (umin !=
            null &&
        umax !=
            null &&
        umax <=
            umin) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Umidade Máx deve ser maior que a Mín',
          ),
        ),
      );
      return;
    }

    setState(
      () =>
          _isSaving =
              true,
    );

    try {
      final plant = Plant(
        id:
            _idController.text.trim(), // ID da planta
        vasoId:
            _vasoIdController.text.trim(), // ID do vaso
        name:
            _nameController.text.trim(),
        temperaturaMin: int.tryParse(
          _tempMinController.text,
        ),
        temperaturaMax: int.tryParse(
          _tempMaxController.text,
        ),
        umidadeMin: int.tryParse(
          _umidMinController.text,
        ),
        umidadeMax: int.tryParse(
          _umidMaxController.text,
        ),
        exposicaoSolar:
            _selectedLight,
        dataPlantio:
            _selectedDate,
        status:
            'verde',
        userId:
            user.id,
      );

      if (widget.existingPlant !=
          null) {
        await _service.updatePlant(
          plant,
        );
      } else {
        await _service.createPlant(
          plant,
        );
      }

      if (context.mounted) {
        Navigator.of(
          context,
        ).pop();
      }
    } finally {
      if (mounted) {
        setState(
          () =>
              _isSaving =
                  false,
        );
      }
    }
  }
}
