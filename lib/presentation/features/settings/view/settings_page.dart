import 'package:app_finanzas/presentation/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../transactions/controller/transactions_controller.dart';
import '../controller/settings_controller.dart';
import '../../../../domain/entities/user_profile.dart'; // entidad del perfil

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Estado editable
  double _savings = 10;
  double _dti = 40;
  double _util = 50;
  bool _reminders = false; // estado local (UI)

  @override
  void initState() {
    super.initState();
    final p = context.read<SettingsController>().profile;
    // si no hay perfil aún, usa defaults razonables
    _savings = p?.savingsTarget ?? 10;
    _dti = p?.debtToIncomeThreshold ?? 40;
    _util = p?.utilizationThreshold ?? 50;
    _reminders = p?.reminders ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700, // negrita
          fontFamily: 'Inter', // tu tipo de letra
          color: Color.fromRGBO(48, 50, 191, 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Header(
            title: 'Ajustes',
            subtitle: 'Personaliza tu experiencia',
          ),
          const SizedBox(height: 16),

          // ---------- Parámetros educativos ----------
          const _SectionTitle('Parámetros educativos'),
          _NumberSetting(
            label: 'Meta de ahorro (%)',
            value: _savings,
            onChanged: (v) => setState(() => _savings = v.clamp(0, 100)),
          ),
          _NumberSetting(
            label: 'Umbral deuda/ingreso (%)',
            value: _dti,
            onChanged: (v) => setState(() => _dti = v.clamp(0, 100)),
          ),
          _NumberSetting(
            label: 'Umbral de utilización (%)',
            value: _util,
            onChanged: (v) => setState(() => _util = v.clamp(0, 100)),
          ),

          const SizedBox(height: 12),

          // ---------- Notificaciones ----------
          const _SectionTitle('Notificaciones'),
          _Card(
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('Recordatorios de vencimientos')),
                Switch(
                  value: _reminders,
                  onChanged: (v) => setState(() => _reminders = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ---------- Datos ----------
          const _SectionTitle('Datos'),
          _Card(
            onTap: () => _exportCsv(context),
            child: Row(
              children: const [
                Icon(Icons.download_outlined, color: AppColors.foreground),
                SizedBox(width: 12),
                Text('Exportar CSV'),
                Spacer(),
                Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const _InfoCard(
            icon: Icons.info_outline_rounded,
            text:
                'Datos locales\nTodos tus datos se almacenan solo en este dispositivo. No se sincronizan con la nube.',
          ),

          const SizedBox(height: 12),

          // ---------- Borrar datos ----------
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.destructive,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _confirmClear(context),
              child: const Text('Borrar todos los datos'),
            ),
          ),

          const SizedBox(height: 16),

          // ---------- Guardar ----------
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Guardar cambios'),
            ),
          ),

          const SizedBox(height: 24),

          const _SectionTitle('Cuenta'),
          _Card(
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar sesión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.destructive,
                  side: const BorderSide(color: AppColors.destructive),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Cerrar sesión'),
                      content: const Text(
                        '¿Seguro que quieres cerrar tu sesión?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  );
                  if (ok != true) return;
                  await context.read<AuthController>().logout();
                  // No hace falta navegar manualmente: AppRouter detecta isLoggedIn=false
                },
              ),
            ),
          ),

          // ---------- Acerca de ----------
          const _SectionTitle('Acerca de'),
          const _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Versión: 1.0.0 MVP',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 6),
                Text(
                  'Esta aplicación es una herramienta educativa de gestión financiera.',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------- Acciones ---------

  void _saveChanges() {
    final current = context.read<SettingsController>().profile;

    final newProfile = UserProfile(
      incomeType: current?.incomeType ?? 'mensual', // conserva/da default
      savingsTarget: _savings,
      debtToIncomeThreshold: _dti,
      utilizationThreshold: _util,
      reminders: _reminders,
    );

    context.read<SettingsController>().updateProfile(newProfile);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Ajustes guardados')));
  }

  Future<void> _exportCsv(BuildContext context) async {
    final txs = context.read<TransactionsController>().items;

    final buf = StringBuffer()..writeln('type,date,amount,category,note');
    for (final t in txs) {
      buf.writeln(
        [
          t.type,
          formatDate(t.date),
          t.amount.toStringAsFixed(2),
          t.category,
          t.note?.replaceAll(',', ';') ?? '',
        ].join(','),
      );
    }

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exportar CSV'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(child: Text(buf.toString())),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar datos'),
        content: const Text(
          '¿Seguro que quieres borrar todos los datos? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    // Si agregas métodos en tus controllers/repos:
    // await context.read<TransactionsController>().clearAll();
    // await context.read<DebtsController>().clearAll();
    // await context.read<SettingsController>().resetDefaults();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Datos borrados (simulado).')));
  }
}

// ================== Widgets de la pantalla ==================

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF7C6BF6), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _Card({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
    return onTap == null
        ? content
        : InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: content,
          );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _NumberSetting extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  const _NumberSetting({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_rounded),
                onPressed: () => onChanged(value - 1),
              ),
              Expanded(
                child: Slider(
                  value: value.clamp(0, 100),
                  min: 0,
                  max: 100,
                  onChanged: onChanged,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => onChanged(value + 1),
              ),
              const SizedBox(width: 8),
              Text(
                '${value.toStringAsFixed(0)} %',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
