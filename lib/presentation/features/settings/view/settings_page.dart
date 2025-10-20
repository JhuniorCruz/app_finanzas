import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/user_profile.dart';
import '../../settings/controller/settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loaded = false;

  final nameCtrl = TextEditingController();
  final currencyCtrl = TextEditingController(text: 'PEN');

  double savingsTarget = 20;
  double dtiThreshold = 30;
  double utilizationThreshold = 50;
  bool reminders = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      Future.microtask(() async {
        final vm = context.read<SettingsController>();
        await vm.load();
        final p = vm.profile ?? const UserProfile(name: '', currency: 'PEN');
        nameCtrl.text = p.name;
        currencyCtrl.text = p.currency;
      });
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    currencyCtrl.dispose();
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
          _sectionCard(
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: currencyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Moneda (ej. PEN)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'Parámetros educativos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _sectionCard(
            children: [
              _sliderRow(
                'Meta de ahorro',
                savingsTarget,
                (v) => setState(() => savingsTarget = v),
              ),
              _sliderRow(
                'Deuda/Ingreso máx.',
                dtiThreshold,
                (v) => setState(() => dtiThreshold = v),
              ),
              _sliderRow(
                'Utilización de tarjeta',
                utilizationThreshold,
                (v) => setState(() => utilizationThreshold = v),
              ),
              SwitchListTile(
                title: const Text('Recordatorios'),
                value: reminders,
                onChanged: (v) => setState(() => reminders = v),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save_outlined),
            label: vm.loading
                ? const Text('Guardando...')
                : const Text('Guardar'),
            onPressed: vm.loading
                ? null
                : () async {
                    final p = UserProfile(
                      name: nameCtrl.text.trim(),
                      currency: currencyCtrl.text.trim().isEmpty
                          ? 'PEN'
                          : currencyCtrl.text.trim(),
                    );
                    await context.read<SettingsController>().save(p);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ajustes guardados')),
                      );
                    }
                  },
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
    ),
    child: Column(children: _space(children)),
  );

  List<Widget> _space(List<Widget> items) {
    final spaced = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      spaced.add(items[i]);
      if (i != items.length - 1) spaced.add(const SizedBox(height: 12));
    }
    return spaced;
  }

  Widget _sliderRow(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          '${value.toStringAsFixed(0)}%',
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
