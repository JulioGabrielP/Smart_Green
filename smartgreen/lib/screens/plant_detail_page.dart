import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // Corrigido aqui!

import '../models/plant.dart';
import '../services/plant_service.dart';
import '../services/user_photo_service.dart';
import 'plant_form_page.dart';
import 'control_page.dart';

class PlantDetailPage extends StatefulWidget {
  final String plantId;

  const PlantDetailPage({super.key, required this.plantId});

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  final PlantService _service = PlantService();
  Plant? _plant;
  String? _localPhotoPath;
  final _photoService = UserPhotoService();

  @override
  void initState() {
    super.initState();
    _loadPlant();
  }

  Future<void> _loadPlant() async {
    try {
      final plant = await _service.fetchPlantById(widget.plantId);
      if (!mounted) return;
      final localPath = await _photoService.getPhotoPath(widget.plantId);
      if (!mounted) return;
      setState(() {
        _plant = plant;
        _localPhotoPath = localPath;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao carregar planta: $e')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final plant = _plant;
    if (plant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes da Planta')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plant.name),
        actions: [
          IconButton(
            tooltip: 'Tirar foto',
            icon: const Icon(Icons.camera_alt),
            onPressed: _onTakePhoto,
          ),
          IconButton(
            tooltip: 'Editar planta',
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PlantFormPage(existingPlant: plant),
                ),
              );
              if (mounted) _loadPlant();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'plantImage-${plant.id}',
                child: _buildTopImage(),
              ),
              const SizedBox(height: 20),

              Text(
                plant.name,
                style: textTheme.headlineMedium!.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Plantada em: ${plant.dataPlantio != null ? DateFormat('dd/MM/yyyy').format(plant.dataPlantio!.toLocal()) : '---'}',
                style: textTheme.bodyMedium,
              ),
              Text(
                'Exposição solar: ${plant.exposicaoSolar ?? '---'}',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Seção de Informações (Temperatura, Umidade, Luz, Status)
              _buildInfoSection(colorScheme, textTheme, plant),
              const SizedBox(height: 24),

              // Gráficos de Histórico (Mock Visual / Placeholder)
              _buildSectionTitle(context, 'Histórico de Dados'),
              const SizedBox(height: 12),
              _buildChartPlaceholder(colorScheme),
              const SizedBox(height: 24),

              // Seção de Cuidados Recomendados
              _buildSectionTitle(context, 'Cuidados Recomendados'),
              const SizedBox(height: 12),
              _buildRecommendedCare(colorScheme, textTheme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ControlPage(),
            ),
          );
        },
        label: Text(
          'Controlar Vaso',
          style: textTheme.titleMedium!.copyWith(color: colorScheme.onPrimary),
        ),
        icon: const Icon(Icons.settings_remote),
        backgroundColor: colorScheme.tertiary,
        foregroundColor: colorScheme.onTertiary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildInfoSection(ColorScheme colorScheme, TextTheme textTheme, Plant plant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Informações Atuais'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.thermostat,
                  label: 'Temperatura',
                  value: '${plant.mediaTemperatura?.toStringAsFixed(1) ?? 'N/A'} °C',
                  color: Colors.redAccent,
                ),
                _buildInfoRow(
                  icon: Icons.opacity,
                  label: 'Umidade',
                  value: '${plant.mediaUmidade?.toStringAsFixed(1) ?? 'N/A'} %',
                  color: Colors.blueAccent,
                ),
                _buildInfoRow(
                  icon: Icons.wb_sunny,
                  label: 'Luminosidade',
                  value: '${plant.horasLuz?.toStringAsFixed(1) ?? 'N/A'} h',
                  color: Colors.amber,
                ),
                _buildInfoRow(
                  icon: Icons.favorite,
                  label: 'Status da Planta',
                  value: 'Saudável',
                  color: colorScheme.secondary,
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder(ColorScheme colorScheme) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 50, color: colorScheme.onSurface.withOpacity(0.4)),
            const SizedBox(height: 8),
            Text(
              'Gráficos de histórico aqui',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedCare(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCareItem(
              icon: Icons.water_drop,
              text: 'Regar a cada 2 dias ou quando o solo estiver seco.',
              color: Colors.lightBlue,
            ),
            _buildCareItem(
              icon: Icons.wb_sunny_outlined,
              text: 'Garantir 6-8 horas de luz solar direta por dia.',
              color: Colors.orange,
            ),
            _buildCareItem(
              icon: Icons.local_florist,
              text: 'Fertilizar mensalmente na primavera e verão.',
              color: Colors.brown,
            ),
            _buildCareItem(
              icon: Icons.cut,
              text: 'Podar folhas secas para estimular o crescimento.',
              color: Colors.green.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareItem({required IconData icon, required String text, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String title,
    required double value,
    required double min,
    required double max,
    required LinearGradient gradient,
    required String unit,
    required IconData icon,
    required Color iconColor,
  }) {
    final clamped = value.clamp(min, max);
    final t = (clamped - min) / (max - min == 0 ? 1 : (max - min));
    const trackHeight = 12.0;
    const markerSize = 24.0;
    const innerIconSize = 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ${clamped.toStringAsFixed(1)} $unit',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final left = (w - markerSize) * t;
            final top = (24 - markerSize) / 2;
            return SizedBox(
              height: 24,
              child: Stack(
                children: [
                  Positioned.fill(
                    top: (24 - trackHeight) / 2,
                    bottom: (24 - trackHeight) / 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    child: Builder(
                      builder: (context) {
                        final cs = Theme.of(context).colorScheme;
                        return Container(
                          width: markerSize,
                          height: markerSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: cs.primary, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Icon(icon, size: innerIconSize, color: iconColor),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildTopImage() {
    final url = _plant?.imageURL;
    const double height = 220;
    final Widget imageWidget;

    if (_localPhotoPath != null && _localPhotoPath!.isNotEmpty && File(_localPhotoPath!).existsSync()) {
      imageWidget = Image.file(
        File(_localPhotoPath!),
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => _imagePlaceholder(height: height),
      );
    } else if (url != null && url.isNotEmpty) {
      imageWidget = Image.network(
        url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => _imagePlaceholder(height: height),
      );
    } else {
      imageWidget = _imagePlaceholder(height: height);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: imageWidget,
    );
  }

  Widget _imagePlaceholder({double height = 220, bool isLoading = false}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: isLoading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco, size: 70, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                const SizedBox(height: 12),
                Text(
                  'Imagem indisponível',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }
}

extension on BuildContext {
  void showSnack(String msg) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(msg)));
  }
}

extension _PickSave on _PlantDetailPageState {
  Future<void> _onTakePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera, maxWidth: 2048, imageQuality: 85);
      if (image == null) return;
      final savedPath = await _photoService.savePhotoForPlant(widget.plantId, File(image.path));
      if (!mounted) return;
      setState(() => _localPhotoPath = savedPath);
      if (!mounted) return;
      context.showSnack('Foto salva para esta planta.');
    } catch (e) {
      if (!mounted) return;
      context.showSnack('Falha ao salvar foto: $e');
    }
  }
}