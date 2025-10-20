import 'dart:math' as math;

/// Días de atraso (DPD) entre una fecha de vencimiento y hoy.
int getDaysPastDue(DateTime due) {
  final now = DateTime.now();
  final d1 = DateTime(due.year, due.month, due.day);
  final d2 = DateTime(now.year, now.month, now.day);
  return d2.difference(d1).inDays; // <= 0 si aún no vence
}

/// Asegura un porcentaje entre 0 y 100. Maneja NaN/Infinito.
double clampScore(num v) {
  final d = v.toDouble();
  if (d.isNaN || d.isInfinite) return 0.0;
  return d.clamp(0.0, 100.0);
}

/// Factores que alimentan el puntaje educativo.
class ScoreFactors {
  final int dpd; // días de atraso promedio (0..∞)
  final double debtToIncome; // DTI %, 0..∞
  final double utilization; // % uso de línea, 0..∞
  final double savingsRate; // % ahorro del ingreso, 0..100+
  const ScoreFactors({
    required this.dpd,
    required this.debtToIncome,
    required this.utilization,
    required this.savingsRate,
  });
}

/// Umbrales de referencia (puedes ajustarlos desde Settings más adelante).
class Thresholds {
  final double debtToIncomeWarning; // p.ej. 30%
  final double utilizationWarning; // p.ej. 50%
  final double savingsTarget; // p.ej. 20%
  const Thresholds({
    required this.debtToIncomeWarning,
    required this.utilizationWarning,
    required this.savingsTarget,
  });
}

/// Resultado del cálculo.
class ScoreResult {
  final int score; // 0..100
  final String status; // 'good' | 'warning' | 'danger'
  final Map<String, double> breakdown; // componentes 0..100
  const ScoreResult({
    required this.score,
    required this.status,
    required this.breakdown,
  });
}

/// Calcula el score compuesto con pesos: DPD(35%), DTI(25%), Util(25%), Ahorro(15%).
ScoreResult calculateScore(ScoreFactors f, Thresholds t) {
  // Componente por DPD: cada día resta ~6 puntos hasta 0.
  final compDpd = clampScore(100 - math.min(f.dpd * 6, 100));

  // DTI: si estás dentro del umbral => 100; por cada punto sobre umbral, resta *2.
  final overDti = math.max(0.0, f.debtToIncome - t.debtToIncomeWarning);
  final compDti = clampScore(100 - math.min(overDti * 2.0, 100));

  // Utilización: similar al DTI, pero penaliza *1.5 por cada punto sobre umbral.
  final overUtil = math.max(0.0, f.utilization - t.utilizationWarning);
  final compUtil = clampScore(100 - math.min(overUtil * 1.5, 100));

  // Ahorro: si alcanzas la meta => 100; si no, proporcional.
  final compSav = clampScore(
    (f.savingsRate / (t.savingsTarget <= 0 ? 1 : t.savingsTarget)) * 100,
  );

  // Pesos
  const wDpd = 0.35, wDti = 0.25, wUtil = 0.25, wSav = 0.15;

  final composite =
      compDpd * wDpd + compDti * wDti + compUtil * wUtil + compSav * wSav;

  final score = composite.round();
  final status = score >= 80 ? 'good' : (score >= 60 ? 'warning' : 'danger');

  return ScoreResult(
    score: score,
    status: status,
    breakdown: {
      'dpd': compDpd,
      'dti': compDti,
      'utilization': compUtil,
      'savings': compSav,
    },
  );
}

/// Recomendaciones generales según el estado (puedes personalizar luego por factor).
List<String> getRecommendations(ScoreResult r) {
  switch (r.status) {
    case 'good':
      return [
        'Mantén tus pagos a tiempo (DPD = 0).',
        'Conserva la utilización de tarjetas por debajo del 50%.',
        'Sostén tu tasa de ahorro mensual.',
      ];
    case 'warning':
      return [
        'Reduce gastos variables 10–15% para elevar tu tasa de ahorro.',
        'Baja tu DTI refinanciando o acortando gastos fijos.',
        'Evita nuevas compras con tarjeta hasta estar por debajo del umbral.',
        'Prioriza pagar deudas con mayor interés y próximos vencimientos.',
      ];
    default: // 'danger'
      return [
        'Regulariza atrasos más antiguos primero para bajar el DPD.',
        'Haz un plan de recorte de gastos del 20–30% por 2–3 meses.',
        'Transfiere saldos a menor tasa o consolida deudas si es posible.',
        'Suspende nuevas deudas hasta estabilizar el flujo mensual.',
      ];
  }
}
