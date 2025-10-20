// list_debts.dart
import '../../domain/entities/debt.dart';
import '../../domain/repositories/debts_repository.dart';

class ListDebts {
  final DebtsRepository repo;
  ListDebts(this.repo);
  Future<List<Debt>> call() => repo.list();
}
