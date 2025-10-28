import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool compact; // Para uso em botões ou lugares compactos
  final Color? color; // Cor opcional do indicador

  const LoadingIndicator({
    super.key,
    this.message,
    this.compact = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    if (compact) {
      return SizedBox(
        width: 20, // Tamanho menor para botões
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2, // Fino para compact
          valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}