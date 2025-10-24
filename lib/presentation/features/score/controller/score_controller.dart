// lib/presentation/features/score/controller/score_controller.dart
import 'package:flutter/foundation.dart';

import '../../../../application/usecases/list_transactions.dart';
import '../../../../application/usecases/list_debts.dart';
import '../../../../domain/entities/transaction.dart' as dom;
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

  /// Umbrales actuales (se pueden inyectar desde Ajustes)
  Thresholds _thresholds = const Thresholds(
    savingsTarget: 20, // %
    debtToIncomeWarning: 30, // %
    utilizationWarning: 50, // %
  );
  Thresholds get thresholds => _thresholds;
  void setThresholds(Thresholds t) {
    _thresholds = t;
    notifyListeners();
  }

  /// Si pasas [t], actualiza umbrales y calcula con esos valores.
  Future<void> load([Thresholds? t]) async {
    if (t != null) _thresholds = t;

    _loading = true;
    notifyListeners();

    try {
      final List<dom.FinanceTx> tx = await _listTx();
      final List<Debt> debts = await _listDebts();

      // ✅ Tus montos en DB son positivos: distingue por 'type'
      final double incomes = tx
          .where((e) => e.type == 'income')
          .fold<double>(0, (s, e) => s + e.amount);

      final double expenses = tx
          .where((e) => e.type == 'expense')
          .fold<double>(0, (s, e) => s + e.amount);

      // Ahorro (%) = (ingresos - gastos) / ingresos * 100   (clamp para evitar NaN)
      final double savingsRate = incomes <= 0
          ? 0.0
          : (((incomes - expenses) / incomes) * 100).clamp(0, 999).toDouble();

      // Días de atraso promedio (solo deudas no pagadas)
      final List<Debt> unpaid = debts.where((d) => !d.paid).toList();
      final List<int> dpdList = unpaid
          .map((d) => _daysPastDue(d.dueDate))
          .toList();
      final int dpd = dpdList.isEmpty
          ? 0
          : (dpdList.reduce((a, b) => a + b) / dpdList.length).round();

      // DTI (%) = suma de cuotas mensuales / ingresos * 100
      final double monthlyDebt = debts.fold<double>(0, (s, d) => s + d.amount);

      final double dti = incomes <= 0
          ? 0.0
          : (monthlyDebt / incomes * 100).clamp(0, 999).toDouble();

      // Utilización (%) = total_debt / credit_limit * 100
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

      result = calculateScore(factors!, _thresholds);
      score = result!.score;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

int _daysPastDue(DateTime dueDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  return today.isAfter(due) ? today.difference(due).inDays : 0;
}
