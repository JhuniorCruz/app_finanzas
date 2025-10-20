import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/scoring.dart';
import '../../score/controller/score_controller.dart';

class ScoreRecommendationsPage extends StatelessWidget {
  const ScoreRecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScoreController>();
    final r = vm.result;
    final tips = r == null ? const <String>[] : getRecommendations(r);

    return Scaffold(
      appBar: AppBar(title: const Text('Recomendaciones')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Sugerencias para mejorar tu puntaje',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...tips.map((t) => _bullet(t)).toList(),
        ],
      ),
    );
  }

  Widget _bullet(String text) => Padding(
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
