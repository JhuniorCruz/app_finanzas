import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart'; // getDaysPastDue
import '../../transactions/controller/transactions_controller.dart';
import '../../debts/controller/debts_controller.dart';
import '../../settings/controller/settings_controller.dart';

class ScoreRecommendationsPage extends StatelessWidget {
  const ScoreRecommendationsPage({super.key});

  double _pct(num nume, num deno) {
    if (deno <= 0) return 0;
    final v = (nume / deno) * 100.0;
    if (v.isNaN || v.isInfinite) return 0;
    return v.clamp(0, 999).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final txs = context.watch<TransactionsController>().items;
    final debts = context.watch<DebtsController>().items;
    final profile = context.watch<SettingsController>().profile!;

    // --- métricas actuales (mismo criterio que en detalle) ---
    final now = DateTime.now();
    final monthTx = txs
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .toList();

    final double income = monthTx
        .where((t) => t.type == 'income')
        .fold<double>(0, (s, t) => s + t.amount);

    final double expenses = monthTx
        .where((t) => t.type == 'expense')
        .fold<double>(0, (s, t) => s + t.amount);

    final debtsActive = debts.where((d) => d.paid == false).toList();

    final int dpdAvg = debtsActive.isEmpty
        ? 0
        : (debtsActive
                      .map<int>((d) => getDaysPastDue(d.dueDate))
                      .reduce((a, b) => a + b) /
                  debtsActive.length)
              .round();

    final double installments = debtsActive.fold<double>(
      0,
      (s, d) => s + d.amount,
    );

    final dti = _pct(installments, income);

    double utilization = 0;
    final withLimit = debtsActive.where(
      (d) => d.creditLimit != null && d.creditLimit! > 0,
    );
    if (withLimit.isNotEmpty) {
      final used = withLimit.fold<double>(0, (s, d) => s + d.totalDebt);
      final limit = withLimit.fold<double>(
        0,
        (s, d) => s + (d.creditLimit ?? 0),
      );
      utilization = _pct(used, limit);
    }

    final savingsRate = _pct(income - expenses, income);

    // --- tips personalizados ---
    final List<_Tip> tips = [];
    if (dpdAvg > 0) {
      tips.add(
        const _Tip(
          'Tienes pagos atrasados. Prioriza regularizar tus deudas para evitar más intereses y mejorar tu historial.',
        ),
      );
    }
    if (utilization > profile.utilizationThreshold) {
      tips.add(
        _Tip(
          'Utilización > ${profile.utilizationThreshold.toStringAsFixed(0)}%. Intenta pagar más del mínimo este mes para reducir tu deuda.',
        ),
      );
    }
    if (dti > profile.debtToIncomeThreshold) {
      tips.add(
        const _Tip(
          'Tus cuotas mensuales son altas respecto a tu ingreso. Evita asumir nuevas deudas hasta bajar tu Deuda/Ingreso.',
        ),
      );
    }
    if (savingsRate < profile.savingsTarget) {
      tips.add(
        _Tip(
          'Aumenta gradualmente tu tasa de ahorro (meta: ${profile.savingsTarget.toStringAsFixed(0)}%). Revisa gastos prescindibles.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Recomendaciones')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Tips personalizados basados en tu perfil financiero actual',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),

          if (tips.isEmpty)
            _tipCard(
              const _Tip(
                '¡Vas muy bien! Mantén buenos hábitos de pago y ahorro para conservar tu puntaje.',
              ),
            )
          else
            ...tips.map(_tipCard),

          const SizedBox(height: 16),
          _resourcesCard(),
        ],
      ),
    );
  }

  Widget _tipCard(_Tip tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tips_and_updates_rounded, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(tip.text)),
        ],
      ),
    );
  }

  Widget _resourcesCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recursos educativos',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
          _Bullet(
            'Mantén un fondo de emergencia equivalente a 3–6 meses de gastos',
          ),
          _Bullet('Revisa y ajusta tu presupuesto mensualmente'),
          _Bullet('Evita usar más del 30% de tu línea de crédito disponible'),
          _Bullet('Paga tus deudas antes de la fecha de vencimiento'),
        ],
      ),
    );
  }
}

class _Tip {
  final String text;
  const _Tip(this.text);
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
