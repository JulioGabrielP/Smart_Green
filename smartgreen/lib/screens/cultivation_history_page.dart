import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

class CultivationHistoryPage extends StatelessWidget {
  const CultivationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de cultivo')),
      body: settings.history.isEmpty
          ? const Center(child: Text('Nenhum histórico registrado'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: settings.history.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final item = settings.history[i];
                return ListTile(
                  title: Text(item),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => settings.removeHistoryItemAt(i),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final ctrl = TextEditingController();
          final result = await showDialog<String?>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Adicionar cultivo'),
              content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Ex: Tomate')),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                TextButton(onPressed: () => Navigator.of(context).pop(ctrl.text), child: const Text('Adicionar')),
              ],
            ),
          );
          if (result != null && result.trim().isNotEmpty) {
            await settings.addHistoryItem(result);
          }
        },
      ),
    );
  }
}
