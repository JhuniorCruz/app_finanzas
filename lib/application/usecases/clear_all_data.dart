import '../../domain/repositories/debts_repository.dart';
import '../../domain/repositories/transactions_repository.dart';

class ClearAllData {
  final DebtsRepository debts;
  final TransactionsRepository txs;
  ClearAllData(this.debts, this.txs);

  Future<void> call() async {
    await txs.clearAll();
    await debts.clearAll();
  }
}
