import 'package:flutter/material.dart';
import 'package:smartgreen/widgets/loading_indicator.dart';

class LoadingIndicatorTestScreen extends StatefulWidget {
  const LoadingIndicatorTestScreen({super.key});

  @override
  State<LoadingIndicatorTestScreen> createState() => _LoadingIndicatorTestScreenState();
}

class _LoadingIndicatorTestScreenState extends State<LoadingIndicatorTestScreen> {
  bool _isLoadingButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading Indicator Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Loading Padrão',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(24.0),
                child: SizedBox(
                  height: 100, // Altura para o indicador padrão
                  child: LoadingIndicator(),
                ),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Loading com Mensagem',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(24.0),
                child: SizedBox(
                  height: 150, // Altura para o indicador com mensagem
                  child: LoadingIndicator(message: 'Carregando suas plantas...'),
                ),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Loading Compacto em Botão',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoadingButton ? null : () {
                setState(() {
                  _isLoadingButton = true;
                });
                Future.delayed(const Duration(seconds: 3), () {
                  setState(() {
                    _isLoadingButton = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ação concluída!')),
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Theme.of(context).colorScheme.primary, // Cor primária para o botão
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: _isLoadingButton
                  ? const LoadingIndicator(compact: true, color: Colors.white) // Cor branca para contraste no botão
                  : const Text('Salvar Alterações'),
            ),
            const SizedBox(height: 16),
             ElevatedButton(
              onPressed: _isLoadingButton ? null : () {
                setState(() {
                  _isLoadingButton = true;
                });
                Future.delayed(const Duration(seconds: 3), () {
                  setState(() {
                    _isLoadingButton = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ação concluída!')),
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Theme.of(context).colorScheme.tertiary, // Cor azul para o botão
                foregroundColor: Theme.of(context).colorScheme.onTertiary,
              ),
              child: _isLoadingButton
                  ? LoadingIndicator(compact: true, color: Theme.of(context).colorScheme.onTertiary) // Cor contrastante no botão
                  : const Text('Adicionar Novo Item'),
            ),
          ],
        ),
      ),
    );
  }
}