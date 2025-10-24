// lib/presentation/features/debts/controller/debts_controller.dart
import 'package:flutter/foundation.dart';

import '../../../../application/usecases/list_debts.dart';
import '../../../../application/usecases/add_debt.dart';
import '../../../../application/usecases/mark_debt_paid.dart';

// Use case de transacciones para registrar el gasto del pago
import '../../../../application/usecases/add_transaction.dart' as tx_uc;

import '../../../../domain/entities/debt.dart';
import '../../../../domain/entities/transaction.dart' as dom;

class DebtsController extends ChangeNotifier {
  final ListDebts _list;
  final AddDebt _add;
  final MarkDebtPaid _markPaid;
  final tx_uc.AddTransaction _addTx;

  DebtsController(this._list, this._add, this._markPaid, this._addTx);

  List<Debt> _items = const [];
  List<Debt> get items => _items;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  // ---------- CARGA ----------
  Future<void> load() async {
    _setLoading(true);
    try {
      _items = await _list();
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ---------- AGREGAR ----------
  Future<void> addDebt(Debt d) async {
    _setLoading(true);
    try {
      await _add(d);
      await load();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  // ---------- MARCAR COMO PAGADA (sin registrar gasto) ----------
  Future<void> markAsPaid(String id) async {
    _setLoading(true);
    try {
      await _markPaid(id);
      await load();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  // ---------- REGISTRAR GASTO + MARCAR COMO PAGADA ----------
  /// Crea una transacción de gasto por el pago de la deuda y luego marca la deuda como pagada.
  /// - [d]: deuda a pagar.
  /// - [amount]: por defecto usa d.amount (cuota).
  /// - [category]: etiqueta de la transacción (por defecto 'debt').
  /// - [note]: nota opcional para la transacción.
  /// - [when]: fecha del pago, por defecto DateTime.now().
  Future<void> payAndMarkPaid(
    Debt d, {
    double? amount,
    String category = 'debt',
    String? note,
    DateTime? when,
  }) async {
    _setLoading(true);
    try {
      // 1) Registrar el gasto (monto POSITIVO; type='expense')
      await _addTx(
        dom.FinanceTx(
          id: '',
          type: 'expense',
          amount: amount ?? d.amount,
          category: category,
          date: when ?? DateTime.now(),
          note: note ?? 'Pago deuda ${d.title}',
        ),
      );

      // 2) Marcar la deuda como pagada
      await _markPaid(d.id);

      // 3) Refrescar
      await load();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  // ---------- helpers ----------
  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }
}
