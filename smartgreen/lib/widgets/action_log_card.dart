// lib/widgets/action_log_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartgreen/models/action_log.dart'; // Importar o novo modelo de ActionLog

class ActionLogCard extends StatelessWidget {
  final ActionLog log; // Usa o ActionLog definido em lib/models/action_log.dart

  const ActionLogCard({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(log.icon, color: log.iconColor ?? colorScheme.primary.withOpacity(0.7), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.description,
                  style: textTheme.bodyLarge!.copyWith(color: colorScheme.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM HH:mm').format(log.timestamp.toLocal()),
                  style: textTheme.bodySmall!.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}