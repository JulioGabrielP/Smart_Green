import 'package:flutter/material.dart';
import 'package:smartgreen/utils/snackbar_helper.dart';

class SnackbarTestScreen extends StatelessWidget {
  const SnackbarTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snackbar Test'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  SnackbarHelper.showSuccess(
                    context: context,
                    message: 'Operação realizada com sucesso!',
                  );
                },
                child: const Text('Mostrar Snackbar de Sucesso'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  SnackbarHelper.showError(
                    context: context,
                    message: 'Erro ao carregar dados. Tente novamente mais tarde.',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('Mostrar Snackbar de Erro'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  SnackbarHelper.showInfo(
                    context: context,
                    message: 'Você tem novas notificações pendentes.',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Mostrar Snackbar de Informação'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  SnackbarHelper.show(
                    context: context,
                    message: 'Snackbar customizado com ícone de alerta e cor amarela!',
                    icon: Icons.warning_amber_rounded,
                    backgroundColor: Colors.amber.shade700,
                    textColor: Colors.black,
                    iconColor: Colors.black,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Mostrar Snackbar Customizado'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}