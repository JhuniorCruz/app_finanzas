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
    final utilPct = (d.creditLimit != null && d.creditLimit! > 0)
        ? (d.totalDebt / d.creditLimit! * 100)
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(d.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _row(context, 'Cuota mensual', formatCurrency(d.amount)),
          _row(context, 'Vencimiento', formatDate(d.dueDate)),
          _row(context, 'Estado', dpd <= 0 ? 'A tiempo' : 'Atraso ($dpd días)'),
          _row(context, 'Saldo total', formatCurrency(d.totalDebt)),
          if (d.creditLimit != null)
            _row(context, 'Línea', formatCurrency(d.creditLimit!)),
          if (utilPct != null)
            _row(context, 'Utilización', '${utilPct.toStringAsFixed(1)} %'),
          const SizedBox(height: 24),
        ],
      ),
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

  Widget _row(BuildContext context, String label, String value) {
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

  int _daysPastDue(DateTime due) {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(due.year, due.month, due.day)).inDays;
  }
}
