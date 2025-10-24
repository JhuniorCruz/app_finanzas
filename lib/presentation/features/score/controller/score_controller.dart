import 'package:flutter/foundation.dart';

import '../../../../application/usecases/list_transactions.dart';
import '../../../../application/usecases/list_debts.dart';
//import '../../../../domain/entities/transaction.dart';
//import '../../../../domain/entities/debt.dart';
import '../../../../core/utils/formatters.dart'; // getDaysPastDue
import '../../../../core/utils/scoring.dart';

class ScoreController extends ChangeNotifier {
  final ListTransactions _listTx;
  final ListDebts _listDebts;

  ScoreController(this._listTx, this._listDebts);

  bool _loading = false;
  bool get loading => _loading;

  int score = 0;
  ScoreResult? result;
  ScoreFactors? factors;

  /// (Si más adelante lees estos valores desde Settings, injéctalos aquí)
  Thresholds thresholds = const Thresholds(
    debtToIncomeWarning: 30, // %
    utilizationWarning: 50, // %
    savingsTarget: 20, // %
  );

  double _pct(num nume, num deno) {
    if (deno <= 0) return 0;
    final v = (nume / deno) * 100.0;
    if (v.isNaN || v.isInfinite) return 0;
    return v.clamp(0, 999).toDouble();
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    // --- Transacciones del MES actual (usa type, no el signo del monto) ---
    final txAll = await _listTx();
    final now = DateTime.now();
    final monthTx = txAll
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .toList();

    final double incomes = monthTx
        .where((t) => t.type == 'income')
        .fold<double>(0, (s, t) => s + t.amount);

    final double expenses = monthTx
        .where((t) => t.type == 'expense')
        .fold<double>(0, (s, t) => s + t.amount);

    // % Ahorro = (ingresos - gastos) / ingresos * 100
    final double savingsRate = _pct(incomes - expenses, incomes);

    // --- Deudas activas ---
    final debtsAll = await _listDebts();
    final unpaid = debtsAll.where((d) => !d.paid).toList();

    // DPD promedio (solo deudas no pagadas)
    final dpdList = unpaid.map((d) => getDaysPastDue(d.dueDate)).toList();
    final int dpd = dpdList.isEmpty
        ? 0
        : (dpdList.reduce((a, b) => a + b) / dpdList.length).round();

    // Suma de cuotas mensuales (asumiendo que `amount` es la cuota)
    final double monthlyDebt = unpaid.fold<double>(0, (s, d) => s + d.amount);

    // DTI = cuota total / ingresos * 100
    final double dti = _pct(monthlyDebt, incomes);

    // Utilización = deuda usada / línea total * 100 (en deudas con límite)
    double utilization = 0.0;
    final withLimit = unpaid.where((d) => (d.creditLimit ?? 0) > 0).toList();
    if (withLimit.isNotEmpty) {
      final used = withLimit.fold<double>(0, (s, d) => s + d.totalDebt);
      final limit = withLimit.fold<double>(
        0,
        (s, d) => s + (d.creditLimit ?? 0),
      );
      utilization = _pct(used, limit);
    }

    // --- Cálculo de score ---
    factors = ScoreFactors(
      dpd: dpd,
      debtToIncome: dti,
      utilization: utilization,
      savingsRate: savingsRate,
    );

    result = calculateScore(factors!, thresholds);
    score = result!.score;

    _loading = false;
    notifyListeners();
  }
}
