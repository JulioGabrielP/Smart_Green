// lib/screens/supply_list_page.dart
import 'package:flutter/material.dart';
import '../models/supply.dart';
import '../services/supply_service.dart';
import '../shared/searchable_tab.dart';
import '../widgets/custom_button.dart';
import '../widgets/supply_card_widget.dart';
import 'supply_form_page.dart';

class SupplyListPage extends StatefulWidget {
  const SupplyListPage({super.key});

  @override
  SupplyListPageState createState() => SupplyListPageState();
}

class SupplyListPageState extends State<SupplyListPage> with SearchableTab {
  final SupplyService _service = SupplyService();
  String _searchQuery = '';

  @override
  String get searchHint => 'Pesquisar insumo...';

  @override
  void applySearch(String query) {
    setState(() => _searchQuery = query.toLowerCase().trim());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Supply>>(
            stream: _service.getSupplies(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Erro ao carregar insumos.'),
                );
              }

              final all = snapshot.data ?? [];
              final filtered = all
                  .where((s) => s.name.toLowerCase().contains(_searchQuery))
                  .toList();

              if (filtered.isEmpty) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.inventory_2,
                            size: 48,
                            color: Colors.black26,
                          ),
                          const SizedBox(height: 12),
                          const Text('Nenhum insumo encontrado.'),
                          const SizedBox(height: 16),
                          CustomButton(
                            label: 'Cadastrar novo insumo',
                            icon: Icons.add,
                            backgroundColor: cs.primary,
                            textColor: cs.onPrimary,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SupplyFormPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // ========== NOVA IMPLEMENTAÇÃO COM SupplyCardWidget ==========
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final supply = filtered[index];

                  return SupplyCardWidget(
                    supply: supply,
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SupplyFormPage(supply: supply),
                        ),
                      );
                    },
                    onDelete: () async {
                      await _service.deleteSupply(supply.id);
                    },
                  );
                },
              );
            },
          ),
        ),

        // Botão flutuante "Cadastrar novo insumo"
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SafeArea(
            top: false,
            child: CustomButton(
              label: 'Cadastrar novo insumo',
              icon: Icons.add,
              backgroundColor: cs.primary,
              textColor: cs.onPrimary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SupplyFormPage(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}