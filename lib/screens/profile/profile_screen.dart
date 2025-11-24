import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/screens/profile/profile_provider.dart';
import 'package:sky_book/screens/profile/settings_screen.dart';
import 'package:sky_book/theme/theme_provider.dart';
import 'package:sky_book/theme/language_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(lang.t('profile')), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundImage: profile.pfpUrl != null
                    ? NetworkImage(profile.pfpUrl!)
                    : null,
                child: profile.pfpUrl == null
                    ? Text(
                        profile.name.isNotEmpty
                            ? profile.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(fontSize: 36),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                profile.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: Text(lang.t('edit_profile')),
              onPressed: () => _showEditDialog(context, profile, lang),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.settings),
              title: Text(lang.t('settings')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.brightness_6),
              title: Text(lang.t('dark_mode')),
              trailing: Switch(
                value:
                    Provider.of<ThemeProvider>(context).themeMode ==
                    ThemeMode.dark,
                onChanged: (value) {
                  Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  ).toggleTheme();
                },
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Hẹn gặp lại !'),
                    showCloseIcon: true,
                  ),
                );
              },
              child: Text(lang.t('logout')),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    ProfileProvider profile,
    dynamic lang,
  ) {
    final nameController = TextEditingController(text: profile.name);
    final avatarController = TextEditingController(text: profile.pfpUrl ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(lang.t('edit_profile')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: lang.t('name'),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: avatarController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: lang.t('avatar'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(lang.t('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                await profile.saveProfile(
                  username: nameController.text.trim(),
                  pfpUrl: avatarController.text.trim().isEmpty
                      ? null
                      : avatarController.text.trim(),
                );
                Navigator.of(ctx).pop();
              },
              child: Text(lang.t('save')),
            ),
          ],
        );
      },
    );
  }
}
