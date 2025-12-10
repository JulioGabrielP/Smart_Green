// lib/widgets/plant_card_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/plant.dart';
// Mantém se ainda for usado, mas não parece estar
import '../services/user_photo_service.dart';

/// Widget de card para exibir informações de uma planta.
///
/// Funcionalidades:
/// - Swipe direita: Editar
/// - Swipe esquerda: Apagar
/// - Tap: Abrir detalhes
/// - Long press: Apagar (com confirmação)
class PlantCardWidget
    extends
        StatelessWidget {
  final Plant plant;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onOpen;

  const PlantCardWidget({
    super.key,
    required this.plant,
    required this.onDelete,
    required this.onEdit,
    required this.onOpen,
  });

  /// Retorna a cor do status baseado no valor
  Color _colorFromStatus(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'verde':
        return const Color(
          0xFF4CAF50,
        );
      case 'amarelo':
        return const Color(
          0xFFFFC107,
        );
      case 'laranja':
        return const Color(
          0xFFFF9800,
        );
      case 'vermelho':
        return const Color(
          0xFFF44336,
        );
      default:
        return Colors.grey;
    }
  }

  /// Retorna o texto do status
  String _statusText(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'verde':
        return 'Saudável';
      case 'amarelo':
        return 'Atenção';
      case 'laranja':
        return 'Alerta';
      case 'vermelho':
        return 'Crítico';
      default:
        return 'Indefinido';
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final cs =
        Theme.of(
          context,
        ).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal:
            16,
        vertical:
            8,
      ),
      child: Dismissible(
        key: ValueKey(
          plant.id,
        ),
        direction:
            DismissDirection.horizontal,
        // Swipe direita: Editar
        background: _swipeBg(
          align:
              Alignment.centerLeft,
          icon:
              Icons.edit,
          color: cs.primary.withOpacity(
            0.1,
          ), // Alterado para withOpacity
          iconColor:
              cs.primary,
          text:
              'Editar',
        ),
        // Swipe esquerda: Apagar
        secondaryBackground: _swipeBg(
          align:
              Alignment.centerRight,
          icon:
              Icons.delete,
          color: cs.error.withOpacity(
            0.1,
          ), // Alterado para withOpacity
          iconColor:
              cs.error,
          text:
              'Apagar',
        ),
        confirmDismiss: (
          direction,
        ) async {
          if (direction ==
              DismissDirection.startToEnd) {
            onEdit();
          } else if (direction ==
              DismissDirection.endToStart) {
            onDelete();
          }
          return false; // Não remove da lista (a tela pai controla)
        },
        child: Card(
          elevation:
              3,
          clipBehavior:
              Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
          child: InkWell(
            onTap:
                onOpen,
            borderRadius: BorderRadius.circular(
              12,
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                12,
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ========== IMAGEM (80x80 fixo) - COM HERO ==========
                  Hero(
                    tag:
                        'plantImage-${plant.id}', // Tag Hero deve ser única
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                      child: SizedBox(
                        width:
                            80,
                        height:
                            80,
                        child:
                            _buildImage(),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width:
                        12,
                  ),

                  // ========== CONTEÚDO ==========
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // Nome + Badge de Status
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plant.name,
                                maxLines:
                                    1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w700,
                                  fontSize:
                                      16,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width:
                                  8,
                            ),
                            _buildStatusBadge(),
                          ],
                        ),

                        const SizedBox(
                          height:
                              8,
                        ),

                        // Métricas (Temperatura e Umidade MÉDIAS)
                        Row(
                          children: [
                            // Temperatura média
                            if (plant.mediaTemperatura !=
                                null) ...[
                              _metric(
                                cs,
                                Icons.thermostat,
                                '${plant.mediaTemperatura!.toStringAsFixed(1)}°C',
                                const Color(
                                  0xFFFF6B6B,
                                ),
                              ),
                              const SizedBox(
                                width:
                                    16,
                              ),
                            ],

                            // Umidade média
                            if (plant.mediaUmidade !=
                                null)
                              _metric(
                                cs,
                                Icons.water_drop,
                                '${plant.mediaUmidade!.toStringAsFixed(0)}%',
                                const Color(
                                  0xFF4FC3F7,
                                ),
                              ),

                            // Se não tiver médias, mostra faixas
                            if (plant.mediaTemperatura ==
                                    null &&
                                plant.mediaUmidade ==
                                    null)
                              Text(
                                'Sem dados de sensores',
                                style: TextStyle(
                                  fontSize:
                                      12,
                                  color:
                                      Colors.grey.shade600,
                                  fontStyle:
                                      FontStyle.italic,
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(
                          height:
                              12,
                        ),

                        // Botões de Ação (compactos)
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.end,
                          children: [
                            _actionButton(
                              icon:
                                  Icons.visibility,
                              tooltip:
                                  'Ver detalhes',
                              color:
                                  cs.primary,
                              onPressed:
                                  onOpen,
                            ),
                            const SizedBox(
                              width:
                                  8,
                            ),
                            _actionButton(
                              icon:
                                  Icons.edit,
                              tooltip:
                                  'Editar',
                              color: const Color(
                                0xFF1976D2,
                              ),
                              onPressed:
                                  onEdit,
                            ),
                            const SizedBox(
                              width:
                                  8,
                            ),
                            _actionButton(
                              icon:
                                  Icons.delete,
                              tooltip:
                                  'Excluir',
                              color:
                                  Colors.red.shade400,
                              onPressed:
                                  onDelete,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói a imagem com fallback para local → URL → placeholder
  Widget _buildImage() {
    final url =
        plant.imageURL;
    return FutureBuilder<
      String?
    >(
      future: UserPhotoService().getPhotoPath(
        plant.id,
      ),
      builder: (
        context,
        snap,
      ) {
        final localPath =
            snap.data;

        // 1. Tenta imagem local
        if (localPath !=
                null &&
            localPath.isNotEmpty &&
            File(
              localPath,
            ).existsSync()) {
          return Image.file(
            File(
              localPath,
            ),
            fit:
                BoxFit.cover,
            errorBuilder:
                (
                  _,
                  __,
                  ___,
                ) =>
                    _imagePlaceholder(),
          );
        }

        // 2. Tenta imagem da URL
        if (url !=
                null &&
            url.isNotEmpty) {
          return Image.network(
            url,
            fit:
                BoxFit.cover,
            errorBuilder:
                (
                  _,
                  __,
                  ___,
                ) =>
                    _imagePlaceholder(),
            loadingBuilder: (
              context,
              child,
              progress,
            ) {
              if (progress ==
                  null)
                return child;
              return _imagePlaceholder(
                isLoading:
                    true,
              );
            },
          );
        }

        // 3. Placeholder padrão
        return _imagePlaceholder(
          isLoading:
              snap.connectionState ==
              ConnectionState.waiting,
        );
      },
    );
  }

  /// Placeholder quando não há imagem
  Widget _imagePlaceholder({
    bool isLoading =
        false,
  }) {
    return Container(
      color: const Color(
        0xFFE8F5E9,
      ),
      alignment:
          Alignment.center,
      child:
          isLoading
              ? const SizedBox(
                height:
                    24,
                width:
                    24,
                child: CircularProgressIndicator(
                  strokeWidth:
                      2.5,
                ),
              )
              : const Icon(
                Icons.local_florist,
                size:
                    40,
                color: Color(
                  0xFF4CAF50,
                ),
              ),
    );
  }

  /// Badge de status textual (Saudável/Atenção/Crítico)
  Widget _buildStatusBadge() {
    final color = _colorFromStatus(
      plant.status,
    );
    final text = _statusText(
      plant.status,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal:
            8,
        vertical:
            4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(
          0.15,
        ), // Alterado para withOpacity
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: color.withOpacity(
            0.3,
          ),
        ), // Alterado para withOpacity
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize:
              11,
          fontWeight:
              FontWeight.w600,
          color:
              color,
        ),
      ),
    );
  }

  /// Métrica de temperatura/umidade
  Widget _metric(
    ColorScheme cs,
    IconData icon,
    String text,
    Color color,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Icon(
          icon,
          size:
              18,
          color:
              color,
        ),
        const SizedBox(
          width:
              4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize:
                14,
            fontWeight:
                FontWeight.w600,
            color:
                color,
          ),
        ),
      ],
    );
  }

  /// Botão de ação compacto
  Widget _actionButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message:
          tooltip,
      child: InkWell(
        onTap:
            onPressed,
        borderRadius: BorderRadius.circular(
          8,
        ),
        child: Container(
          padding: const EdgeInsets.all(
            6,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(
              0.1,
            ), // Alterado para withOpacity
            borderRadius: BorderRadius.circular(
              8,
            ),
          ),
          child: Icon(
            icon,
            size:
                20,
            color:
                color,
          ),
        ),
      ),
    );
  }

  /// Background do swipe (editar/apagar)
  Widget _swipeBg({
    required Alignment align,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      alignment:
          align,
      padding: const EdgeInsets.symmetric(
        horizontal:
            20,
      ),
      color:
          color,
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            color:
                iconColor,
          ),
          const SizedBox(
            width:
                8,
          ),
          Text(
            text,
            style: TextStyle(
              color:
                  iconColor,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
