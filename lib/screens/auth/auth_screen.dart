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
                            _isLogin ? 'Đăng nhập' : 'Tạo tài khoản',
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
                                    labelText: lang.t('name'),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Nhập tên đăng nhập';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Mật khẩu',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.length < 6) {
                                      return 'Mật khẩu tối thiểu 6 ký tự';
                                    }
                                    return null;
                                  },
                                ),
                                if (!_isLogin) ...[
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Nhập lại mật khẩu',
                                    ),
                                    validator: (value) {
                                      if (value != _passwordController.text) {
                                        return 'Mật khẩu không khớp';
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
                                : Text(_isLogin ? 'Đăng nhập' : 'Đăng ký'),
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
                                  ? 'Chưa có tài khoản? Đăng ký'
                                  : 'Đã có tài khoản? Đăng nhập',
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
    } catch (e) {
      setState(() {
        _localError = auth.errorMessage ?? e.toString();
      });
    }
  }
}
