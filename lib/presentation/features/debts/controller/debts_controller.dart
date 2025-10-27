// lib/presentation/features/debts/controller/debts_controller.dart
import 'package:flutter/foundation.dart';

import '../../../../application/usecases/list_debts.dart';
import '../../../../application/usecases/add_debt.dart';
import '../../../../application/usecases/mark_debt_paid.dart';

// Use case de transacciones para registrar el gasto del pago
import '../../../../application/usecases/add_transaction.dart' as tx_uc;

import '../../../../domain/entities/debt.dart';
import '../../../../domain/entities/transaction.dart' as dom;
import '../../../../services/notifications_service.dart';

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

  int _version = 0;
  int get version => _version;

  bool _remindersEnabled = false;
  bool get remindersEnabled => _remindersEnabled;

  void setRemindersEnabled(bool v) {
    if (_remindersEnabled == v) return;
    _remindersEnabled = v;
    // Sincroniza en background para no bloquear UI
    Future.microtask(() => syncNotifications());
  }

  // ---------- CARGA ----------
  Future<void> load() async {
    _setLoading(true);
    try {
      _items = await _list();
      _setError(null);
      await syncNotifications();
      _version++;
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
      // Programar notificaciones para la nueva deuda
      if (!d.paid && _remindersEnabled) {
        await NotificationsService.instance.scheduleForDebt(
          debtId: d.id,
          title: 'Pago de ${d.title}',
          dueDate: d.dueDate,
        );
      }
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
      // Cancelar notificaciones para la deuda pagada
      await NotificationsService.instance.cancelForDebt(id);
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
      // Cancelar notificaciones (ya se pagó)
      await NotificationsService.instance.cancelForDebt(d.id);
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

  /// Sincroniza notificaciones según preferencia actual y deudas activas
  Future<void> syncNotifications() async {
    final active = _items.where((e) => !e.paid);
    if (_remindersEnabled) {
      for (final d in active) {
        await NotificationsService.instance.scheduleForDebt(
          debtId: d.id,
          title: 'Pago de ${d.title}',
          dueDate: d.dueDate,
        );
      }
    } else {
      for (final d in active) {
        await NotificationsService.instance.cancelForDebt(d.id);
      }
    }
  }
}
