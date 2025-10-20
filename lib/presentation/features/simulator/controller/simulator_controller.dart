import 'package:flutter/foundation.dart';
import '../../../../application/usecases/list_transactions.dart';
import '../../../../domain/entities/transaction.dart';

class SimulatorController extends ChangeNotifier {
  final ListTransactions _listTx;

  SimulatorController(this._listTx);

  List<FinanceTx> _items = [];
  List<FinanceTx> get items => _items;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _items = await _listTx();
    _loading = false;
    notifyListeners();
  }
}
