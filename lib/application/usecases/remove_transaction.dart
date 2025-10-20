import '../../domain/repositories/transactions_repository.dart';

class RemoveTransaction {
  final TransactionsRepository repo;
  RemoveTransaction(this.repo);
  Future<void> call(String id) => repo.remove(id);
}
