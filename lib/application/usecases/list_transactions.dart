import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transactions_repository.dart';

class ListTransactions {
  final TransactionsRepository repo;
  ListTransactions(this.repo);
  Future<List<FinanceTx>> call() => repo.list();
}
