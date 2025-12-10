import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../globals.dart'; // Mantém o import para getUserData
import '../services/settings_service.dart';
import 'package:smartgreen/theme/app_colors.dart'; // Importa AppColors

class ProfilePage
    extends
        StatelessWidget {
  const ProfilePage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final user =
        getUserData(); // Mock de dados do usuário
    final settings = Provider.of<
      SettingsService
    >(
      context,
    );
    final colorScheme =
        Theme.of(
          context,
        ).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(
            16,
          ),
          children: [
            // Seção de Avatar e Informações do Usuário
            Card(
              margin: const EdgeInsets.only(
                bottom:
                    24,
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
              child: Padding(
                padding: const EdgeInsets.all(
                  16.0,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius:
                          40,
                      backgroundColor:
                          colorScheme.primary,
                      child:
                          user !=
                                      null &&
                                  user.name.isNotEmpty
                              ? Text(
                                user.name
                                    .trim()
                                    .split(
                                      ' ',
                                    )
                                    .map(
                                      (
                                        s,
                                      ) =>
                                          s.isNotEmpty
                                              ? s[0]
                                              : '',
                                    )
                                    .take(
                                      2,
                                    )
                                    .join(),
                                style: const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize:
                                      24,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              )
                              : const Icon(
                                Icons.account_circle_rounded,
                                size:
                                    48,
                                color:
                                    Colors.white,
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
                        children: [
                          Text(
                            user?.name ??
                                'Usuário Smart Green',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height:
                                4,
                          ),
                          Text(
                            user?.email ??
                                'usuario@smartgreen.com',
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
                                4,
                          ),
                          Text(
                            user?.address ??
                                'Rua das Flores, 123 - Jardim Botânico',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(
                                0.6,
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

            // Seção de Configurações
            Text(
              'Configurações',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(
                fontWeight:
                    FontWeight.bold,
                color:
                    colorScheme.primary,
              ),
            ),
            const SizedBox(
              height:
                  8,
            ),
            Card(
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
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Notificações',
                    ),
                    value:
                        settings.notificationsEnabled,
                    onChanged:
                        (
                          v,
                        ) => settings.setNotificationsEnabled(
                          v,
                        ),
                    activeThumbColor:
                        colorScheme.primary,
                  ),
                  const Divider(
                    indent:
                        16,
                    endIndent:
                        16,
                    height:
                        1,
                  ),
                  ListTile(
                    title: const Text(
                      'Tema',
                    ),
                    subtitle: Text(
                      settings.themeMode ==
                              'light'
                          ? 'Claro'
                          : settings.themeMode ==
                              'dark'
                          ? 'Escuro'
                          : 'Sistema',
                    ),
                    trailing: DropdownButton<
                      String
                    >(
                      value:
                          settings.themeMode,
                      items: const [
                        DropdownMenuItem(
                          value:
                              'light',
                          child: Text(
                            'Claro',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                              'dark',
                          child: Text(
                            'Escuro',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                              'system',
                          child: Text(
                            'Sistema',
                          ),
                        ),
                      ],
                      onChanged: (
                        val,
                      ) {
                        if (val !=
                            null)
                          settings.setThemeMode(
                            val,
                          );
                      },
                      underline:
                          const SizedBox.shrink(), // Remove a linha padrão do Dropdown
                    ),
                  ),
                  const Divider(
                    indent:
                        16,
                    endIndent:
                        16,
                    height:
                        1,
                  ),
                  ListTile(
                    title: const Text(
                      'Idioma',
                    ),
                    subtitle: Text(
                      settings.language ==
                              'pt'
                          ? 'Português'
                          : 'English',
                    ),
                    trailing: DropdownButton<
                      String
                    >(
                      value:
                          settings.language,
                      items: const [
                        DropdownMenuItem(
                          value:
                              'pt',
                          child: Text(
                            'Português',
                          ),
                        ),
                        DropdownMenuItem(
                          value:
                              'en',
                          child: Text(
                            'English',
                          ),
                        ),
                      ],
                      onChanged: (
                        val,
                      ) {
                        if (val !=
                            null)
                          settings.setLanguage(
                            val,
                          );
                      },
                      underline:
                          const SizedBox.shrink(), // Remove a linha padrão do Dropdown
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height:
                  24,
            ),

            // Seção de Ações
            Text(
              'Outras Opções',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(
                fontWeight:
                    FontWeight.bold,
                color:
                    colorScheme.primary,
              ),
            ),
            const SizedBox(
              height:
                  8,
            ),
            Card(
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
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.history_rounded,
                      color: colorScheme.onSurface.withOpacity(
                        0.7,
                      ),
                    ),
                    title: const Text(
                      'Histórico de cultivo',
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurface.withOpacity(
                        0.5,
                      ),
                    ),
                    onTap:
                        () => Navigator.of(
                          context,
                        ).pushNamed(
                          '/history',
                        ),
                  ),
                  const Divider(
                    indent:
                        16,
                    endIndent:
                        16,
                    height:
                        1,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.info_outline_rounded,
                      color: colorScheme.onSurface.withOpacity(
                        0.7,
                      ),
                    ),
                    title: const Text(
                      'Sobre o Smart Green',
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurface.withOpacity(
                        0.5,
                      ),
                    ),
                    onTap: () {
                      // Simular navegação para uma página "Sobre"
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Navegar para a página "Sobre"',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(
              height:
                  24,
            ),

            // Botão de Logout Estilizado
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    colorScheme.error, // Cor vermelha para indicar ação de cuidado
                foregroundColor:
                    colorScheme.onError, // Texto branco para contraste
                padding: const EdgeInsets.symmetric(
                  vertical:
                      14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                elevation:
                    3,
              ),
              onPressed: () {
                // Lógica de logout simulada
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Realizando logout...',
                    ),
                  ),
                );
                // Exemplo: Navigator.of(context).pushReplacementNamed('/login');
              },
              icon: const Icon(
                Icons.logout_rounded,
              ),
              label: const Text(
                'Sair da conta',
                style: TextStyle(
                  fontSize:
                      16,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
