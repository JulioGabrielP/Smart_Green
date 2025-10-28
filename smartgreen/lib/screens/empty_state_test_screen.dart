import 'package:flutter/material.dart';
import 'package:smartgreen/widgets/empty_state_widget.dart';

class EmptyStateTestScreen extends StatelessWidget {
  const EmptyStateTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empty State Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Teste 1: Padrão com LeafGlyph e botão
            Card(
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: EmptyStateWidget(
                  title: 'Nenhuma planta encontrada!',
                  message: 'Parece que você ainda não cadastrou nenhuma planta. Comece agora!',
                  buttonText: 'Cadastrar primeira planta',
                  onButtonPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Botão "Cadastrar" pressionado!')),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Teste 2: Com ícone customizado e sem botão
            Card(
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: EmptyStateWidget(
                  title: 'Nenhum histórico disponível',
                  message: 'Suas atividades recentes aparecerão aqui.',
                  icon: Icons.history, // Exemplo de ícone customizado
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Teste 3: Apenas com LeafGlyph, título e mensagem (sem botão)
            Card(
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: EmptyStateWidget(
                  title: 'Carrinho vazio',
                  message: 'Explore nosso catálogo e adicione itens!',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Teste 4: Layout simulado em uma lista (ex: resultados de busca)
            Card(
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: EmptyStateWidget(
                  title: 'Nenhum resultado para "rosas"',
                  message: 'Tente uma busca diferente ou explore nossas categorias.',
                  icon: Icons.search_off,
                  buttonText: 'Ver todas as categorias',
                  onButtonPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Botão "Ver categorias" pressionado!')),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}