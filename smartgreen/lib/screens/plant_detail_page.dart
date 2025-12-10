import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/plant.dart';
import '../services/plant_service.dart';
import '../services/user_photo_service.dart';
import 'plant_form_page.dart';

// ...existing code...

class PlantDetailPage
    extends
        StatefulWidget {
  final String plantId;

  const PlantDetailPage({
    super.key,
    required this.plantId,
  });

  @override
  State<
    PlantDetailPage
  >
  createState() =>
      _PlantDetailPageState();
}

class _PlantDetailPageState
    extends
        State<
          PlantDetailPage
        > {
  @override
  void initState() {
    super.initState();
    _loadAndFetchPlant();
  }

  Future<
    void
  >
  _loadAndFetchPlant() async {
    await _loadPlant();
    await _fetchSensorData();
  }

  Future<
    void
  >
  _loadPlant() async {
    try {
      final plant = await _service.fetchPlantById(
        widget.plantId,
      );
      if (!mounted) return;
      final localPath = await _photoService.getPhotoPath(
        widget.plantId,
      );
      if (!mounted) return;
      setState(
        () {
          _plant =
              plant;
          _localPhotoPath =
              localPath;
        },
      );
    } catch (
      e
    ) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Falha ao carregar planta: $e',
          ),
        ),
      );
      Navigator.of(
        context,
      ).pop();
    }
  }

  final PlantService _service =
      PlantService();
  Plant? _plant;
  String? _localPhotoPath;
  final _photoService =
      UserPhotoService();

  double? _sensorTemp;
  double? _sensorHumidity;
  String? _sensorLight;
  String _sensorStatus =
      'Atualizando...';

  void showSnack(
    String msg,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          msg,
        ),
      ),
    );
  }

  Future<
    void
  >
  _onTakePhoto() async {
    try {
      final ImagePicker picker =
          ImagePicker();
      final XFile? image = await picker.pickImage(
        source:
            ImageSource.camera,
        maxWidth:
            2048,
        imageQuality:
            85,
      );
      if (image ==
          null)
        return;
      final savedPath = await _photoService.savePhotoForPlant(
        widget.plantId,
        File(
          image.path,
        ),
      );
      if (!mounted) return;
      setState(
        () =>
            _localPhotoPath =
                savedPath,
      );
      if (!mounted) return;
      showSnack(
        'Foto salva para esta planta.',
      );
    } catch (
      e
    ) {
      if (!mounted) return;
      showSnack(
        'Falha ao salvar foto: $e',
      );
    }
  }

  Future<
    void
  >
  _fetchSensorData() async {
    try {
      final vasoId =
          _plant?.vasoId;
      if (vasoId ==
              null ||
          vasoId.isEmpty) {
        setState(
          () {
            _sensorTemp =
                null;
            _sensorHumidity =
                null;
            _sensorLight =
                null;
            _sensorStatus =
                'ID do vaso não informado';
          },
        );
        return;
      }

      final lastResp = await http.get(
        Uri.parse(
          'http://56.125.164.45:5000/api/last/$vasoId',
        ),
      );
      if (lastResp.statusCode ==
          200) {
        final lastJson = json.decode(
          lastResp.body,
        );
        String? lightRaw =
            lastJson['light_level']?.toString();
        String? lightText;
        if (lightRaw ==
            'A') {
          lightText =
              'Alto';
        } else if (lightRaw ==
            'B') {
          lightText =
              'Baixo';
        } else if (lightRaw ==
            'M') {
          lightText =
              'Médio';
        } else {
          lightText =
              lightRaw ??
              '--';
        }
        setState(
          () {
            _sensorTemp =
                (lastJson['temperature_c']
                        as num?)
                    ?.toDouble();
            _sensorHumidity =
                (lastJson['soil_humidity']
                        as num?)
                    ?.toDouble();
            _sensorLight =
                lightText;
          },
        );
      } else {
        setState(
          () {
            _sensorTemp =
                null;
            _sensorHumidity =
                null;
            _sensorLight =
                null;
          },
        );
      }

      final statusResp = await http.get(
        Uri.parse(
          'http://56.125.164.45:5000/',
        ),
      );
      if (statusResp.statusCode ==
          200) {
        final statusJson = json.decode(
          statusResp.body,
        );
        setState(
          () {
            _sensorStatus =
                statusJson['status']?.toString() ??
                '--';
          },
        );
      } else {
        setState(
          () {
            _sensorStatus =
                '--';
          },
        );
      }
    } catch (
      e
    ) {
      debugPrint(
        "Erro ao buscar dados dos sensores: $e",
      );
      setState(
        () {
          _sensorTemp =
              null;
          _sensorHumidity =
              null;
          _sensorLight =
              null;
          _sensorStatus =
              'Erro ao buscar dados';
        },
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final ColorScheme colorScheme =
        Theme.of(
          context,
        ).colorScheme;
    final TextTheme textTheme =
        Theme.of(
          context,
        ).textTheme;

    final plant =
        _plant;
    if (plant ==
        null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Detalhes da Planta',
          ),
        ),
        body: const Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          plant.name,
        ),
        actions: [
          IconButton(
            tooltip:
                'Tirar foto',
            icon: const Icon(
              Icons.camera_alt,
            ),
            onPressed:
                _onTakePhoto,
          ),
          IconButton(
            tooltip:
                'Editar planta',
            icon: const Icon(
              Icons.edit,
            ),
            onPressed: () async {
              await Navigator.of(
                context,
              ).push(
                MaterialPageRoute(
                  builder:
                      (
                        _,
                      ) => PlantFormPage(
                        existingPlant:
                            plant,
                      ),
                ),
              );
              if (mounted) _loadAndFetchPlant();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            16.0,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Hero(
                tag:
                    'plantImage-${plant.id}',
                child:
                    _buildTopImage(),
              ),
              const SizedBox(
                height:
                    20,
              ),

              Text(
                plant.name,
                style: textTheme.headlineMedium!.copyWith(
                  color:
                      colorScheme.primary,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(
                height:
                    8,
              ),
              Text(
                'Plantada em: ${plant.dataPlantio != null ? DateFormat('dd/MM/yyyy').format(plant.dataPlantio!.toLocal()) : '---'}',
                style:
                    textTheme.bodyMedium,
              ),
              Text(
                'Exposição solar: ${plant.exposicaoSolar ?? '---'}',
                style:
                    textTheme.bodyMedium,
              ),
              const SizedBox(
                height:
                    24,
              ),

              _buildInfoSection(
                colorScheme,
                textTheme,
              ),
              const SizedBox(
                height:
                    24,
              ),

              _buildSectionTitle(
                context,
                'Histórico de Dados',
              ),
              const SizedBox(
                height:
                    12,
              ),
              _buildChartPlaceholder(
                colorScheme,
              ),
              const SizedBox(
                height:
                    24,
              ),

              _buildSectionTitle(
                context,
                'Cuidados Recomendados',
              ),
              const SizedBox(
                height:
                    12,
              ),
              _buildRecommendedCare(
                colorScheme,
                textTheme,
              ),
              const SizedBox(
                height:
                    24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
  ) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge!.copyWith(
        color:
            Theme.of(
              context,
            ).colorScheme.primary,
        fontWeight:
            FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoSection(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          'Informações Atuais',
        ),
        const SizedBox(
          height:
              12,
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(
              16.0,
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  icon:
                      Icons.thermostat,
                  label:
                      'Temperatura',
                  value:
                      _sensorTemp !=
                              null
                          ? '${_sensorTemp!.toStringAsFixed(1)} °C'
                          : 'Carregando...',
                  color:
                      Colors.redAccent,
                ),
                _buildInfoRow(
                  icon:
                      Icons.opacity,
                  label:
                      'Umidade',
                  value:
                      _sensorHumidity !=
                              null
                          ? '${_sensorHumidity!.toStringAsFixed(1)} %'
                          : 'Carregando...',
                  color:
                      Colors.blueAccent,
                ),
                _buildInfoRow(
                  icon:
                      Icons.wb_sunny,
                  label:
                      'Luminosidade',
                  value:
                      _sensorLight !=
                              null
                          ? '${_sensorLight!}'
                          : 'Carregando...',
                  color:
                      Colors.amber,
                ),
                _buildInfoRow(
                  icon:
                      Icons.favorite,
                  label:
                      'Status da Planta',
                  value:
                      _sensorStatus,
                  color:
                      colorScheme.secondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical:
            8.0,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                color,
          ),
          const SizedBox(
            width:
                12,
          ),
          Expanded(
            child: Text(
              label,
              style:
                  Theme.of(
                    context,
                  ).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(
              fontWeight:
                  FontWeight.bold,
              color:
                  value ==
                          'Carregando...'
                      ? Colors.grey
                      : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder(
    ColorScheme colorScheme,
  ) {
    return Container(
      height:
          200,
      decoration: BoxDecoration(
        color:
            colorScheme.surface,
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: colorScheme.outline.withOpacity(
            0.3,
          ),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(
            24.0,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                Icons.hourglass_empty,
                size:
                    50,
                color: colorScheme.onSurface.withOpacity(
                  0.4,
                ),
              ),
              const SizedBox(
                height:
                    12,
              ),
              Text(
                'Coletando dados...',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(
                  color: colorScheme.onSurface.withOpacity(
                    0.7,
                  ),
                  fontWeight:
                      FontWeight.bold,
                ),
                textAlign:
                    TextAlign.center,
              ),
              const SizedBox(
                height:
                    4,
              ),
              Text(
                'É necessário coletar dados por pelo menos 7 dias para gerar o histórico visual.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(
                  color: colorScheme.onSurface.withOpacity(
                    0.6,
                  ),
                ),
                textAlign:
                    TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedCare(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          16.0,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _buildCareItem(
              icon:
                  Icons.water_drop,
              text:
                  'Regar a cada 2 dias ou quando o solo estiver seco.',
              color:
                  Colors.lightBlue,
            ),
            _buildCareItem(
              icon:
                  Icons.wb_sunny_outlined,
              text:
                  'Garantir 6-8 horas de luz solar direta por dia.',
              color:
                  Colors.orange,
            ),
            _buildCareItem(
              icon:
                  Icons.local_florist,
              text:
                  'Fertilizar mensalmente na primavera e verão.',
              color:
                  Colors.brown,
            ),
            _buildCareItem(
              icon:
                  Icons.cut,
              text:
                  'Podar folhas secas para estimular o crescimento.',
              color:
                  Colors.green.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical:
            8.0,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color:
                color,
            size:
                20,
          ),
          const SizedBox(
            width:
                12,
          ),
          Expanded(
            child: Text(
              text,
              style:
                  Theme.of(
                    context,
                  ).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopImage() {
    final url =
        _plant?.imageURL;
    const double height =
        220;
    final Widget imageWidget;

    if (_localPhotoPath !=
            null &&
        _localPhotoPath!.isNotEmpty &&
        File(
          _localPhotoPath!,
        ).existsSync()) {
      imageWidget = Image.file(
        File(
          _localPhotoPath!,
        ),
        height:
            height,
        width:
            double.infinity,
        fit:
            BoxFit.cover,
        alignment:
            Alignment.center,
        errorBuilder:
            (
              _,
              __,
              ___,
            ) => _imagePlaceholder(
              height:
                  height,
            ),
      );
    } else if (url !=
            null &&
        url.isNotEmpty) {
      imageWidget = Image.network(
        url,
        height:
            height,
        width:
            double.infinity,
        fit:
            BoxFit.cover,
        alignment:
            Alignment.center,
        errorBuilder:
            (
              _,
              __,
              ___,
            ) => _imagePlaceholder(
              height:
                  height,
            ),
      );
    } else {
      imageWidget = _imagePlaceholder(
        height:
            height,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        16,
      ),
      child:
          imageWidget,
    );
  }

  Widget _imagePlaceholder({
    double height =
        220,
    bool isLoading =
        false,
  }) {
    return Container(
      height:
          height,
      width:
          double.infinity,
      decoration: BoxDecoration(
        color:
            Colors.grey.shade100,
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      alignment:
          Alignment.center,
      child:
          isLoading
              ? const SizedBox(
                height:
                    22,
                width:
                    22,
                child: CircularProgressIndicator(
                  strokeWidth:
                      2,
                ),
              )
              : Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons.eco,
                    size:
                        70,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(
                      0.5,
                    ),
                  ),
                  const SizedBox(
                    height:
                        12,
                  ),
                  Text(
                    'Imagem indisponível',
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall!.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(
                        0.6,
                      ),
                    ),
                    textAlign:
                        TextAlign.center,
                  ),
                ],
              ),
    );
  }
}

extension
    on
        BuildContext {
  void showSnack(
    String msg,
  ) {
    ScaffoldMessenger.of(
      this,
    ).showSnackBar(
      SnackBar(
        content: Text(
          msg,
        ),
      ),
    );
  }
}
