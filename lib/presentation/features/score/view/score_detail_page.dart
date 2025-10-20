//import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/scoring.dart';
import '../../score/controller/score_controller.dart';
import 'score_recommendations_page.dart';

enum KpiStatus { good, warning, danger }

class ScoreDetailPage extends StatefulWidget {
  const ScoreDetailPage({super.key});
  @override
  State<ScoreDetailPage> createState() => _ScoreDetailPageState();
}

class _ScoreDetailPageState extends State<ScoreDetailPage> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      Future.microtask(() => context.read<ScoreController>().load());
    }
  }

  // ---------- Helpers de estado visual (idéntico al original) ----------
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
          border: const Color(0xFFFFCDD2),
          accent: const Color(0xFFB91C1C),
        );
    }
  }

  double _pct(num nume, num deno) {
    if (deno <= 0) return 0;
    final v = (nume / deno) * 100.0;
    if (v.isNaN || v.isInfinite) return 0;
    return v.clamp(0, 999).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScoreController>();
    final thresholds = vm.thresholds;

    if (vm.loading && vm.result == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Si aún no calculó, usa valores “seguros” para no romper UI
    final f =
        vm.factors ??
        const ScoreFactors(
          dpd: 0,
          debtToIncome: 0,
          utilization: 0,
          savingsRate: 0,
        );
    final r = vm.result ?? calculateScore(f, thresholds);

    final stMain = switch (r.status) {
      'good' => KpiStatus.good,
      'warning' => KpiStatus.warning,
      _ => KpiStatus.danger,
    };
    final mainC = _colors(stMain);

    // Estados por KPI
    final stDpd = _statusDpd(f.dpd);
    final stDti = _statusLessIsBetter(
      f.debtToIncome,
      thresholds.debtToIncomeWarning,
    );
    final stUtil = _statusLessIsBetter(
      f.utilization,
      thresholds.utilizationWarning,
    );
    final stSave = _statusMoreIsBetter(f.savingsRate, thresholds.savingsTarget);

    // Texto del header según estado
    final mainText = switch (r.status) {
      'good' => '¡Vas muy bien!',
      'warning' => 'Vas en camino, ajusta algunas cosas.',
      _ => 'Necesitas mejoras urgentes.',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Puntaje educativo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner aclaratorio (amarillo)
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

          // Card principal con color por estado
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
                Text(
                  '${r.score}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: mainC.accent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  mainText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text(
            'Indicadores que componen tu puntaje',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),

          _IndicatorCard(
            title: 'Días de atraso (DPD)',
            valueTrailing: '${f.dpd} días',
            description:
                'Promedio de atraso entre tus deudas activas. Ideal: 0 días.',
            weightPct: 35,
            status: stDpd,
          ),
          const SizedBox(height: 10),

          _IndicatorCard(
            title: 'Deuda / Ingreso',
            valueTrailing: '${f.debtToIncome.toStringAsFixed(0)}%',
            description:
                'Relación de cuotas vs. ingreso mensual. Ideal: ≤${thresholds.debtToIncomeWarning.toStringAsFixed(0)}%.',
            weightPct: 25,
            status: stDti,
          ),
          const SizedBox(height: 10),

          _IndicatorCard(
            title: 'Utilización de crédito',
            valueTrailing: '${f.utilization.toStringAsFixed(0)}%',
            description:
                'Uso de línea disponible. Ideal: <${thresholds.utilizationWarning.toStringAsFixed(0)}%.',
            weightPct: 25,
            status: stUtil,
          ),
          const SizedBox(height: 10),

          _IndicatorCard(
            title: 'Tasa de ahorro',
            valueTrailing: '${f.savingsRate.toStringAsFixed(1)}%',
            description:
                'Porcentaje que ahorras de tus ingresos. Meta: ≥${thresholds.savingsTarget.toStringAsFixed(0)}%.',
            weightPct: 15,
            status: stSave,
          ),

          const SizedBox(height: 16),

          // CTA: Ver recomendaciones
          SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.trending_up_rounded),
                label: const Text('Ver recomendaciones'),
                onPressed: () {
                  Navigator.push(
                    context,
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

// =================== UI (idéntico al estilo original) ===================

class _IndicatorCard extends StatelessWidget {
  final String title;
  final String valueTrailing;
  final String description;
  final int weightPct; // 0..100
  final KpiStatus status;
  const _IndicatorCard({
    required this.title,
    required this.valueTrailing,
    required this.description,
    required this.weightPct,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final c = switch (status) {
      KpiStatus.good => (
        bg: const Color(0xFFEFFDF5),
        border: const Color(0xFFD1F7E8),
        accent: const Color(0xFF16A34A),
      ),
      KpiStatus.warning => (
        bg: const Color(0xFFFFF7E8),
        border: const Color(0xFFFFE3A3),
        accent: const Color(0xFFF59E0B),
      ),
      KpiStatus.danger => (
        bg: const Color(0xFFFFEBEE),
        border: const Color(0xFFFFCDD2),
        accent: const Color(0xFFB91C1C),
      ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border, width: 2),
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
          // Barra de peso (decorativa)
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: c.bg,
              border: Border.all(color: c.border),
              borderRadius: BorderRadius.circular(16),
            ),
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
