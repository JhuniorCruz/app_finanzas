import 'package:flutter/foundation.dart';

import '../../../../application/usecases/list_transactions.dart';
import '../../../../application/usecases/list_debts.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../../domain/entities/debt.dart';
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

  // Puedes ajustar estos valores leyendo luego desde Settings
  Thresholds thresholds = const Thresholds(
    debtToIncomeWarning: 30, // %
    utilizationWarning: 50, // %
    savingsTarget: 20, // %
  );

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    final List<FinanceTx> tx = await _listTx();
    final List<Debt> debts = await _listDebts();

    final double incomes = tx
        .where((t) => t.amount > 0)
        .fold<double>(0, (s, t) => s + t.amount);

    final double expensesAbs = tx
        .where((t) => t.amount < 0)
        .fold<double>(0, (s, t) => s + t.amount.abs());

    // Tasa de ahorro (%) = (ingresos - gastos) / ingresos * 100
    final double savingsRate = incomes <= 0
        ? 0.0
        : (((incomes - expensesAbs) / incomes) * 100).clamp(0, 999).toDouble();

    final List<Debt> unpaid = debts.where((d) => !d.paid).toList();
    final List<int> dpdList = unpaid
        .map((d) => getDaysPastDue(d.dueDate))
        .toList();
    final int dpd = dpdList.isEmpty
        ? 0
        : (dpdList.reduce((a, b) => a + b) / dpdList.length).round();

    final double monthlyDebt = debts.fold<double>(0, (s, d) => s + d.amount);

    // DTI (%) = cuota mensual total / ingresos * 100
    final double dti = incomes <= 0
        ? 0.0
        : (monthlyDebt / incomes * 100).clamp(0, 999).toDouble();

    // Utilización (%) = saldo total / línea total * 100
    final double totalLimit = debts.fold<double>(
      0,
      (s, d) => s + (d.creditLimit ?? 0),
    );
    final double totalDebt = debts.fold<double>(0, (s, d) => s + d.totalDebt);
    final double utilization = totalLimit <= 0
        ? 0.0
        : (totalDebt / totalLimit * 100).clamp(0, 999).toDouble();

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
