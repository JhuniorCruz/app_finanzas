import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transactions_repository.dart';

class AddTransaction {
  final TransactionsRepository repo;
  AddTransaction(this.repo);
  Future<void> call(FinanceTx tx) => repo.add(tx);
}
