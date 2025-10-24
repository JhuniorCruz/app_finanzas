import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

import '../controller/debts_controller.dart';
import '../../transactions/controller/transactions_controller.dart';
import '../../score/controller/score_controller.dart';

class DebtDetailPage extends StatefulWidget {
  final String debtId;
  const DebtDetailPage({super.key, required this.debtId});

  @override
  State<DebtDetailPage> createState() => _DebtDetailPageState();
}

class _DebtDetailPageState extends State<DebtDetailPage> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DebtsController>();
    final debt = vm.items.firstWhere(
      (d) => d.id == widget.debtId,
      orElse: () => throw Exception('Deuda no encontrada'),
    );

    final dpd = _daysPastDue(debt.dueDate);
    final onTime = dpd == 0;

    final hasLimit = (debt.creditLimit != null && debt.creditLimit! > 0);
    final double? utilPct = hasLimit
        ? ((debt.totalDebt / debt.creditLimit!).clamp(0, 1) * 100)
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(debt.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoCard(
            title: debt.title,
            fee: debt.amount,
            dueDate: debt.dueDate,
            onTime: onTime,
            dpd: dpd,
            totalDebt: debt.totalDebt,
            creditLimit: debt.creditLimit,
            utilizationPct: utilPct,
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            icon: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_outline),
            label: Text(debt.paid ? 'Ya pagada' : 'Pagar y marcar'),
            onPressed: (debt.paid || _submitting)
                ? null
                : () async {
                    setState(() => _submitting = true);
                    try {
                      // 1) Crear gasto (expense) y 2) marcar deuda pagada
                      await context.read<DebtsController>().payAndMarkPaid(
                        debt,
                        amount: debt
                            .amount, // o debt.totalDebt si deseas liquidar todo
                        category: 'debt',
                        note: 'Pago deuda ${debt.title}',
                      );

                      // 3) Refrescar transacciones y score para que el dashboard baje el saldo al instante
                      await context.read<TransactionsController>().load();
                      await context.read<ScoreController>().load();

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pago registrado')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al pagar: $e')),
                      );
                    } finally {
                      if (mounted) setState(() => _submitting = false);
                    }
                  },
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final double fee;
  final DateTime dueDate;
  final bool onTime;
  final int dpd;
  final double totalDebt;
  final double? creditLimit;
  final double? utilizationPct;

  const _InfoCard({
    required this.title,
    required this.fee,
    required this.dueDate,
    required this.onTime,
    required this.dpd,
    required this.totalDebt,
    required this.creditLimit,
    required this.utilizationPct,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = onTime
        ? const Color(0xFF059669)
        : const Color(0xFFB91C1C);
    final statusText = onTime ? 'Al día' : 'DPD $dpd';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),

          // Cuota mensual (grande)
          const Text(
            'Cuota mensual',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          Text(
            formatCurrency(fee),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.foreground,
            ),
          ),

          const SizedBox(height: 16),

          // Fecha de vencimiento + Estado
          Row(
            children: [
              Expanded(
                child: _Kv(
                  label: 'Fecha de vencimiento',
                  value: formatDate(dueDate),
                  bold: true,
                ),
              ),
              Expanded(
                child: _Kv(
                  label: 'Estado',
                  value: statusText,
                  color: statusColor,
                  bold: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Deuda total
          _Kv(
            label: 'Deuda total',
            value: formatCurrency(totalDebt),
            bold: true,
          ),

          // Línea de crédito y utilización (si aplica)
          if (creditLimit != null && creditLimit! > 0) ...[
            const SizedBox(height: 12),
            _Kv(
              label: 'Línea de crédito',
              value: formatCurrency(creditLimit!),
              bold: true,
            ),
            const SizedBox(height: 8),
            _UtilBar(percent: (utilizationPct ?? 0) / 100),
            const SizedBox(height: 6),
            if (utilizationPct != null)
              Text(
                'Utilizando ${utilizationPct!.toStringAsFixed(0)}% de tu línea',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
          ],
        ],
      ),
    );
  }
}

class _Kv extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;

  const _Kv({
    required this.label,
    required this.value,
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color ?? AppColors.foreground,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _UtilBar extends StatelessWidget {
  final double percent; // 0.0 - 1.0
  const _UtilBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    final p = percent.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: p,
        minHeight: 8,
        color: AppColors.primary,
        backgroundColor: const Color(0xFFE2E8F0),
      ),
    );
  }
}

int _daysPastDue(DateTime dueDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  return today.isAfter(due) ? today.difference(due).inDays : 0;
}
