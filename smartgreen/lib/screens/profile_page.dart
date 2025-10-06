import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../globals.dart';
import '../services/settings_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
  final user = getUserData();
    final settings = Provider.of<SettingsService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: user != null && user.name.isNotEmpty
                    ? Text(
                        user.name.trim().split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join(),
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                      )
                    : const Icon(Icons.account_circle, size: 36, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Usuário',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(user?.email ?? '', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text('Configurações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Notificações'),
            value: settings.notificationsEnabled,
            onChanged: (v) => settings.setNotificationsEnabled(v),
          ),

          ListTile(
            title: const Text('Tema'),
            subtitle: Text(settings.themeMode),
            trailing: DropdownButton<String>(
              value: settings.themeMode,
              items: const [
                DropdownMenuItem(value: 'light', child: Text('Claro')),
                DropdownMenuItem(value: 'dark', child: Text('Escuro')),
                DropdownMenuItem(value: 'system', child: Text('Sistema')),
              ],
              onChanged: (val) {
                if (val != null) settings.setThemeMode(val);
              },
            ),
          ),

          ListTile(
            title: const Text('Idioma'),
            subtitle: Text(settings.language),
            trailing: DropdownButton<String>(
              value: settings.language,
              items: const [
                DropdownMenuItem(value: 'pt', child: Text('Português')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (val) {
                if (val != null) settings.setLanguage(val);
              },
            ),
          ),

          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Histórico de cultivo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushNamed('/history'),
          ),
        ],
      ),
    );
  }
}
