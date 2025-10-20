import '../../domain/entities/debt.dart';
import '../../domain/repositories/debts_repository.dart';

class AddDebt {
  final DebtsRepository repo;
  AddDebt(this.repo);
  Future<void> call(Debt debt) => repo.add(debt);
}
