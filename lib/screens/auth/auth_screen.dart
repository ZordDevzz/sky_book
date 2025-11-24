import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sky_book/services/auth_provider.dart';
import 'package:sky_book/services/language_provider.dart';

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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final error = _localError ?? auth.errorMessage;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _isLogin
                                ? lang.t('title_login')
                                : lang.t('title_register'),
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    labelText: lang.t('username'),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return lang.t('username_validator');
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: lang.t('passw'),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.length < 6) {
                                      return lang.t('passw_validator');
                                    }
                                    return null;
                                  },
                                ),
                                if (!_isLogin) ...[
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: lang.t('repeat_passw'),
                                    ),
                                    validator: (value) {
                                      if (value != _passwordController.text) {
                                        return lang.t('repeat_passw_validator');
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
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
                          ElevatedButton(
                            onPressed: auth.isLoading
                                ? null
                                : () => _submit(context, auth),
                            child: auth.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _isLogin
                                        ? lang.t('login_btn')
                                        : lang.t('register_btn'),
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
        ),
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
