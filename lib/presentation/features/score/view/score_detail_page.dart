// lib/presentation/features/score/view/score_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../score/controller/score_controller.dart';
import '../../settings/controller/settings_controller.dart';
import 'score_recommendations_page.dart';

class ScoreDetailPage extends StatefulWidget {
  const ScoreDetailPage({super.key});

  @override
  State<ScoreDetailPage> createState() => _ScoreDetailPageState();
}

class _ScoreDetailPageState extends State<ScoreDetailPage> {
  bool _kickedLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Si alguien entró directo a esta pantalla, asegura que el score esté cargado
    if (_kickedLoad) return;
    _kickedLoad = true;
    final scoreVm = context.read<ScoreController>();
    if (scoreVm.monthlyResult == null) {
      final settings = context.read<SettingsController>();
      scoreVm.load(thresholds: settings.thresholds);
    }
  }

  // ---------- Helpers de estado visual ----------
  KpiStatus _statusFrom(String? status) {
    return {
          'good': KpiStatus.good,
          'warning': KpiStatus.warning,
          'danger': KpiStatus.danger,
        }[status ?? 'warning'] ??
        KpiStatus.warning;
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

  @override
  Widget build(BuildContext context) {
    final scoreVm = context.watch<ScoreController>();

    // // Umbrales elegidos por el usuario (guardados en Settings/Profile)
    //final Thresholds t = scoreVm.thresholds;
    final t = scoreVm.thresholds;

    // Factores y resultados MENSUALES (los que se ven en el dashboard)
    final mf = scoreVm.monthlyFactors;
    final mr = scoreVm.monthlyResult;

    // Factores y resultado HISTÓRICO (opcional, puede ser null si no lo calculas)
    final lr = scoreVm.lifetimeResult;

    if (scoreVm.loading && mr == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Puntaje educativo')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (mr == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Puntaje educativo')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _InfoBanner(),
            SizedBox(height: 12),
            _EmptyStateCard(),
          ],
        ),
      );
    }

    final monthlyStatus = {
      'good': KpiStatus.good,
      'warning': KpiStatus.warning,
      'danger': KpiStatus.danger,
    }[mr.status]!;
    final monthlyC = colors(monthlyStatus);
    final monthlyLabel = {
      'good': 'Bueno',
      'warning': 'A mejorar',
      'danger': 'Bajo',
    }[mr.status]!;

    final histStatus = {
      'good': KpiStatus.good,
      'warning': KpiStatus.warning,
      'danger': KpiStatus.danger,
    }[lr?.status ?? 'warning']!;
    final histC = colors(histStatus);
    final histLabel = {
      'good': 'Bueno',
      'warning': 'A mejorar',
      'danger': 'Bajo',
    }[lr?.status ?? 'warning']!;

    final factors = mr.factors;
    final stDpd = _statusFrom(factors['dpd']?.status);
    final stDti = _statusFrom(factors['debtToIncome']?.status);
    final stUtil = _statusFrom(factors['utilization']?.status);
    final stSave = _statusFrom(factors['savings']?.status);
    return Scaffold(
      appBar: AppBar(title: const Text('Puntaje educativo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner aclaratorio
          const _InfoBanner(),
          const SizedBox(height: 12),

          // ===================== PUNTAJE MENSUAL (principal) =====================
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: monthlyC.bg,
              border: Border.all(color: monthlyC.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tu puntaje (mes actual)',
                  style: TextStyle(color: monthlyC.accent),
                ),
                const SizedBox(height: 6),
                Text(
                  mr.score.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 64,
                    height: 1.0,
                    fontWeight: FontWeight.w700,
                    color: monthlyC.accent,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 18, color: monthlyC.accent),
                    const SizedBox(width: 6),
                    Text(
                      monthlyLabel,
                      style: TextStyle(color: monthlyC.accent),
                    ),
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
          const SizedBox(height: 12),

          // ===================== CARD: SCORE HISTÓRICO TOTAL =====================
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: histC.bg,
              border: Border.all(color: histC.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.timeline_rounded),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Score histórico total',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Resumen considerando todo tu historial registrado.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      (lr?.score ?? 0).toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: histC.accent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(histLabel, style: TextStyle(color: histC.accent)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ===================== Desglose por indicador (mensual) =====================
          Text(
            'Desglose por indicador',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),

          _IndicatorCard(
            title: 'Días de atraso (DPD)',
            valueTrailing: '${mf?.dpd ?? 0}',
            description:
                'Promedio de días de atraso en tus pagos. Ideal: 0 días.',
            weightPct: 35,
            status: stDpd,
          ),
          const SizedBox(height: 10),

          _IndicatorCard(
            title: 'Deuda/Ingreso',
            valueTrailing: '${(mf?.debtToIncome ?? 0).toStringAsFixed(0)}%',
            description:
                'Cuotas mensuales vs ingreso. Ideal: <${t.debtToIncomeWarning.toStringAsFixed(0)}%.',
            weightPct: 25,
            status: stDti,
          ),
          const SizedBox(height: 10),

          _IndicatorCard(
            title: 'Utilización de crédito',
            valueTrailing: '${(mf?.utilization ?? 0).toStringAsFixed(0)}%',
            description:
                'Uso de línea disponible. Ideal: <${t.utilizationWarning.toStringAsFixed(0)}%.',
            weightPct: 25,
            status: stUtil,
          ),
          const SizedBox(height: 10),

          _IndicatorCard(
            title: 'Tasa de ahorro',
            valueTrailing: '${(mf?.savingsRate ?? 0).toStringAsFixed(1)}%',
            description:
                'Porcentaje que ahorras de tus ingresos. Ideal: ≥${t.savingsTarget.toStringAsFixed(0)}%.',
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

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Aún no podemos calcular tu puntaje',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Agrega tus movimientos y deudas recientes para generar recomendaciones personalizadas.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

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
