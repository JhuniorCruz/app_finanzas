// mark_debt_paid.dart
import '../../domain/repositories/debts_repository.dart';

class MarkDebtPaid {
  final DebtsRepository repo;
  MarkDebtPaid(this.repo);
  Future<void> call(String id) => repo.markPaid(id);
}
