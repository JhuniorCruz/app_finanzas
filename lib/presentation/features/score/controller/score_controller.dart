// lib/presentation/features/score/controller/score_controller.dart
import 'package:flutter/foundation.dart';

import '../../../../application/usecases/list_transactions.dart';
import '../../../../application/usecases/list_debts.dart';
import '../../../../domain/entities/transaction.dart' as dom;
import '../../../../domain/entities/debt.dart' as dom;
import '../../../../core/utils/formatters.dart' show getDaysPastDue;
import '../../../../core/utils/scoring.dart';

class ScoreController extends ChangeNotifier {
  final ListTransactions _listTx;
  final ListDebts _listDebts;

  ScoreController(this._listTx, this._listDebts);

  bool _loading = false;
  bool get loading => _loading;

  /// Umbrales vigentes (vienen de Settings; si no hay, usa defaults)
  Thresholds _thresholds = defaultThresholds;
  Thresholds get thresholds => _thresholds;

  int _lastSyncedTxVersion = -1;
  int _lastSyncedDebtVersion = -1;
  int get lastSyncedTxVersion => _lastSyncedTxVersion;
  int get lastSyncedDebtVersion => _lastSyncedDebtVersion;

  bool _reloadQueued = false;
  Thresholds? _queuedThresholds;
  int? _queuedTxVersion;
  int? _queuedDebtVersion;

  // ---------- RESULTADOS DEL MES ACTUAL ----------
  ScoreFactors? _monthlyFactors;
  ScoreResult? _monthlyResult;

  ScoreFactors? get monthlyFactors => _monthlyFactors;
  ScoreResult? get monthlyResult => _monthlyResult;
  int get monthlyScore => _monthlyResult?.score ?? 0;

  // ---------- RESULTADOS HISTÓRICOS (vida útil) ----------
  ScoreFactors? _lifetimeFactors;
  ScoreResult? _lifetimeResult;

  ScoreFactors? get lifetimeFactors => _lifetimeFactors;
  ScoreResult? get lifetimeResult => _lifetimeResult;
  int get lifetimeScore => _lifetimeResult?.score ?? 0;

  // ---------- ALIAS de compatibilidad (si en algún sitio usas "total*") ----------
  ScoreFactors? get totalFactors => _lifetimeFactors;
  ScoreResult? get totalResult => _lifetimeResult;
  int get totalScore => lifetimeScore;

  // ---------------- Utils ----------------
  double _safePct(num nume, num den) {
    if (den <= 0) return 0;
    final v = (nume / den) * 100.0;
    return (v.isFinite ? v : 0).clamp(0, 999).toDouble();
  }

  double _savingsRate(num incomes, num expensesAbs) {
    return incomes <= 0
        ? 0.0
        : (((incomes - expensesAbs) / incomes) * 100).clamp(0, 999).toDouble();
  }

  double _utilization(List<dom.Debt> debts) {
    // Solo deudas activas con línea
    final active = debts
        .where((d) => !d.paid && (d.creditLimit ?? 0) > 0)
        .toList();
    if (active.isEmpty) return 0.0;

    final used = active.fold<double>(0, (s, d) => s + d.totalDebt);
    final limit = active.fold<double>(0, (s, d) => s + (d.creditLimit ?? 0));
    return _safePct(used, limit);
  }

  /// Carga transacciones y deudas y calcula:
  /// - score mensual (mes de [forMonth], por defecto: ahora)
  /// - score histórico (sobre todo el dataset)
  Future<void> load({
    Thresholds? thresholds,
    DateTime? forMonth,
    int? txVersion,
    int? debtVersion,
  }) async {
    if (_loading) {
      _reloadQueued = true;
      if (thresholds != null) _queuedThresholds = thresholds;
      if (txVersion != null) _queuedTxVersion = txVersion;
      if (debtVersion != null) _queuedDebtVersion = debtVersion;
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      if (thresholds != null) _thresholds = thresholds;

      final List<dom.FinanceTx> tx = await _listTx();
      final List<dom.Debt> debts = await _listDebts();

      final base = forMonth ?? DateTime.now();
      final m = base.month, y = base.year;

      // ===== MES ACTUAL =====
      final monthTx = tx
          .where((e) => e.date.month == m && e.date.year == y)
          .toList();

      final incomesM = monthTx
          .where((t) => t.type == 'income')
          .fold<double>(0, (s, t) => s + t.amount);

      // Por robustez, sumamos ABS por si tienes gastos antiguos negativos
      final expensesAbsM = monthTx
          .where((t) => t.type == 'expense')
          .fold<double>(0, (s, t) => s + t.amount.abs());

      final savingsM = _savingsRate(incomesM, expensesAbsM);

      final monthlyDebts = debts
          .where((d) => !d.paid && d.dueDate.month == m && d.dueDate.year == y)
          .toList();

      final installmentsM = monthlyDebts.fold<double>(
        0,
        (s, d) => s + d.amount,
      );

      final dtiM = _safePct(installmentsM, incomesM);

      final dpdM = monthlyDebts.isEmpty
          ? 0
          : (monthlyDebts
                        .map((d) => getDaysPastDue(d.dueDate))
                        .reduce((a, b) => a + b) /
                    monthlyDebts.length)
                .round();

      final utilM = _utilization(debts);

      _monthlyFactors = ScoreFactors(
        dpd: dpdM,
        debtToIncome: dtiM,
        utilization: utilM,
        savingsRate: savingsM,
      );
      _monthlyResult = calculateScore(_monthlyFactors!, _thresholds);

      // ===== HISTÓRICO TOTAL =====
      final incomesT = tx
          .where((t) => t.type == 'income')
          .fold<double>(0, (s, t) => s + t.amount);

      final expensesAbsT = tx
          .where((t) => t.type == 'expense')
          .fold<double>(0, (s, t) => s + t.amount.abs());

      final savingsT = _savingsRate(incomesT, expensesAbsT);

      final activeDebts = debts.where((d) => !d.paid).toList();
      final installmentsAll = activeDebts.fold<double>(
        0,
        (s, d) => s + d.amount,
      );

      final dtiT = _safePct(installmentsAll, incomesT);

      final dpdT = activeDebts.isEmpty
          ? 0
          : (activeDebts
                        .map((d) => getDaysPastDue(d.dueDate))
                        .reduce((a, b) => a + b) /
                    activeDebts.length)
                .round();

      final utilT = _utilization(debts);

      _lifetimeFactors = ScoreFactors(
        dpd: dpdT,
        debtToIncome: dtiT,
        utilization: utilT,
        savingsRate: savingsT,
      );
      _lifetimeResult = calculateScore(_lifetimeFactors!, _thresholds);

      if (txVersion != null) _lastSyncedTxVersion = txVersion;
      if (debtVersion != null) _lastSyncedDebtVersion = debtVersion;
    } finally {
      _loading = false;
      notifyListeners();

      if (_reloadQueued) {
        final nextThresholds = _queuedThresholds;
        final nextTx = _queuedTxVersion;
        final nextDebt = _queuedDebtVersion;
        _reloadQueued = false;
        _queuedThresholds = null;
        _queuedTxVersion = null;
        _queuedDebtVersion = null;
        await load(
          thresholds: nextThresholds ?? _thresholds,
          txVersion: nextTx ?? _lastSyncedTxVersion,
          debtVersion: nextDebt ?? _lastSyncedDebtVersion,
        );
      }
    }
  }
}
