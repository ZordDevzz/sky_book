import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/screens/auth/auth_screen.dart';
import 'package:sky_book/screens/profile/settings_screen.dart';
import 'package:sky_book/screens/profile/profile_top_bar.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: ProfileTopBar(user: user, lang: lang),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileBackdrop(),
                  const SizedBox(height: 12),
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: user?.pfpUrl != null &&
                              user!.pfpUrl!.trim().isNotEmpty
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
                  const SizedBox(height: 24),
                  _ActionCard(
                    colorScheme: colorScheme,
                    child: Column(
                      children: [
                        _ActionButton(
                          icon: Icons.edit,
                          label: lang.t('edit_profile'),
                          onTap: user == null
                              ? null
                              : () => _showEditDialog(context, auth, lang),
                        ),
                        const SizedBox(height: 10),
                        _ActionButton(
                          icon: Icons.lock_reset,
                          label: lang.t('change_password'),
                          onTap: user == null
                              ? null
                              : () => _showChangePasswordDialog(
                                    context,
                                    auth,
                                    lang,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ActionCard(
                    colorScheme: colorScheme,
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.settings),
                          title: Text(lang.t('settings')),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const SettingsScreen()),
                            );
                          },
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(lang.t('dark_mode')),
                            Switch(
                              value: Provider.of<ThemeProvider>(context)
                                      .themeMode ==
                                  ThemeMode.dark,
                              onChanged: (value) {
                                Provider.of<ThemeProvider>(
                                  context,
                                  listen: false,
                                ).toggleTheme();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ActionCard(
                    colorScheme: colorScheme,
                    child: ElevatedButton(
                      onPressed: auth.isGuest
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const AuthScreen()),
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
                        auth.isGuest
                            ? lang.t('login_or_register')
                            : lang.t('logout'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

class _ProfileBackdrop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 80,
      child: Stack(
        children: [
          Positioned(
            top: -20,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            top: -10,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.secondary.withOpacity(0.08),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.child, required this.colorScheme});

  final Widget child;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.08),
            colorScheme.secondary.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
