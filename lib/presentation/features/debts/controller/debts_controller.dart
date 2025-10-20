import 'package:flutter/foundation.dart';
import '../../../../application/usecases/list_debts.dart';
import '../../../../application/usecases/add_debt.dart';
import '../../../../application/usecases/mark_debt_paid.dart';
import '../../../../domain/entities/debt.dart';

class DebtsController extends ChangeNotifier {
  final ListDebts _list;
  final AddDebt _add;
  final MarkDebtPaid _markPaid;

  DebtsController(this._list, this._add, this._markPaid);

  List<Debt> _items = [];
  List<Debt> get items => _items;
  bool _loading = false;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _items = await _list();
    _loading = false;
    notifyListeners();
  }

  Future<void> addDebt(Debt d) async {
    await _add(d);
    await load();
  }

  Future<void> markAsPaid(String id) async {
    await _markPaid(id);
    await load();
  }
}
