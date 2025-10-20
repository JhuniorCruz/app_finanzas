import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/user_profile.dart';
import '../../settings/controller/settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loaded = false;

  // Perfil
  final _nameCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController(text: 'PEN');

  // Parámetros educativos (UI informativa – no altera lógica existente)
  double _savingsTarget = 20; // %
  double _dtiThreshold = 30; // %
  double _utilizationThreshold = 50; // %
  bool _reminders = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    Future.microtask(() async {
      final vm = context.read<SettingsController>();
      await vm.load();
      final p = vm.profile ?? const UserProfile(name: '', currency: 'PEN');
      _nameCtrl.text = p.name;
      _currencyCtrl.text = p.currency.isEmpty ? 'PEN' : p.currency;

      // Si en tu app original estos valores se guardaban, puedes leerlos aquí
      // desde SharedPreferences o el controller. Por defecto dejamos los
      // valores UI por compatibilidad visual.
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _currencyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ------------ Perfil ------------
          _SectionCard(
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _currencyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Moneda (ej. PEN)',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ------------ Parámetros educativos ------------
          Text(
            'Parámetros educativos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _SectionCard(
            children: [
              _SliderRow(
                label: 'Meta de ahorro',
                value: _savingsTarget,
                suffix: '%',
                onChanged: (v) => setState(() => _savingsTarget = v),
              ),
              const SizedBox(height: 12),
              _SliderRow(
                label: 'Deuda/Ingreso máx.',
                value: _dtiThreshold,
                suffix: '%',
                onChanged: (v) => setState(() => _dtiThreshold = v),
              ),
              const SizedBox(height: 12),
              _SliderRow(
                label: 'Utilización de tarjeta',
                value: _utilizationThreshold,
                suffix: '%',
                onChanged: (v) => setState(() => _utilizationThreshold = v),
              ),
              const SizedBox(height: 4),
              const _Hint(
                text:
                    'Estos parámetros te ayudan a interpretar los indicadores.\nNo reemplazan políticas oficiales de entidades financieras.',
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Recordatorios'),
                contentPadding: EdgeInsets.zero,
                value: _reminders,
                onChanged: (v) => setState(() => _reminders = v),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),

      // ------------ Botón Guardar (perfil) ------------
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_outlined),
              label: vm.loading
                  ? const Text('Guardando...')
                  : const Text('Guardar'),
              onPressed: vm.loading
                  ? null
                  : () async {
                      final profile = UserProfile(
                        name: _nameCtrl.text.trim(),
                        currency: _currencyCtrl.text.trim().isEmpty
                            ? 'PEN'
                            : _currencyCtrl.text.trim(),
                      );

                      await context.read<SettingsController>().save(profile);

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ajustes guardados')),
                      );

                      // Si en tu app original estos valores se persistían, aquí
                      // podrías llamar a un método del controller para guardarlos
                      // sin alterar la funcionalidad actual.
                    },
            ),
          ),
        ),
      ),
    );
  }
}

// ================== Widgets de UI (idénticos al estilo original) ==================

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final String suffix;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          '${value.toStringAsFixed(0)}$suffix',
          style: const TextStyle(color: Color(0xFF475569)),
        ),
        SizedBox(
          width: 180,
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 100,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        border: Border.all(color: const Color(0xFFFFE3A3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFFB45309))),
    );
  }
}
