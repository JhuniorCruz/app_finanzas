// transactions_repository.dart
import '../entities/transaction.dart';

abstract class TransactionsRepository {
  Future<List<FinanceTx>> list();
  Future<void> add(FinanceTx tx);
  Future<void> remove(String id);
  Future<void> clearAll();
}
