// lib/screens/control_page.dart
import 'package:flutter/material.dart';
import 'package:smartgreen/models/action_log.dart';
import 'package:smartgreen/models/plant.dart';
import 'package:smartgreen/widgets/action_log_card.dart';
import 'package:smartgreen/widgets/custom_button.dart';
import 'package:smartgreen/widgets/plant_selector_card.dart';
import 'package:smartgreen/theme/app_colors.dart';

class ControlPage
    extends
        StatefulWidget {
  const ControlPage({
    super.key,
  });

  @override
  State<
    ControlPage
  >
  createState() =>
      _ControlPageState();
}

class _ControlPageState
    extends
        State<
          ControlPage
        > {
  final Plant _selectedPlant = Plant(
    id:
        'plant_001',
    name:
        'Rosa do Deserto',
    status:
        'verde',
    imageURL:
        'https://images.unsplash.com/photo-1518490104631-c483216ee953?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  );

  bool _isLightOn =
      false;
  bool _isVentilationOn =
      false;
  bool _isWatering =
      false;

  final List<
    ActionLog
  >
  _actionHistory = [
    ActionLog(
      icon:
          Icons.water_drop_outlined,
      iconColor:
          Colors.blue.shade400,
      description:
          'Água ligada manualmente',
      timestamp: DateTime.now().subtract(
        const Duration(
          minutes:
              5,
        ),
      ),
    ),
    ActionLog(
      icon:
          Icons.lightbulb_outline,
      iconColor:
          Colors.orange.shade400,
      description:
          'Luz ativada automaticamente',
      timestamp: DateTime.now().subtract(
        const Duration(
          minutes:
              20,
        ),
      ),
    ),
    ActionLog(
      icon:
          Icons.air, // Corrigido de mode_fan para air
      iconColor:
          Colors.grey.shade600,
      description:
          'Ventilação desligada por agendamento',
      timestamp: DateTime.now().subtract(
        const Duration(
          hours:
              1,
        ),
      ),
    ),
  ];

  void _toggleLight(
    bool value,
  ) {
    setState(
      () {
        _isLightOn =
            value;
        _actionHistory.insert(
          0,
          ActionLog(
            icon:
                Icons.lightbulb_outline,
            iconColor:
                value
                    ? Colors.orange.shade400
                    : Colors.grey.shade600,
            description:
                value
                    ? 'Luz ligada'
                    : 'Luz desligada',
            timestamp:
                DateTime.now(),
          ),
        );
      },
    );
  }

  void _toggleVentilation(
    bool value,
  ) {
    setState(
      () {
        _isVentilationOn =
            value;
        _actionHistory.insert(
          0,
          ActionLog(
            icon:
                Icons.air, // Corrigido
            iconColor:
                value
                    ? Colors.blue.shade300
                    : Colors.grey.shade600,
            description:
                value
                    ? 'Ventilação ligada'
                    : 'Ventilação desligada',
            timestamp:
                DateTime.now(),
          ),
        );
      },
    );
  }

  Future<
    void
  >
  _startWatering() async {
    setState(
      () {
        _isWatering =
            true;
      },
    );
    await Future.delayed(
      const Duration(
        seconds:
            2,
      ),
    );
    setState(
      () {
        _isWatering =
            false;
        _actionHistory.insert(
          0,
          ActionLog(
            icon:
                Icons.water_drop_outlined,
            iconColor:
                Colors.blue.shade400,
            description:
                'Água ligada manualmente',
            timestamp:
                DateTime.now(),
          ),
        );
      },
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'Irrigação iniciada!',
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final ColorScheme colorScheme =
        Theme.of(
          context,
        ).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Controle do Vaso',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            16.0,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              Text(
                'Planta Atual',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(
                  fontWeight:
                      FontWeight.bold,
                  color:
                      colorScheme.onSurface,
                ),
              ),
              const SizedBox(
                height:
                    8,
              ),
              PlantSelectorCard(
                plant:
                    _selectedPlant,
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Navegar para seleção de vasos',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(
                height:
                    24,
              ),

              Text(
                'Controles Manuais',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(
                  fontWeight:
                      FontWeight.bold,
                  color:
                      colorScheme.onSurface,
                ),
              ),
              const SizedBox(
                height:
                    8,
              ),
              Card(
                color:
                    AppColors.surfaceAlt,
                child: Padding(
                  padding: const EdgeInsets.all(
                    16.0,
                  ),
                  child: Column(
                    children: [
                      CustomButton(
                        label:
                            _isWatering
                                ? 'Irrigando...'
                                : 'Ligar Água',
                        icon:
                            Icons.water_drop,
                        backgroundColor:
                            colorScheme.primary,
                        onPressed:
                            _isWatering
                                ? null
                                : _startWatering,
                      ),
                      const SizedBox(
                        height:
                            16,
                      ),

                      _buildControlToggle(
                        context,
                        icon:
                            Icons.lightbulb_outline,
                        label:
                            'Luz ON/OFF',
                        value:
                            _isLightOn,
                        onChanged:
                            _toggleLight,
                        activeColor:
                            Colors.orange.shade400,
                      ),
                      const Divider(
                        height:
                            32,
                      ),

                      _buildControlToggle(
                        context,
                        icon:
                            Icons.air, // Corrigido
                        label:
                            'Ventilação',
                        value:
                            _isVentilationOn,
                        onChanged:
                            _toggleVentilation,
                        activeColor:
                            Colors.blue.shade300,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height:
                    24,
              ),

              Text(
                'Histórico de Ações Recentes',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(
                  fontWeight:
                      FontWeight.bold,
                  color:
                      colorScheme.onSurface,
                ),
              ),
              const SizedBox(
                height:
                    8,
              ),
              _actionHistory.isEmpty
                  ? Card(
                    color:
                        colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(
                        16.0,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_note,
                            size:
                                48,
                            color:
                                Colors.grey.shade400,
                          ),
                          const SizedBox(
                            height:
                                8,
                          ),
                          Text(
                            'Nenhuma ação registrada ainda.',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.copyWith(
                              color:
                                  Colors.grey.shade600,
                            ),
                            textAlign:
                                TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                  : Card(
                    color:
                        AppColors.surfaceAlt,
                    child: ListView.builder(
                      shrinkWrap:
                          true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount:
                          _actionHistory.length,
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        return ActionLogCard(
                          log:
                              _actionHistory[index],
                        );
                      },
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlToggle(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<
      bool
    >
    onChanged,
    required Color activeColor,
  }) {
    final ColorScheme colorScheme =
        Theme.of(
          context,
        ).colorScheme;
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color:
                  value
                      ? activeColor
                      : colorScheme.onSurface.withOpacity(
                        0.6,
                      ),
              size:
                  28,
            ),
            const SizedBox(
              width:
                  12,
            ),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(
                color:
                    colorScheme.onSurface,
              ),
            ),
          ],
        ),
        Switch(
          value:
              value,
          onChanged:
              onChanged,
          activeThumbColor:
              activeColor,
          inactiveThumbColor: colorScheme.onSurface.withOpacity(
            0.4,
          ),
          inactiveTrackColor: colorScheme.onSurface.withOpacity(
            0.1,
          ),
        ),
      ],
    );
  }
}
