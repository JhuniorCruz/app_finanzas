import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/scoring.dart';
import '../../score/controller/score_controller.dart';
import 'score_recommendations_page.dart';

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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScoreController>();
    if (vm.loading || vm.result == null || vm.factors == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final f = vm.factors!;
    final r = vm.result!;
    return Scaffold(
      appBar: AppBar(title: const Text('Puntaje educativo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(r.score, r.status),
          const SizedBox(height: 16),
          _kpi(
            'Días de atraso (DPD)',
            '${f.dpd} días',
            35,
            _statusColor(r.breakdown['dpd'] ?? 0),
          ),
          const SizedBox(height: 10),
          _kpi(
            'Deuda / Ingreso',
            '${f.debtToIncome.toStringAsFixed(1)}%',
            25,
            _statusColor(r.breakdown['dti'] ?? 0),
          ),
          const SizedBox(height: 10),
          _kpi(
            'Utilización de crédito',
            '${f.utilization.toStringAsFixed(1)}%',
            25,
            _statusColor(r.breakdown['utilization'] ?? 0),
          ),
          const SizedBox(height: 10),
          _kpi(
            'Tasa de ahorro',
            '${f.savingsRate.toStringAsFixed(1)}%',
            15,
            _statusColor(r.breakdown['savings'] ?? 0),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.tips_and_updates_outlined),
            label: const Text('Ver recomendaciones'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ScoreRecommendationsPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(int score, String status) {
    final color = switch (status) {
      'good' => AppColors.accent,
      'warning' => const Color(0xFFF59E0B),
      _ => AppColors.destructive,
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        border: Border.all(color: color.withOpacity(.3), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            '$score',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              status == 'good'
                  ? '¡Vas muy bien!'
                  : (status == 'warning'
                        ? 'Vas en camino, ajusta algunas cosas.'
                        : 'Necesitas mejoras urgentes.'),
              style: const TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(double component) {
    if (component >= 80) return AppColors.accent;
    if (component >= 60) return const Color(0xFFF59E0B);
    return AppColors.destructive;
  }

  Widget _kpi(String title, String value, int weight, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Peso: $weight%',
                  style: const TextStyle(color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
