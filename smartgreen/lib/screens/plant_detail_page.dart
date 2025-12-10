import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; 

import '../models/plant.dart';
import '../services/plant_service.dart';
import '../services/user_photo_service.dart';
import 'plant_form_page.dart';

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

  // ===========================================================================
  // [ÁREA DE INTEGRAÇÃO - MEMBRO DO GRUPO]
  // ===========================================================================
  // Essas são as variáveis que vão segurar os dados vindos da nuvem (Firebase/IoT).
  // Atualmente estão nulas, o que fará aparecer "Carregando..." ou "--".
  double? _sensorTemp;     // Temperatura atual
  double? _sensorHumidity; // Umidade atual
  double? _sensorLight;    // Luminosidade atual
  String _sensorStatus = 'Atualizando...'; // Status calculado
  // ===========================================================================

  @override
  void initState() {
    super.initState();
    _loadPlant();
    _fetchSensorData(); // Chama a função que busca os dados dos sensores
  }

  // ===========================================================================
  // [ÁREA DE INTEGRAÇÃO - MEMBRO DO GRUPO]
  // DICA: Substitua o conteúdo desta função pela chamada real à API/Firebase
  // ===========================================================================
  Future<void> _fetchSensorData() async {
    // TODO: Implementar a lógica real de busca de dados aqui.
    // Exemplo: final dados = await IotService.getLatestData(widget.plantId);
    
    try {
      // Simulando um delay de rede (remover isso na versão final)
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        // AQUI VOCÊ ATRIBUI OS VALORES REAIS
        // Exemplo: _sensorTemp = dados.temperatura;
        _sensorTemp = 26.5;      // Valor Exemplo (Apagar depois)
        _sensorHumidity = 55.0;  // Valor Exemplo (Apagar depois)
        _sensorLight = 14.2;     // Valor Exemplo (Apagar depois)
        _sensorStatus = 'Saudável';
      });
    } catch (e) {
      debugPrint("Erro ao buscar dados dos sensores: $e");
    }
  }
  // ===========================================================================

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

              _buildInfoSection(colorScheme, textTheme),
              const SizedBox(height: 24),

              _buildSectionTitle(context, 'Histórico de Dados'),
              const SizedBox(height: 12),
              _buildChartPlaceholder(colorScheme),
              const SizedBox(height: 24),

              _buildSectionTitle(context, 'Cuidados Recomendados'),
              const SizedBox(height: 12),
              _buildRecommendedCare(colorScheme, textTheme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
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

  Widget _buildInfoSection(ColorScheme colorScheme, TextTheme textTheme) {
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
                  value: _sensorTemp != null ? '${_sensorTemp!.toStringAsFixed(1)} °C' : 'Carregando...',
                  color: Colors.redAccent,
                ),
                _buildInfoRow(
                  icon: Icons.opacity,
                  label: 'Umidade',
                  value: _sensorHumidity != null ? '${_sensorHumidity!.toStringAsFixed(1)} %' : 'Carregando...',
                  color: Colors.blueAccent,
                ),
                _buildInfoRow(
                  icon: Icons.wb_sunny,
                  label: 'Luminosidade',
                  value: _sensorLight != null ? '${_sensorLight!.toStringAsFixed(1)} h' : 'Carregando...',
                  color: Colors.amber,
                ),
                _buildInfoRow(
                  icon: Icons.favorite,
                  label: 'Status da Planta',
                  value: _sensorStatus,
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
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: value == 'Carregando...' ? Colors.grey : null,
            ),
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_empty, size: 50, color: colorScheme.onSurface.withOpacity(0.4)),
              const SizedBox(height: 12),
              Text(
                'Coletando dados...',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'É necessário coletar dados por pelo menos 7 dias para gerar o histórico visual.',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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