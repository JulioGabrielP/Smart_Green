import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartgreen/theme/app_colors.dart'; // Importa AppColors
import '../services/settings_service.dart'; // Mantém o serviço de configurações

// Modelo de dados simulado para um cultivo (para fins de UI)
class CultivationItem {
  final String id;
  final String name;
  final String imageUrl;
  final DateTime startDate;
  final DateTime? endDate; // Pode ser nulo se ainda estiver ativo
  final String status; // Ex: 'Concluído', 'Ativo', ' '

  CultivationItem({
    required this.id,
    required this.name,
    this.imageUrl =
        'https://via.placeholder.com/150', // Imagem placeholder
    required this.startDate,
    this.endDate,
    this.status =
        'Concluído',
  });

  // Método para formatar o período de cultivo
  String get period {
    final start =
        '${startDate.day}/${startDate.month}/${startDate.year}';
    if (endDate ==
        null) {
      return '$start - Ativo';
    }
    final end =
        '${endDate!.day}/${endDate!.month}/${endDate!.year}';
    return '$start - $end';
  }
}

class CultivationHistoryPage
    extends
        StatefulWidget {
  const CultivationHistoryPage({
    super.key,
  });

  @override
  State<
    CultivationHistoryPage
  >
  createState() =>
      _CultivationHistoryPageState();
}

class _CultivationHistoryPageState
    extends
        State<
          CultivationHistoryPage
        > {
  // Lista simulada de cultivos para aprimorar a UI
  final List<
    CultivationItem
  >
  _cultivations = [
    CultivationItem(
      id:
          'c1',
      name:
          'Tomate Cereja - Varanda',
      imageUrl:
          'https://images.unsplash.com/photo-1627931985959-86ed110f01f4?q=80&w=1770&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      startDate: DateTime(
        2023,
        3,
        15,
      ),
      endDate: DateTime(
        2023,
        7,
        20,
      ),
      status:
          'Concluído',
    ),
    CultivationItem(
      id:
          'c2',
      name:
          'Hortelã Fresca - Cozinha',
      imageUrl:
          'https://images.unsplash.com/photo-1589745585093-4a18ceb8529e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      startDate: DateTime(
        2023,
        9,
        10,
      ),
      endDate:
          null, // Ainda ativo
      status:
          'Ativo',
    ),
    CultivationItem(
      id:
          'c3',
      name:
          'Orquídea Phalaenopsis',
      imageUrl:
          'https://images.unsplash.com/photo-1544485121-50e560b407b8?q=80&w=1770&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      startDate: DateTime(
        2022,
        11,
        5,
      ),
      endDate: DateTime(
        2023,
        2,
        28,
      ),
      status:
          'Concluído',
    ),
  ];

  String? _selectedYearFilter;
  String? _selectedStatusFilter;

  // Lista de anos disponíveis para filtro (extraídos dos dados simulados)
  List<
    String
  >
  get _availableYears {
    Set<
      String
    >
    years =
        {};
    for (var item in _cultivations) {
      years.add(
        item.startDate.year.toString(),
      );
      if (item.endDate !=
          null) {
        years.add(
          item.endDate!.year.toString(),
        );
      }
    }
    List<
      String
    >
    sortedYears =
        years.toList();
    sortedYears.sort(
      (
        a,
        b,
      ) => b.compareTo(
        a,
      ),
    ); // Anos mais recentes primeiro
    return sortedYears;
  }

  // Lista de status disponíveis
  List<
    String
  >
  get _availableStatuses => [
    'Ativo',
    'Concluído',
  ];

  // Aplica os filtros à lista de cultivos
  List<
    CultivationItem
  >
  get _filteredCultivations {
    List<
      CultivationItem
    >
    filtered =
        _cultivations;

    if (_selectedYearFilter !=
        null) {
      filtered =
          filtered.where(
            (
              item,
            ) {
              return item.startDate.year.toString() ==
                      _selectedYearFilter ||
                  (item.endDate !=
                          null &&
                      item.endDate!.year.toString() ==
                          _selectedYearFilter);
            },
          ).toList();
    }

    if (_selectedStatusFilter !=
        null) {
      filtered =
          filtered
              .where(
                (
                  item,
                ) =>
                    item.status ==
                    _selectedStatusFilter,
              )
              .toList();
    }
    return filtered;
  }

  // Função para simular a adição de um novo cultivo (mantém a lógica do FloatingActionButton)
  void _addCultivation(
    String name,
  ) {
    setState(
      () {
        _cultivations.add(
          CultivationItem(
            id:
                'c${_cultivations.length + 1}',
            name:
                name,
            imageUrl:
                'https://via.placeholder.com/150/random', // Imagem aleatória para novos itens
            startDate:
                DateTime.now(),
            endDate:
                null,
            status:
                'Ativo',
          ),
        );
      },
    );
    // Lógica para persistir a mudança (API/Service) seria adicionada aqui
  }

  // Função para simular a remoção de um cultivo (mantém a lógica do FloatingActionButton)
  void _removeCultivationAt(
    int index,
  ) {
    setState(
      () {
        _cultivations.removeAt(
          index,
        );
      },
    );
    // Lógica para persistir a mudança (API/Service) seria adicionada aqui
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
          'Histórico de Cultivo',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <
            Widget
          >[
            // Área de Filtros
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal:
                    16.0,
                vertical:
                    8.0,
              ),
              child: Row(
                children: <
                  Widget
                >[
                  Expanded(
                    child: DropdownButtonFormField<
                      String
                    >(
                      decoration: InputDecoration(
                        labelText:
                            'Ano',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal:
                              12,
                          vertical:
                              8,
                        ),
                      ),
                      initialValue:
                          _selectedYearFilter,
                      hint: const Text(
                        'Todos os Anos',
                      ),
                      onChanged: (
                        String? newValue,
                      ) {
                        setState(
                          () {
                            _selectedYearFilter =
                                newValue;
                          },
                        );
                      },
                      items: [
                        const DropdownMenuItem<
                          String
                        >(
                          value:
                              null,
                          child: Text(
                            'Todos os Anos',
                          ),
                        ),
                        ..._availableYears.map<
                          DropdownMenuItem<
                            String
                          >
                        >(
                          (
                            String value,
                          ) {
                            return DropdownMenuItem<
                              String
                            >(
                              value:
                                  value,
                              child: Text(
                                value,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width:
                        16,
                  ),
                  Expanded(
                    child: DropdownButtonFormField<
                      String
                    >(
                      decoration: InputDecoration(
                        labelText:
                            'Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal:
                              12,
                          vertical:
                              8,
                        ),
                      ),
                      initialValue:
                          _selectedStatusFilter,
                      hint: const Text(
                        'Todos os Status',
                      ),
                      onChanged: (
                        String? newValue,
                      ) {
                        setState(
                          () {
                            _selectedStatusFilter =
                                newValue;
                          },
                        );
                      },
                      items: [
                        const DropdownMenuItem<
                          String
                        >(
                          value:
                              null,
                          child: Text(
                            'Todos os Status',
                          ),
                        ),
                        ..._availableStatuses.map<
                          DropdownMenuItem<
                            String
                          >
                        >(
                          (
                            String value,
                          ) {
                            return DropdownMenuItem<
                              String
                            >(
                              value:
                                  value,
                              child: Text(
                                value,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height:
                  1,
            ), // Divisória abaixo dos filtros
            Expanded(
              child:
                  _filteredCultivations.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: <
                            Widget
                          >[
                            Icon(
                              Icons.eco_outlined, // Ícone de planta
                              size:
                                  80,
                              color: colorScheme.onSurface.withOpacity(
                                0.4,
                              ),
                            ),
                            const SizedBox(
                              height:
                                  16,
                            ),
                            Text(
                              'Nenhum cultivo encontrado!',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height:
                                  8,
                            ),
                            Text(
                              'Seu histórico de cultivos aparecerá aqui.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(
                                  0.5,
                                ),
                              ),
                              textAlign:
                                  TextAlign.center,
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(
                          12,
                        ),
                        itemCount:
                            _filteredCultivations.length,
                        itemBuilder: (
                          context,
                          i,
                        ) {
                          final item =
                              _filteredCultivations[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical:
                                  8.0,
                            ),
                            elevation:
                                Theme.of(
                                  context,
                                ).cardTheme.elevation,
                            shape:
                                Theme.of(
                                  context,
                                ).cardTheme.shape,
                            color:
                                Theme.of(
                                  context,
                                ).cardTheme.color,
                            child: InkWell(
                              onTap: () {
                                // Lógica para ver detalhes do cultivo
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Detalhes do cultivo: ${item.name}',
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  12.0,
                                ),
                                child: Row(
                                  children: <
                                    Widget
                                  >[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        8.0,
                                      ),
                                      child: Image.network(
                                        item.imageUrl,
                                        width:
                                            80,
                                        height:
                                            80,
                                        fit:
                                            BoxFit.cover,
                                        errorBuilder:
                                            (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => const Icon(
                                              Icons.broken_image,
                                              size:
                                                  80,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width:
                                          16,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <
                                          Widget
                                        >[
                                          Text(
                                            item.name,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium?.copyWith(
                                              fontWeight:
                                                  FontWeight.bold,
                                              color:
                                                  colorScheme.onSurface,
                                            ),
                                            maxLines:
                                                1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(
                                            height:
                                                4,
                                          ),
                                          Text(
                                            item.period,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall?.copyWith(
                                              color: colorScheme.onSurface.withOpacity(
                                                0.7,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height:
                                                4,
                                          ),
                                          Chip(
                                            label: Text(
                                              item.status,
                                            ),
                                            backgroundColor:
                                                item.status ==
                                                        'Ativo'
                                                    ? colorScheme.primary.withOpacity(
                                                      0.1,
                                                    )
                                                    : colorScheme.surfaceContainerHighest,
                                            labelStyle: Theme.of(
                                              context,
                                            ).textTheme.bodySmall?.copyWith(
                                              color:
                                                  item.status ==
                                                          'Ativo'
                                                      ? colorScheme.primary
                                                      : colorScheme.onSurface.withOpacity(
                                                        0.7,
                                                      ),
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  4,
                                              vertical:
                                                  0,
                                            ),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize.shrinkWrap,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Botão de detalhes (opcionalmente pode ser um IconButton)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size:
                                            18,
                                      ),
                                      color: colorScheme.onSurface.withOpacity(
                                        0.6,
                                      ),
                                      onPressed: () {
                                        // Lógica para navegação para tela de detalhes
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Navegar para detalhes de ${item.name}',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ctrl =
              TextEditingController();
          final result = await showDialog<
            String?
          >(
            context:
                context,
            builder:
                (
                  _,
                ) => AlertDialog(
                  title: const Text(
                    'Adicionar Cultivo',
                  ),
                  content: TextField(
                    controller:
                        ctrl,
                    decoration: InputDecoration(
                      hintText:
                          'Ex: Tomate Cereja',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal:
                            12,
                        vertical:
                            12,
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          () =>
                              Navigator.of(
                                context,
                              ).pop(),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(
                            0.6,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed:
                          () => Navigator.of(
                            context,
                          ).pop(
                            ctrl.text,
                          ),
                      child: const Text(
                        'Adicionar',
                      ),
                    ),
                  ],
                ),
          );
          if (result !=
                  null &&
              result.trim().isNotEmpty) {
            _addCultivation(
              result,
            ); // Chama o método para adicionar cultivo simulado
            // O SettingsService.addHistoryItem original pode ser integrado aqui, se necessário.
          }
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
