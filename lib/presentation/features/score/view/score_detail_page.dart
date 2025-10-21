import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart'; // getDaysPastDue(), formatDate/formatCurrency
import '../../../../core/utils/scoring.dart'; // calculateScore, ScoreFactors, Thresholds, defaultThresholds
import '../../transactions/controller/transactions_controller.dart';
import '../../debts/controller/debts_controller.dart';
import '../../settings/controller/settings_controller.dart';
import 'score_recommendations_page.dart'; // ← sin hide

class ScoreDetailPage extends StatelessWidget {
  const ScoreDetailPage({super.key});

  // ---------- Helpers de estado visual ----------
  KpiStatus _statusDpd(int dpd) {
    if (dpd <= 0) return KpiStatus.good;
    if (dpd <= 5) return KpiStatus.warning;
    return KpiStatus.danger;
  }

  KpiStatus _statusLessIsBetter(double valuePct, double warnThreshold) {
    if (valuePct <= warnThreshold) return KpiStatus.good;
    if (valuePct <= warnThreshold + 10) return KpiStatus.warning;
    return KpiStatus.danger;
  }

  KpiStatus _statusMoreIsBetter(double valuePct, double target) {
    if (valuePct >= target) return KpiStatus.good;
    if (valuePct >= target * 0.6) return KpiStatus.warning;
    return KpiStatus.danger;
  }

  ({Color bg, Color border, Color accent}) colors(KpiStatus s) {
    switch (s) {
      case KpiStatus.good:
        return (
          bg: const Color(0xFFEFFDF5),
          border: const Color(0xFFD1F7E8),
          accent: const Color(0xFF16A34A),
        );
      case KpiStatus.warning:
        return (
          bg: const Color(0xFFFFF7E8),
          border: const Color(0xFFFFE3A3),
          accent: const Color(0xFFF59E0B),
        );
      case KpiStatus.danger:
        return (
          bg: const Color(0xFFFFEBEE),
          border: const Color(0xFFFACDD2),
          accent: const Color(0xFFDC2626),
        );
    }
  }

  double _pct(double num, double den) {
    if (den <= 0) return 0;
    final v = (num / den) * 100.0;
    if (v.isNaN || v.isInfinite) return 0;
    return v.clamp(0, 999).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final txs = context.watch<TransactionsController>().items;
    final debts = context.watch<DebtsController>().items;
    final profile = context.watch<SettingsController>().profile;

    final thresholds = Thresholds(
      debtToIncomeWarning:
          profile?.debtToIncomeThreshold ??
          defaultThresholds.debtToIncomeWarning,
      utilizationWarning:
          profile?.utilizationThreshold ?? defaultThresholds.utilizationWarning,
      savingsTarget: profile?.savingsTarget ?? defaultThresholds.savingsTarget,
    );

    // Mes actual
    final now = DateTime.now();
    final monthTx = txs
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .toList();

    final income = monthTx
        .where((t) => t.type == 'income')
        .fold<double>(0, (a, t) => a + t.amount);
    final expenses = monthTx
        .where((t) => t.type == 'expense')
        .fold<double>(0, (a, t) => a + t.amount);

    final debtsActive = debts.where((d) => !d.paid).toList();

    final dpdAvg = debtsActive.isEmpty
        ? 0
        : (debtsActive
                      .map((d) => getDaysPastDue(d.dueDate))
                      .reduce((a, b) => a + b) /
                  debtsActive.length)
              .round();

    final installments = debtsActive.fold<double>(0, (a, d) => a + d.amount);
    final dti = _pct(installments, income);

    double utilization = 0;
    final withLimit = debtsActive.where(
      (d) => d.creditLimit != null && d.creditLimit! > 0,
    );
    if (withLimit.isNotEmpty) {
      final used = withLimit.fold<double>(0, (a, d) => a + d.totalDebt);
      final limit = withLimit.fold<double>(
        0,
        (a, d) => a + (d.creditLimit ?? 0),
      );
      utilization = _pct(used, limit);
    }

    final savingsRate = _pct(income - expenses, income);

    // Calcula puntaje global
    final scoreObj = calculateScore(
      ScoreFactors(
        dpd: dpdAvg,
        debtToIncome: dti,
        utilization: utilization,
        savingsRate: savingsRate,
      ),
      thresholds,
    );

    final overallKpi = {
      'good': KpiStatus.good,
      'warning': KpiStatus.warning,
      'danger': KpiStatus.danger,
    }[scoreObj.status]!;
    final mainC = colors(overallKpi);
    final overallLabel = {
      'good': 'Bueno',
      'warning': 'A mejorar',
      'danger': 'Bajo',
    }[scoreObj.status]!;

    // Estados por indicador
    final stDpd = _statusDpd(dpdAvg);
    final stDti = _statusLessIsBetter(dti, thresholds.debtToIncomeWarning);
    final stUtil = _statusLessIsBetter(
      utilization,
      thresholds.utilizationWarning,
    );
    final stSave = _statusMoreIsBetter(savingsRate, thresholds.savingsTarget);

    return Scaffold(
      appBar: AppBar(title: const Text('Puntaje educativo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner aclaratorio
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E8),
              border: Border.all(color: const Color(0xFFFFE3A3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Este puntaje es educativo, no oficial. Las entidades financieras usan sus propios modelos.',
              style: TextStyle(color: Color(0xFFB45309)),
            ),
          ),
          const SizedBox(height: 12),

          // Card principal (colores según estado global)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: mainC.bg,
              border: Border.all(color: mainC.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Tu puntaje', style: TextStyle(color: mainC.accent)),
                const SizedBox(height: 6),
                Text(
                  scoreObj.score.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 64,
                    height: 1.0,
                    fontWeight: FontWeight.w700,
                    color: mainC.accent,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 18, color: mainC.accent),
                    const SizedBox(width: 6),
                    Text(overallLabel, style: TextStyle(color: mainC.accent)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Escala de 0 a 100 puntos',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Desglose por indicador',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),

          _IndicatorCard(
            title: 'Días de atraso (DPD)',
            valueTrailing: '$dpdAvg',
            description:
                'Promedio de días de atraso en tus pagos.\nIdeal: 0 días.',
            weightPct: 35,
            status: stDpd,
          ),
          const SizedBox(height: 10),

          _IndicatorCard(
            title: 'Deuda/Ingreso',
            valueTrailing: '${dti.toStringAsFixed(0)}%',
            description:
                'Cuotas mensuales vs ingreso. Ideal: <${thresholds.debtToIncomeWarning.toStringAsFixed(0)}%.',
            weightPct: 25,
            status: stDti,
          ),
          const SizedBox(height: 10),

          _IndicatorCard(
            title: 'Utilización de crédito',
            valueTrailing: '${utilization.toStringAsFixed(0)}%',
            description:
                'Uso de línea disponible. Ideal: <${thresholds.utilizationWarning.toStringAsFixed(0)}%.',
            weightPct: 25,
            status: stUtil,
          ),
          const SizedBox(height: 10),

          _IndicatorCard(
            title: 'Tasa de ahorro',
            valueTrailing: '${savingsRate.toStringAsFixed(1)}%',
            description:
                'Porcentaje que ahorras de tus ingresos. Ideal: ≥${thresholds.savingsTarget.toStringAsFixed(0)}%.',
            weightPct: 15,
            status: stSave,
          ),

          const SizedBox(height: 16),

          // ===== CTA: Ver recomendaciones =====
          SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.trending_up_rounded),
                label: const Text('Ver recomendaciones'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ScoreRecommendationsPage(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================== Widgets auxiliares ==================

enum KpiStatus { good, warning, danger }

class _IndicatorCard extends StatelessWidget {
  final String title;
  final String valueTrailing;
  final String description;
  final int weightPct;
  final KpiStatus status;

  const _IndicatorCard({
    required this.title,
    required this.valueTrailing,
    required this.description,
    required this.weightPct,
    required this.status,
  });

  ({Color bg, Color border, Color accent}) _colors(KpiStatus s) {
    switch (s) {
      case KpiStatus.good:
        return (
          bg: const Color(0xFFEFFDF5),
          border: const Color(0xFFD1F7E8),
          accent: const Color(0xFF16A34A),
        );
      case KpiStatus.warning:
        return (
          bg: const Color(0xFFFFF7E8),
          border: const Color(0xFFFFE3A3),
          accent: const Color(0xFFF59E0B),
        );
      case KpiStatus.danger:
        return (
          bg: const Color(0xFFFFEBEE),
          border: const Color(0xFFFACDD2),
          accent: const Color(0xFFDC2626),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _colors(status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.bg,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
              ),
              Text(
                valueTrailing,
                style: TextStyle(fontWeight: FontWeight.w700, color: c.accent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              description,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Peso en puntaje',
                style: TextStyle(color: c.accent, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '$weightPct%',
                style: TextStyle(color: c.accent, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(height: 6, width: double.infinity, color: c.border),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: weightPct / 100,
                  child: Container(height: 6, color: c.accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
