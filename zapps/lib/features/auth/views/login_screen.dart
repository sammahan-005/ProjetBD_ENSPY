import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zapps/features/auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final String phone;
  const LoginScreen({super.key, required this.phone});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pwdCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_pwdCtrl.text.isEmpty) return;
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService().login(widget.phone, _pwdCtrl.text);
      if (mounted) context.go('/conversations');
    } catch (e, stack) {
      print('LOGIN ERROR: $e');
      print('STACK TRACE: $stack');
      setState(() => _error = 'Numéro ou mot de passe incorrect. ($e)');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Connexion'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Content de vous revoir 👋',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Numéro: ${widget.phone}',
                style: const TextStyle(color: Color(0xFF9999BB)),
              ),
              const SizedBox(height: 32),
              // Mot de passe
              TextField(
                controller: _pwdCtrl,
                obscureText: _obscure,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF666680)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF666680),
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  errorText: _error,
                ),
                onSubmitted: (_) => _login(),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Se connecter'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
