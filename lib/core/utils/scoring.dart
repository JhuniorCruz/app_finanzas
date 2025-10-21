// lib/core/utils/scoring.dart

class ScoreFactors {
  final int dpd; // días de atraso promedio
  final double debtToIncome; // %
  final double utilization; // %
  final double savingsRate; // %
  const ScoreFactors({
    required this.dpd,
    required this.debtToIncome,
    required this.utilization,
    required this.savingsRate,
  });
}

class FactorInfo {
  final double value;
  final String status; // 'good' | 'warning' | 'danger'
  final double weight;
  const FactorInfo({
    required this.value,
    required this.status,
    required this.weight,
  });
}

class ScoreResult {
  final int score; // 0-100
  final String status; // 'good' | 'warning' | 'danger'
  final Map<String, FactorInfo> factors;
  const ScoreResult({
    required this.score,
    required this.status,
    required this.factors,
  });
}

class Thresholds {
  final double debtToIncomeWarning;
  final double utilizationWarning;
  final double savingsTarget;
  const Thresholds({
    required this.debtToIncomeWarning,
    required this.utilizationWarning,
    required this.savingsTarget,
  });
}

// Umbrales por defecto (para cuando no pasemos uno explícito)
const defaultThresholds = Thresholds(
  debtToIncomeWarning: 30,
  utilizationWarning: 50,
  savingsTarget: 20,
);

ScoreResult calculateScore(ScoreFactors f, Thresholds t) {
  // Ponderaciones
  const weights = {
    'dpd': 0.35,
    'debtToIncome': 0.25,
    'utilization': 0.25,
    'savings': 0.15,
  };

  final dpdScore = (100 - (f.dpd * 10)).clamp(0, 100).toDouble();
  final dpdStatus = f.dpd == 0 ? 'good' : (f.dpd <= 5 ? 'warning' : 'danger');

  final debtScore =
      (100 -
              ((f.debtToIncome - t.debtToIncomeWarning).clamp(
                    0,
                    double.infinity,
                  ) *
                  2))
          .clamp(0, 100)
          .toDouble();
  final debtStatus = f.debtToIncome <= t.debtToIncomeWarning
      ? 'good'
      : (f.debtToIncome <= t.debtToIncomeWarning * 1.25 ? 'warning' : 'danger');

  final utilScore =
      (100 -
              ((f.utilization - t.utilizationWarning).clamp(
                    0,
                    double.infinity,
                  ) *
                  2))
          .clamp(0, 100)
          .toDouble();
  final utilStatus = f.utilization <= t.utilizationWarning
      ? 'good'
      : (f.utilization <= t.utilizationWarning * 1.2 ? 'warning' : 'danger');

  final savScore = ((f.savingsRate / t.savingsTarget) * 100)
      .clamp(0, 100)
      .toDouble();
  final savStatus = f.savingsRate >= t.savingsTarget
      ? 'good'
      : (f.savingsRate >= t.savingsTarget * 0.7 ? 'warning' : 'danger');

  final total =
      (dpdScore * weights['dpd']! +
              debtScore * weights['debtToIncome']! +
              utilScore * weights['utilization']! +
              savScore * weights['savings']!)
          .round();

  final overall = total >= 80 ? 'good' : (total >= 60 ? 'warning' : 'danger');

  return ScoreResult(
    score: total,
    status: overall,
    factors: {
      'dpd': FactorInfo(
        value: f.dpd.toDouble(),
        status: dpdStatus,
        weight: weights['dpd']!,
      ),
      'debtToIncome': FactorInfo(
        value: f.debtToIncome,
        status: debtStatus,
        weight: weights['debtToIncome']!,
      ),
      'utilization': FactorInfo(
        value: f.utilization,
        status: utilStatus,
        weight: weights['utilization']!,
      ),
      'savings': FactorInfo(
        value: f.savingsRate,
        status: savStatus,
        weight: weights['savings']!,
      ),
    },
  );
}

List<String> generateRecommendations(ScoreResult r, Thresholds t) {
  final out = <String>[];
  if (r.factors['dpd']!.status != 'good') {
    out.add(
      'Tienes pagos atrasados. Prioriza regularizar tus deudas para evitar intereses.',
    );
  }
  if (r.factors['debtToIncome']!.status == 'danger') {
    out.add(
      'Tu deuda/ingreso supera ${t.debtToIncomeWarning}%. Reduce gastos o amplía plazos.',
    );
  } else if (r.factors['debtToIncome']!.status == 'warning') {
    out.add(
      'Tu nivel de deuda está cerca del límite recomendado. Evita nuevas deudas por ahora.',
    );
  }
  if (r.factors['utilization']!.status == 'danger') {
    out.add('Utilización alta. Intenta pagar más del mínimo este mes.');
  } else if (r.factors['utilization']!.status == 'warning') {
    out.add(
      'Tu utilización de crédito está alta. Controla de cerca tus gastos con tarjeta.',
    );
  }
  if (r.factors['savings']!.status == 'danger') {
    out.add(
      'Ahorro por debajo de tu meta. Activa una meta de ahorro automático.',
    );
  } else if (r.factors['savings']!.status == 'warning') {
    out.add(
      'Estás cerca de tu meta de ahorro. Intenta aumentar un 2% este mes.',
    );
  }
  if (out.isEmpty) out.add('¡Excelente! Considera aumentar tu meta de ahorro.');
  return out;
}

// ---- Shims de compatibilidad usados por las views que ya hicimos ----

// Wrapper para el nombre que ya usamos en las vistas
List<String> getRecommendations(ScoreResult r, [Thresholds? t]) {
  final tt = t ?? defaultThresholds;
  return generateRecommendations(r, tt);
}

// clampScore lo usamos como helper visual en Dashboard
int clampScore(num v) => v.clamp(0, 100).round();
