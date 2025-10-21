import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart'; // AppColors
import '../controller/auth_controller.dart'; // Debe exponer register(...)

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _nameNode = FocusNode();
  final _emailNode = FocusNode();
  final _passNode = FocusNode();
  final _confirmNode = FocusNode();

  bool _showPass = false;
  bool _showConfirm = false;
  bool _acceptTerms = false;

  String? _generalError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _nameNode.dispose();
    _emailNode.dispose();
    _passNode.dispose();
    _confirmNode.dispose();
    super.dispose();
  }

  // ==================== Validaciones ====================
  String? _validateName(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'El nombre es requerido';
    if (s.length < 2) return 'Mínimo 2 caracteres';
    return null;
  }

  String? _validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'El email es requerido';
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!re.hasMatch(s)) return 'Ingresa un email válido';
    return null;
  }

  String? _validatePassword(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'La contraseña es requerida';
    if (s.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(s))
      return 'Debe incluir al menos una mayúscula';
    if (!RegExp(r'[0-9]').hasMatch(s)) return 'Debe incluir al menos un número';
    return null;
  }

  String? _validateConfirm(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Confirma tu contraseña';
    if (s != _passCtrl.text) return 'Las contraseñas no coinciden';
    return null;
  }

  // Fuerza/etiqueta de contraseña (visual)
  ({double pct, String label, Color color}) _passwordStrength(String s) {
    if (s.isEmpty) return (pct: 0, label: '', color: Colors.transparent);
    int score = 0;
    if (s.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(s)) score++;
    if (RegExp(r'[a-z]').hasMatch(s)) score++;
    if (RegExp(r'[0-9]').hasMatch(s)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(s)) score++;

    if (score <= 2) {
      return (pct: 0.33, label: 'Débil', color: AppColors.destructive);
    } else if (score <= 3) {
      return (
        pct: 0.66,
        label: 'Media',
        color: const Color(0xFFF59E0B),
      ); // amber
    } else {
      return (pct: 1.0, label: 'Fuerte', color: AppColors.accent);
    }
  }

  Future<void> _submit() async {
    setState(() => _generalError = null);

    if (!_acceptTerms) {
      setState(() => _generalError = 'Debes aceptar los términos');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    try {
      await auth.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      // Puedes volver al login o ir directo al app:
      // Navigator.of(context).pop(); // volver al login
      // o Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      setState(() => _generalError = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isLoading = auth.isLoading;

    final strength = _passwordStrength(_passCtrl.text);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ========= Header =========
            Container(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 20),
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
                children: [
                  IconButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crear cuenta',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Únete y toma control financiero',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ========= Form =========
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

                      const Text('Nombre completo'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameCtrl,
                        focusNode: _nameNode,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Juan Pérez',
                        ),
                        validator: _validateName,
                        enabled: !isLoading,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_emailNode),
                      ),
                      const SizedBox(height: 14),

                      const Text('Email'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailCtrl,
                        focusNode: _emailNode,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'ejemplo@correo.com',
                        ),
                        validator: _validateEmail,
                        enabled: !isLoading,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_passNode),
                      ),
                      const SizedBox(height: 14),

                      const Text('Contraseña'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passCtrl,
                        focusNode: _passNode,
                        obscureText: !_showPass,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Mínimo 8 caracteres',
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
                        onChanged: (_) => setState(() {}),
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_confirmNode),
                      ),
                      const SizedBox(height: 8),
                      if (_passCtrl.text.isNotEmpty)
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: strength.pct,
                                  minHeight: 6,
                                  color: strength.color,
                                  backgroundColor: const Color(0xFFE2E8F0),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              strength.label,
                              style: TextStyle(
                                fontSize: 12,
                                color: strength.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 14),

                      const Text('Confirmar contraseña'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _confirmCtrl,
                        focusNode: _confirmNode,
                        obscureText: !_showConfirm,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'Repite tu contraseña',
                          suffixIcon: IconButton(
                            onPressed: isLoading
                                ? null
                                : () => setState(
                                    () => _showConfirm = !_showConfirm,
                                  ),
                            icon: Icon(
                              _showConfirm
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                            ),
                          ),
                        ),
                        validator: _validateConfirm,
                        enabled: !isLoading,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      if (_confirmCtrl.text.isNotEmpty &&
                          _confirmCtrl.text == _passCtrl.text)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            '✓ Las contraseñas coinciden',
                            style: TextStyle(color: AppColors.accent),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Términos
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox.adaptive(
                            value: _acceptTerms,
                            onChanged: isLoading
                                ? null
                                : (v) {
                                    setState(() {
                                      _acceptTerms = v ?? false;
                                      _generalError = null;
                                    });
                                  },
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.foreground,
                                ),
                                children: [
                                  const TextSpan(text: 'Acepto los '),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: InkWell(
                                      onTap: () {
                                        // TODO: navegar a términos
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          'Términos de Servicio',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            decoration:
                                                TextDecoration.underline,
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
                                        // TODO: navegar a privacidad
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          'Política de Privacidad',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationThickness: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Botón enviar
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          child: Text(
                            isLoading ? 'Creando cuenta...' : 'Crear cuenta',
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Volver a login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '¿Ya tienes cuenta? ',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Text('Inicia sesión'),
                          ),
                        ],
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
