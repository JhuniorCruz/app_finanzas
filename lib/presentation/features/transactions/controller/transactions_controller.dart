import 'package:flutter/material.dart'; // <- incluye UniqueKey y ChangeNotifier
import '../../../../application/usecases/add_transaction.dart';
import '../../../../application/usecases/remove_transaction.dart';
import '../../../../application/usecases/list_transactions.dart';
import '../../../../domain/entities/transaction.dart';

class TransactionsController extends ChangeNotifier {
  // Usa parámetros con nombre para evitar errores de orden
  final ListTransactions listTx;
  final AddTransaction addTx;
  final RemoveTransaction removeTx;

  TransactionsController({
    required this.listTx,
    required this.addTx,
    required this.removeTx,
  });

  bool _busy = false;
  bool get busy => _busy;

  List<FinanceTx> _items = [];
  List<FinanceTx> get items => _items;

  Future<void> load() async {
    _busy = true;
    notifyListeners();
    _items = await listTx();
    _busy = false;
    notifyListeners();
  }

  /// Agrega un **ingreso**.
  /// - [category]: 'recibo' | 'planilla' (o lo que uses en tu UI)
  /// - [gross]: ingreso bruto
  /// - [netAmount]: ingreso neto que se registrará como `amount` (positivo)
  Future<void> addIncome({
    required String category,
    required double gross,
    required double netAmount,
    DateTime? date,
  }) async {
    _busy = true;
    notifyListeners();

    final tx = FinanceTx(
      id: UniqueKey().toString(),
      type: 'income', // <- REQUERIDO
      category: category,
      amount: netAmount, // positivo = ingreso
      date: date ?? DateTime.now(),
      gross: gross,
      net: netAmount,
      note: null,
    );

    await addTx(tx);
    await load();

    _busy = false;
    notifyListeners();
  }

  /// Agrega un **gasto**.
  /// - [amount]: monto POSITIVO que se guardará como negativo en `amount`
  Future<void> addExpense({
    required String category,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    _busy = true;
    notifyListeners();

    final tx = FinanceTx(
      id: UniqueKey().toString(),
      type: 'expense', // <- REQUERIDO
      category: category,
      amount: -amount.abs(), // negativo = gasto
      date: date,
      note: note,
      gross: null,
      net: null,
    );

    await addTx(tx);
    await load();

    _busy = false;
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _busy = true;
    notifyListeners();
    await removeTx(id);
    await load();
    _busy = false;
    notifyListeners();
  }
}
