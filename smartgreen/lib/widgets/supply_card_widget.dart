// lib/widgets/supply_card_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/supply.dart';

/// Widget de card para exibir insumos do estoque.
/// 
/// Funcionalidades:
/// - Exibe imagem, nome, quantidade e validade
/// - Badge de categoria (Fertilizante, Substrato, etc)
/// - Alerta de estoque baixo (< 5 unidades)
/// - Alerta de validade próxima (< 30 dias)
/// - Botões de editar e excluir
/// - Swipe para excluir
class SupplyCardWidget extends StatelessWidget {
  const SupplyCardWidget({
    super.key,
    required this.supply,
    required this.onEdit,
    required this.onDelete,
  });

  final Supply supply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Verifica se o estoque está baixo (< 5 unidades)
  bool get _isLowStock => supply.quantity < 5;

  /// Verifica se a validade está próxima (< 30 dias) ou vencida
  bool get _isExpiringOrExpired {
    final validade = _parseValidity(supply.validity);
    if (validade == null) return false;
    final diff = validade.difference(DateTime.now()).inDays;
    return diff <= 30;
  }

  /// Verifica se já está vencido
  bool get _isExpired {
    final validade = _parseValidity(supply.validity);
    if (validade == null) return false;
    return validade.isBefore(DateTime.now());
  }

  /// Parse da data de validade (aceita vários formatos)
  DateTime? _parseValidity(String validity) {
    if (validity.isEmpty) return null;

    try {
      // Formato: dd/MM/yyyy
      if (validity.contains('/')) {
        final parts = validity.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]), // ano
            int.parse(parts[1]), // mês
            int.parse(parts[0]), // dia
          );
        }
      }
      // Formato: yyyy-MM-dd
      return DateTime.parse(validity);
    } catch (_) {
      return null;
    }
  }

  /// Formata a data de validade para exibição
  String _formatValidity(String validity) {
    final date = _parseValidity(validity);
    if (date == null) return validity;

    final diff = date.difference(DateTime.now()).inDays;

    if (_isExpired) {
      return '❌ Vencido';
    } else if (diff <= 7) {
      return '⚠️ Vence em $diff dias';
    } else if (diff <= 30) {
      return '⏰ Vence em $diff dias';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  /// Detecta a categoria do insumo pelo nome (heurística simples)
  String _detectCategory() {
    final name = supply.name.toLowerCase();
    if (name.contains('fertilizante') ||
        name.contains('adubo') ||
        name.contains('npk')) {
      return 'Fertilizante';
    } else if (name.contains('substrato') ||
        name.contains('terra') ||
        name.contains('solo')) {
      return 'Substrato';
    } else if (name.contains('ferramenta') ||
        name.contains('regador') ||
        name.contains('vaso')) {
      return 'Ferramenta';
    } else if (name.contains('semente')) {
      return 'Semente';
    }
    return 'Insumo';
  }

  /// Retorna a cor da categoria
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Fertilizante':
        return const Color(0xFF8BC34A); // Verde claro
      case 'Substrato':
        return const Color(0xFF795548); // Marrom
      case 'Ferramenta':
        return const Color(0xFF607D8B); // Azul-cinza
      case 'Semente':
        return const Color(0xFFFFC107); // Amarelo
      default:
        return const Color(0xFF9E9E9E); // Cinza
    }
  }

  /// Retorna o ícone da categoria
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Fertilizante':
        return Icons.science;
      case 'Substrato':
        return Icons.grass;
      case 'Ferramenta':
        return Icons.build;
      case 'Semente':
        return Icons.spa;
      default:
        return Icons.inventory_2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final category = _detectCategory();

    return Dismissible(
      key: ValueKey(supply.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Excluir insumo'),
            content: Text(
              'Deseja realmente excluir "${supply.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Excluir',
                  style: TextStyle(color: cs.error),
                ),
              ),
            ],
          ),
        );
        if (ok == true) {
          onDelete();
        }
        return false; // Não remove automaticamente, deixa o callback fazer
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: cs.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: cs.error),
            const SizedBox(width: 8),
            Text(
              'Excluir',
              style: TextStyle(
                color: cs.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========== IMAGEM ==========
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: _buildImage(),
                  ),
                ),

                const SizedBox(width: 12),

                // ========== CONTEÚDO ==========
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome + Badge de Categoria
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              supply.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildCategoryBadge(category),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Alertas (Estoque Baixo / Validade)
                      if (_isLowStock || _isExpiringOrExpired) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (_isLowStock) _buildAlertBadge(
                              icon: Icons.warning,
                              label: 'Estoque baixo',
                              color: Colors.orange.shade700,
                            ),
                            if (_isExpired) _buildAlertBadge(
                              icon: Icons.dangerous,
                              label: 'Vencido',
                              color: Colors.red.shade700,
                            )
                            else if (_isExpiringOrExpired) _buildAlertBadge(
                              icon: Icons.schedule,
                              label: 'Vence em breve',
                              color: Colors.amber.shade700,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Informações (Quantidade + Validade)
                      Row(
                        children: [
                          // Quantidade
                          _buildInfo(
                            icon: Icons.inventory_2,
                            label: 'Qtd: ${supply.quantity}',
                            color: _isLowStock
                                ? Colors.orange.shade700
                                : cs.primary,
                          ),
                          const SizedBox(width: 16),
                          // Validade
                          Expanded(
                            child: _buildInfo(
                              icon: Icons.event,
                              label: _formatValidity(supply.validity),
                              color: _isExpiringOrExpired
                                  ? (_isExpired ? Colors.red : Colors.amber.shade700)
                                  : cs.primary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Botões de Ação
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit,
                            tooltip: 'Editar',
                            color: const Color(0xFF1976D2),
                            onPressed: onEdit,
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.delete,
                            tooltip: 'Excluir',
                            color: Colors.red.shade400,
                            onPressed: onDelete,
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
    );
  }

  /// Constrói a imagem com fallback
  Widget _buildImage() {
    if (supply.imageUrl != null && supply.imageUrl!.trim().isNotEmpty) {
      return Image.network(
        supply.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _buildPlaceholder(isLoading: true);
        },
      );
    }
    return _buildPlaceholder();
  }

  /// Placeholder quando não há imagem
  Widget _buildPlaceholder({bool isLoading = false}) {
    return Container(
      color: const Color(0xFFF5F5F5),
      alignment: Alignment.center,
      child: isLoading
          ? const CircularProgressIndicator(strokeWidth: 2.5)
          : const Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: Color(0xFF9E9E9E),
            ),
    );
  }

  /// Badge de categoria
  Widget _buildCategoryBadge(String category) {
    final color = _getCategoryColor(category);
    final icon = _getCategoryIcon(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            category,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Badge de alerta (estoque baixo, vencido)
  Widget _buildAlertBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Informação (quantidade/validade)
  Widget _buildInfo({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Botão de ação compacto
  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}