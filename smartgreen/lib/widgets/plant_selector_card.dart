// lib/widgets/plant_selector_card.dart
import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../theme/app_colors.dart'; // Importar AppColors para usar surfaceAlt

class PlantSelectorCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;

  const PlantSelectorCard({
    super.key,
    required this.plant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    Widget plantImageWidget;
    plantImageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: plant.imageURL != null && plant.imageURL!.isNotEmpty
          ? Image.network(
              plant.imageURL!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholderImage(colorScheme),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildPlaceholderImage(colorScheme, isLoading: true);
              },
            )
          : _buildPlaceholderImage(colorScheme),
    );

    return Card(
      color: colorScheme.surface,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              plantImageWidget,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name,
                      style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vaso Conectado: Online',
                      style: textTheme.bodySmall!.copyWith(color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: colorScheme.onSurface.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(ColorScheme colorScheme, {bool isLoading = false}) {
    return Container(
      width: 60,
      height: 60,
      color: AppColors.surfaceAlt, // Corrigido para AppColors.surfaceAlt
      child: isLoading
          ? Center(child: CircularProgressIndicator(strokeWidth: 2.0, valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary)))
          : Icon(Icons.eco, color: colorScheme.primary.withOpacity(0.6), size: 30),
    );
  }
}