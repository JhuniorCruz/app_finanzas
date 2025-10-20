import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../debts/controller/debts_controller.dart';

class DebtDetailPage extends StatelessWidget {
  final String debtId;
  const DebtDetailPage({super.key, required this.debtId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DebtsController>();
    final d = vm.items.firstWhere((e) => e.id == debtId);

    final dpd = _daysPastDue(d.dueDate);
    final onTime = dpd <= 0;
    final utilPct = (d.creditLimit != null && d.creditLimit! > 0)
        ? (d.totalDebt / d.creditLimit! * 100)
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(d.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== CABECERA =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: d.creditLimit != null
                      ? const Color(0xFFE0ECFF)
                      : const Color(0xFFFDE68A),
                  child: Icon(
                    d.creditLimit != null
                        ? Icons.credit_card
                        : Icons.account_balance,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saldo total',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatCurrency(d.totalDebt),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusPill(onTime: onTime, dpd: dpd),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ===== FILAS DE INFORMACIÓN =====
          _InfoRow(label: 'Cuota mensual', value: formatCurrency(d.amount)),
          _InfoRow(label: 'Vencimiento', value: formatDate(d.dueDate)),
          _InfoRow(
            label: 'Estado',
            value: onTime ? 'A tiempo' : 'Atraso ($dpd días)',
          ),
          _InfoRow(label: 'Saldo total', value: formatCurrency(d.totalDebt)),
          if (d.creditLimit != null)
            _InfoRow(label: 'Línea', value: formatCurrency(d.creditLimit!)),
          if (utilPct != null)
            _InfoRow(
              label: 'Utilización',
              value: '${utilPct.toStringAsFixed(1)} %',
            ),

          const SizedBox(height: 24),
        ],
      ),

      // ===== BOTÓN FIJO =====
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Marcar como pagada'),
            onPressed: d.paid
                ? null
                : () async {
                    await context.read<DebtsController>().markAsPaid(d.id);
                    if (context.mounted) Navigator.pop(context);
                  },
          ),
        ),
      ),
    );
  }

  int _daysPastDue(DateTime due) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dd = DateTime(due.year, due.month, due.day);
    final diff = today.difference(dd).inDays;
    return diff > 0 ? diff : 0;
  }
}

// =================== UI helpers (idénticos al estilo original) ===================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool onTime;
  final int dpd;
  const _StatusPill({required this.onTime, required this.dpd});

  @override
  Widget build(BuildContext context) {
    final pillBg = onTime ? const Color(0xFFEFFDF5) : const Color(0xFFFFEBEE);
    final pillFg = onTime ? const Color(0xFF047857) : const Color(0xFFB91C1C);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: pillFg.withOpacity(.25)),
      ),
      child: Text(
        onTime ? 'A tiempo' : 'DPD: $dpd',
        style: TextStyle(
          color: pillFg,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
