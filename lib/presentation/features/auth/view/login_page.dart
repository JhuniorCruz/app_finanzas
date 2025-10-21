import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart'; // AppColors
import '../controller/auth_controller.dart'; // ← asegúrate de crearlo (ChangeNotifier)

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final _emailNode = FocusNode();
  final _passNode = FocusNode();

  bool _showPass = false;
  bool _remember = false;
  String? _generalError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailNode.dispose();
    _passNode.dispose();
    super.dispose();
  }

  // ===== Validadores internos (email o teléfono 9–11 dígitos aprox.)
  String? _validateEmailOrPhone(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'El email o teléfono es requerido';

    final emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    final digits = value.replaceAll(RegExp(r'\s+'), '');
    final phoneRe = RegExp(r'^\d{9,11}$'); // ajusta si quieres 10 fijo

    if (!emailRe.hasMatch(value) && !phoneRe.hasMatch(digits)) {
      return 'Ingresa un email o teléfono válido';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'La contraseña es requerida';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  Future<void> _submit() async {
    setState(() => _generalError = null);
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    try {
      await auth.login(email: email, password: pass, remember: _remember);
      if (!mounted) return;
      // Si prefieres navegar aquí en lugar del AuthGate:
      // Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      setState(() => _generalError = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isLoading = auth.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ======= Header con gradiente =======
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF7C6BF6), AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.auto_awesome, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _HeaderTexts(
                      title: 'Iniciar sesión',
                      subtitle: 'Accede a tu cuenta',
                    ),
                  ),
                ],
              ),
            ),

            // ======= Form =======
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_generalError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.destructive.withOpacity(.08),
                            border: Border.all(
                              color: AppColors.destructive.withOpacity(.25),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _generalError!,
                            style: const TextStyle(
                              color: AppColors.destructive,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Email / Teléfono
                      const Text('Email o teléfono'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailCtrl,
                        focusNode: _emailNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'ejemplo@correo.com o 5512345678',
                        ),
                        validator: _validateEmailOrPhone,
                        enabled: !isLoading,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_passNode),
                      ),
                      const SizedBox(height: 14),

                      // Password
                      const Text('Contraseña'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passCtrl,
                        focusNode: _passNode,
                        obscureText: !_showPass,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'Mínimo 6 caracteres',
                          suffixIcon: IconButton(
                            onPressed: isLoading
                                ? null
                                : () => setState(() => _showPass = !_showPass),
                            icon: Icon(
                              _showPass
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                            ),
                          ),
                        ),
                        validator: _validatePassword,
                        enabled: !isLoading,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 12),

                      // Remember + Forgot
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox.adaptive(
                                value: _remember,
                                onChanged: isLoading
                                    ? null
                                    : (v) => setState(
                                        () => _remember = v ?? false,
                                      ),
                              ),
                              const Text('Recordarme'),
                            ],
                          ),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.of(
                                    context,
                                  ).pushNamed('/forgot'),
                            child: const Text('Olvidé mi contraseña'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Botones primarios
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          child: Text(
                            isLoading
                                ? 'Iniciando sesión...'
                                : 'Iniciar sesión',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.of(
                                  context,
                                ).pushNamed('/register'),
                          child: const Text('Crear cuenta'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Divider
                      Row(
                        children: const [
                          Expanded(child: _Line()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'O continúa con',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          ),
                          Expanded(child: _Line()),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Social
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isLoading ? null : () {}, // TODO OAuth
                              icon: const Icon(Icons.g_translate),
                              label: const Text('Google'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isLoading ? null : () {}, // TODO OAuth
                              icon: const Icon(Icons.apple),
                              label: const Text('Apple'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      // Legal
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                          children: [
                            const TextSpan(
                              text: 'Al continuar, aceptas nuestros ',
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: InkWell(
                                onTap: () {
                                  // TODO navegar a términos
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 2),
                                  child: Text(
                                    'Términos de Servicio',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                      decorationThickness: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: ' y '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: InkWell(
                                onTap: () {
                                  // TODO navegar a privacidad
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 2),
                                  child: Text(
                                    'Política de Privacidad',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                      decorationThickness: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderTexts extends StatelessWidget {
  final String title;
  final String subtitle;
  const _HeaderTexts({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: const Color(0xFFE2E8F0));
  }
}
