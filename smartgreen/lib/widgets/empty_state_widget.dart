import 'package:flutter/material.dart';
import 'package:smartgreen/widgets/leaf_glyph.dart'; // Importe o LeafGlyph

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon; // Ícone ilustrativo (opcional)
  final String? buttonText; // Texto do botão de ação (opcional)
  final VoidCallback? onButtonPressed; // Callback do botão (opcional)

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ícone ilustrativo ou LeafGlyph padrão
              if (icon != null)
                Icon(
                  icon,
                  size: 80,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                )
              else
                LeafGlyph.empty(), // Usando o LeafGlyph padrão para empty states
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              if (buttonText != null && onButtonPressed != null)
                Column(
                  children: [
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: onButtonPressed,
                      child: Text(buttonText!),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}