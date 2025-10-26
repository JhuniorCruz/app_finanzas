import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/scoring.dart';
import '../../score/controller/score_controller.dart';

class ScoreRecommendationsPage extends StatelessWidget {
  const ScoreRecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scoreVm = context.watch<ScoreController>();
    final result = scoreVm.monthlyResult;
    final thresholds = scoreVm.thresholds;

    final recommendations = result == null
        ? const <String>[]
        : generateRecommendations(result, thresholds);

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

          if (scoreVm.loading)
            const Center(child: CircularProgressIndicator())
          else if (result == null)
            _tipCard(
              const _Tip(
                'Agrega tus movimientos y deudas para recibir recomendaciones personalizadas.',
              ),
            )
          else
            ...recommendations.map((text) => _tipCard(_Tip(text))),

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
