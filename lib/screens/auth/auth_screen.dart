import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/services/auth_provider.dart';
import 'package:sky_book/services/language_provider.dart';
import 'package:sky_book/screens/auth/widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLogin = true;
  String? _localError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(color: Theme.of(context).colorScheme.surface),
          Positioned(
            top: -60,
            right: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final error = _localError ?? auth.errorMessage;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sky Book',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _isLogin
                                  ? lang.t('title_login')
                                  : lang.t('title_register'),
                              key: ValueKey(_isLogin),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.75),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceVariant.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    AuthTextField(
                                      controller: _usernameController,
                                      label: lang.t('username'),
                                      icon: Icons.person_outline,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return lang.t('username_validator');
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    AuthTextField(
                                      controller: _passwordController,
                                      label: lang.t('passw'),
                                      icon: Icons.lock_outline,
                                      obscure: true,
                                      validator: (value) {
                                        if (value == null || value.length < 6) {
                                          return lang.t('passw_validator');
                                        }
                                        return null;
                                      },
                                    ),
                                    if (!_isLogin) ...[
                                      const SizedBox(height: 12),
                                      AuthTextField(
                                        controller: _confirmPasswordController,
                                        label: lang.t('repeat_passw'),
                                        icon: Icons.lock_reset,
                                        obscure: true,
                                        validator: (value) {
                                          if (value !=
                                              _passwordController.text) {
                                            return lang.t(
                                              'repeat_passw_validator',
                                            );
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                    if (error != null) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        error,
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          foregroundColor: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        onPressed: auth.isLoading
                                            ? null
                                            : () => _submit(context, auth),
                                        child: auth.isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                        Colors.white,
                                                      ),
                                                ),
                                              )
                                            : Text(
                                                _isLogin
                                                    ? lang.t('login_btn')
                                                    : lang.t('register_btn'),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isLogin = !_isLogin;
                                          _localError = null;
                                        });
                                      },
                                      child: Text(
                                        _isLogin
                                            ? lang.t('no_account')
                                            : lang.t('has_account'),
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context, AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _localError = null);

    try {
      if (_isLogin) {
        await auth.login(
          _usernameController.text.trim(),
          _passwordController.text,
        );
      } else {
        await auth.register(
          _usernameController.text.trim(),
          _passwordController.text,
        );
      }
      if (mounted) {
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      setState(() {
        _localError = auth.errorMessage ?? e.toString();
      });
    }
  }
}
