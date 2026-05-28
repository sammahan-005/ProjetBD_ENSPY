import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zapps/features/auth/auth_service.dart';

class SignupScreen extends StatefulWidget {
  final String phone;
  const SignupScreen({super.key, required this.phone});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nomCtrl = TextEditingController();
  final _pseudoCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _pseudoCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _pseudoCtrl.text.trim().isNotEmpty && _pwdCtrl.text.length >= 6;

  Future<void> _signup() async {
    if (!_isValid) return;
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService().signup(
        phone: widget.phone,
        pseudo: _pseudoCtrl.text.trim(),
        password: _pwdCtrl.text,
        nom: _nomCtrl.text.trim().isEmpty ? null : _nomCtrl.text.trim(),
      );
      if (mounted) context.go('/conversations');
    } catch (e, stack) {
      print('SIGNUP ERROR: $e');
      print('STACK TRACE: $stack');
      setState(() => _error = 'Une erreur est survenue : $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Créer un compte'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Bienvenue ! 🎉',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Numéro: ${widget.phone} — Configurez votre profil',
                style: const TextStyle(color: Color(0xFF9999BB)),
              ),
              const SizedBox(height: 32),

              // Nom (optionnel)
              TextField(
                controller: _nomCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Nom complet (optionnel)',
                  prefixIcon: Icon(Icons.person_outline, color: Color(0xFF666680)),
                ),
              ),
              const SizedBox(height: 16),

              // Pseudo (requis)
              TextField(
                controller: _pseudoCtrl,
                decoration: const InputDecoration(
                  hintText: 'Nom d\'utilisateur (pseudo) *',
                  prefixIcon: Icon(Icons.alternate_email, color: Color(0xFF666680)),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Unique, sans espaces',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: const Color(0xFF666680)),
                ),
              ),
              const SizedBox(height: 16),

              // Mot de passe
              TextField(
                controller: _pwdCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Mot de passe (min 6 caractères) *',
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF666680)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF666680),
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _signup(),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCF6679).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(color: Color(0xFFCF6679))),
                ),
              ],

              const SizedBox(height: 32),
              AnimatedOpacity(
                opacity: _isValid ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: _isValid && !_loading ? _signup : null,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Créer mon compte'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
