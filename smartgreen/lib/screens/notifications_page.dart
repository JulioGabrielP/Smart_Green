import 'package:flutter/material.dart';
import 'package:smartgreen/theme/app_colors.dart'; // Importa AppColors para cores específicas

// Enum para representar os tipos de notificação
enum NotificationType {
  alert,
  info,
  success,
}

// Modelo de dados para uma notificação
class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead =
        false,
  });
}

class NotificationsPage
    extends
        StatefulWidget {
  const NotificationsPage({
    super.key,
  });

  @override
  State<
    NotificationsPage
  >
  createState() =>
      _NotificationsPageState();
}

class _NotificationsPageState
    extends
        State<
          NotificationsPage
        > {
  // Lista simulada de notificações para fins de UI
  final List<
    NotificationItem
  >
  _notifications = [
    NotificationItem(
      id:
          '1',
      type:
          NotificationType.alert,
      title:
          'Alerta de Umidade Baixa',
      message:
          'A umidade do vaso "Orquídea da Sala" está em 20%. Necessita de rega.',
      timestamp: DateTime.now().subtract(
        const Duration(
          hours:
              2,
        ),
      ),
      isRead:
          false,
    ),
    NotificationItem(
      id:
          '2',
      type:
          NotificationType.info,
      title:
          'Nova Funcionalidade Disponível',
      message:
          'Descubra agora o novo modo "Férias" para suas plantas!',
      timestamp: DateTime.now().subtract(
        const Duration(
          days:
              1,
        ),
      ),
      isRead:
          false,
    ),
    NotificationItem(
      id:
          '3',
      type:
          NotificationType.success,
      title:
          'Rega Registrada com Sucesso',
      message:
          'A rega da "Samambaia da Cozinha" foi registrada em 10:30 AM.',
      timestamp: DateTime.now().subtract(
        const Duration(
          minutes:
              45,
        ),
      ),
      isRead:
          true,
    ),
    NotificationItem(
      id:
          '4',
      type:
          NotificationType.alert,
      title:
          'Bateria do Sensor Baixa',
      message:
          'O sensor do vaso "Hortelã da Varanda" está com bateria fraca.',
      timestamp: DateTime.now().subtract(
        const Duration(
          days:
              3,
        ),
      ),
      isRead:
          false,
    ),
  ];

  void _markAsRead(
    String id,
  ) {
    setState(
      () {
        final index = _notifications.indexWhere(
          (
            notification,
          ) =>
              notification.id ==
              id,
        );
        if (index !=
            -1) {
          _notifications[index].isRead = true;
        }
      },
    );
    // Lógica para persistir a mudança (API/Service) seria adicionada aqui
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'Notificação marcada como lida.',
        ),
      ),
    );
  }

  void _deleteNotification(
    String id,
  ) {
    setState(
      () {
        _notifications.removeWhere(
          (
            notification,
          ) =>
              notification.id ==
              id,
        );
      },
    );
    // Lógica para persistir a mudança (API/Service) seria adicionada aqui
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'Notificação excluída.',
        ),
      ),
    );
  }

  // Retorna o ícone e a cor baseada no tipo de notificação
  Map<
    String,
    dynamic
  >
  _getNotificationStyle(
    BuildContext context,
    NotificationType type,
  ) {
    switch (type) {
      case NotificationType.alert:
        return {
          'icon':
              Icons.warning_rounded,
          'color':
              Theme.of(
                context,
              ).colorScheme.error, // Vermelho de erro do tema
        };
      case NotificationType.info:
        return {
          'icon':
              Icons.info_rounded,
          'color':
              Theme.of(
                context,
              ).colorScheme.tertiary, // Azul padronizado (AppColors.blue)
        };
      case NotificationType.success:
        return {
          'icon':
              Icons.check_circle_rounded,
          'color':
              AppColors.green, // Verde primário
        };
      default:
        return {
          'icon':
              Icons.notifications_rounded,
          'color':
              Theme.of(
                context,
              ).colorScheme.onSurface,
        };
    }
  }

  // Retorna o timestamp relativo (e.g., "há 2 horas")
  String _getRelativeTime(
    DateTime timestamp,
  ) {
    final Duration difference = DateTime.now().difference(
      timestamp,
    );
    if (difference.inMinutes <
        1) {
      return 'agora mesmo';
    } else if (difference.inHours <
        1) {
      return 'há ${difference.inMinutes} minutos';
    } else if (difference.inDays <
        1) {
      return 'há ${difference.inHours} horas';
    } else if (difference.inDays <
        7) {
      return 'há ${difference.inDays} dias';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
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
          'Notificações',
        ),
      ),
      body: SafeArea(
        child:
            _notifications.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: <
                      Widget
                    >[
                      Icon(
                        Icons.notifications_off_rounded,
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
                        'Nenhuma notificação por enquanto!',
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
                        'Todos os seus alertas e avisos aparecerão aqui.',
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
                : ListView.separated(
                  itemCount:
                      _notifications.length,
                  separatorBuilder:
                      (
                        BuildContext context,
                        int index,
                      ) => const Divider(
                        height:
                            1,
                        indent:
                            16,
                        endIndent:
                            16,
                      ),
                  itemBuilder: (
                    BuildContext context,
                    int index,
                  ) {
                    final NotificationItem notification =
                        _notifications[index];
                    final Map<
                      String,
                      dynamic
                    >
                    style = _getNotificationStyle(
                      context,
                      notification.type,
                    );
                    final IconData icon =
                        style['icon']
                            as IconData;
                    final Color iconColor =
                        style['color']
                            as Color;

                    return Dismissible(
                      key: Key(
                        notification.id,
                      ),
                      direction:
                          DismissDirection.horizontal,
                      background: Container(
                        color:
                            Colors.green.shade700,
                        alignment:
                            Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal:
                              20,
                        ),
                        child: const Icon(
                          Icons.check,
                          color:
                              Colors.white,
                        ),
                      ),
                      secondaryBackground: Container(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.error,
                        alignment:
                            Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(
                          horizontal:
                              20,
                        ),
                        child: const Icon(
                          Icons.delete,
                          color:
                              Colors.white,
                        ),
                      ),
                      onDismissed: (
                        DismissDirection direction,
                      ) {
                        if (direction ==
                            DismissDirection.startToEnd) {
                          _markAsRead(
                            notification.id,
                          );
                        } else {
                          _deleteNotification(
                            notification.id,
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal:
                              8,
                          vertical:
                              4,
                        ),
                        elevation:
                            0, // Card dentro da lista para evitar dupla elevação
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                        color:
                            notification.isRead
                                ? colorScheme.surfaceContainerHighest.withOpacity(
                                  0.5,
                                ) // Cor mais suave para lido
                                : Theme.of(
                                  context,
                                ).cardTheme.color, // Cor padrão do card do tema
                        child: Padding(
                          padding: const EdgeInsets.all(
                            12.0,
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: <
                              Widget
                            >[
                              Container(
                                padding: const EdgeInsets.all(
                                  8,
                                ),
                                decoration: BoxDecoration(
                                  color: iconColor.withOpacity(
                                    0.1,
                                  ),
                                  shape:
                                      BoxShape.circle,
                                ),
                                child: Icon(
                                  icon,
                                  color:
                                      iconColor,
                                  size:
                                      24,
                                ),
                              ),
                              const SizedBox(
                                width:
                                    12,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: <
                                    Widget
                                  >[
                                    Text(
                                      notification.title,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        fontWeight:
                                            notification.isRead
                                                ? FontWeight.normal
                                                : FontWeight.bold,
                                        color:
                                            colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(
                                      height:
                                          4,
                                    ),
                                    Text(
                                      notification.message,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurface.withOpacity(
                                          0.7,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height:
                                          8,
                                    ),
                                    Align(
                                      alignment:
                                          Alignment.bottomRight,
                                      child: Text(
                                        _getRelativeTime(
                                          notification.timestamp,
                                        ),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurface.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
