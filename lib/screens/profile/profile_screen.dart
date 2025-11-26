import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/screens/auth/auth_screen.dart';
import 'package:sky_book/screens/profile/settings_screen.dart';
import 'package:sky_book/services/auth_provider.dart';
import 'package:sky_book/services/theme_provider.dart';
import 'package:sky_book/services/language_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
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
                backgroundImage:
                    user?.pfpUrl != null && user!.pfpUrl!.trim().isNotEmpty
                    ? AssetImage('assets/images/pfp/${user.pfpUrl!}')
                          as ImageProvider
                    : null,
                child: user?.pfpUrl == null || user!.pfpUrl!.trim().isEmpty
                    ? Text(
                        (user?.username ?? 'U').isNotEmpty
                            ? (user?.username ?? 'U')[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(fontSize: 36),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                user?.username ?? lang.t('guest'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (auth.isGuest) ...[
              const SizedBox(height: 8),
              Text(
                lang.t('guest_mode'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: Text(lang.t('edit_profile')),
              onPressed: user == null
                  ? null
                  : () => _showEditDialog(context, auth, lang),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.lock_reset),
              label: Text(lang.t('change_password')),
              onPressed: user == null
                  ? null
                  : () => _showChangePasswordDialog(context, auth, lang),
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
              onPressed: auth.isGuest
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                      );
                    }
                  : () async {
                      await auth.logout();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(lang.t('logout_toast')),
                            showCloseIcon: true,
                          ),
                        );
                      }
                    },
              child: Text(
                auth.isGuest ? lang.t('login_or_register') : lang.t('logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, AuthProvider auth, dynamic lang) {
    final nameController = TextEditingController(
      text: auth.currentUser?.username ?? '',
    );
    final avatarController = TextEditingController(
      text: auth.currentUser?.pfpUrl ?? '',
    );

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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(lang.t('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                await auth.updateProfile(
                  username: nameController.text.trim(),
                  pfpUrl: avatarController.text.trim().isEmpty
                      ? null
                      : avatarController.text.trim(),
                );
                if (auth.errorMessage != null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
                  return;
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: Text(lang.t('save')),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(
    BuildContext context,
    AuthProvider auth,
    dynamic lang,
  ) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(lang.t('change_password')),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: lang.t('current_password')),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? lang.t('current_password') : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: lang.t('new_password')),
                  validator: (v) {
                    if (v == null || v.length < 6) return lang.t('passw_validator');
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  decoration:
                      InputDecoration(labelText: lang.t('confirm_password')),
                  validator: (v) =>
                      v != newController.text ? lang.t('repeat_passw_validator') : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(lang.t('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                await auth.changePassword(
                  currentPassword: currentController.text,
                  newPassword: newController.text,
                );
                if (auth.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(auth.errorMessage!)),
                  );
                  return;
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(lang.t('password_changed'))),
                  );
                  Navigator.of(ctx).pop();
                }
              },
              child: Text(lang.t('save')),
            ),
          ],
        );
      },
    );
  }
}
