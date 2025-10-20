// debts_repository.dart
import '../entities/debt.dart';

abstract class DebtsRepository {
  Future<List<Debt>> list();
  Future<void> add(Debt debt);
  Future<void> markPaid(String id);
  Future<void> clearAll();
}
