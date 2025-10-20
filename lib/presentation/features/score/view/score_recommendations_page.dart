import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/scoring.dart';
import '../../score/controller/score_controller.dart';

class ScoreRecommendationsPage extends StatefulWidget {
  const ScoreRecommendationsPage({super.key});
  @override
  State<ScoreRecommendationsPage> createState() =>
      _ScoreRecommendationsPageState();
}

class _ScoreRecommendationsPageState extends State<ScoreRecommendationsPage> {
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
    final r = vm.result;
    final f = vm.factors;

    return Scaffold(
      appBar: AppBar(title: const Text('Recomendaciones')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Resumen actual
          if (f != null && r != null) ...[
            _summaryRow('DPD', '${f.dpd} días'),
            _summaryRow(
              'Deuda/Ingreso',
              '${f.debtToIncome.toStringAsFixed(0)}%',
            ),
            _summaryRow('Utilización', '${f.utilization.toStringAsFixed(0)}%'),
            _summaryRow(
              'Tasa de ahorro',
              '${f.savingsRate.toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 14),
          ],

          // Acciones sugeridas
          Text(
            'Acciones sugeridas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ..._tips(r).map(_bullet),

          const SizedBox(height: 16),

          // Recursos educativos (bloque estático del original)
          Container(
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
                _Bullet('Evita la utilización alta de tus líneas de crédito'),
                _Bullet('Prioriza deudas con mayor tasa de interés'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
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

  List<String> _tips(ScoreResult? r) {
    if (r == null) return const [];
    // Usa las recomendaciones del motor que ya definimos
    return getRecommendations(r);
  }

  Widget _bullet(String text) => _Bullet(text);
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
