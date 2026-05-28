import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:zapps/features/auth/auth_service.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid => _controller.text.length == 6 &&
      RegExp(r'^\d{6}$').hasMatch(_controller.text);

  Future<void> _continue() async {
    if (!_isValid) return;
    setState(() { _loading = true; _error = null; });

    try {
      final exists = await AuthService().checkPhone(_controller.text);
      if (!mounted) return;
      if (exists) {
        context.push('/auth/login', extra: _controller.text);
      } else {
        context.push('/auth/signup', extra: _controller.text);
      }
    } catch (e) {
      setState(() => _error = 'Erreur réseau. Réessayez.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Logo compact
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF03DAC6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.chat_bubble_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 32),
              Text(
                'Bienvenue sur Zapps',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Entrez votre numéro Zapps à 6 chiffres pour continuer.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: const Color(0xFF9999BB)),
              ),
              const SizedBox(height: 40),
              // Champ numéro
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 10,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••••',
                  hintStyle: TextStyle(
                    fontSize: 28,
                    letterSpacing: 10,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  errorText: _error,
                ),
                onChanged: (_) => setState(() => _error = null),
                onSubmitted: (_) => _continue(),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '6 chiffres uniquement',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: const Color(0xFF666680)),
                ),
              ),
              const Spacer(),
              AnimatedOpacity(
                opacity: _isValid ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: _isValid && !_loading ? _continue : null,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Continuer'),
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
