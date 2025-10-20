import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../datasources/local/local_storage.dart';
import '../dtos/app_state_dto.dart';
import '../dtos/transaction_dto.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  final LocalStorage storage;
  TransactionsRepositoryImpl(this.storage);

  @override
  Future<List<FinanceTx>> list() async {
    final raw = storage.readRaw();
    final state = raw == null
        ? AppStateDto.empty()
        : AppStateDto.fromJsonString(raw);
    return state.transactions
        .map(
          (t) => FinanceTx(
            id: t.id,
            type: t.type,
            category: t.category,
            amount: t.amount,
            date: DateTime.parse(t.date),
            note: t.note,
            gross: t.gross,
            net: t.net,
          ),
        )
        .toList();
  }

  AppStateDto _read() {
    final raw = storage.readRaw();
    return raw == null ? AppStateDto.empty() : AppStateDto.fromJsonString(raw);
  }

  Future<void> _write(AppStateDto s) => storage.writeRaw(s.toJsonString());

  @override
  Future<void> add(FinanceTx tx) async {
    final s = _read();
    final dto = TransactionDto(
      id: tx.id,
      type: tx.type,
      category: tx.category,
      amount: tx.amount,
      date: tx.date.toIso8601String(),
      note: tx.note,
      gross: tx.gross,
      net: tx.net,
    );
    await _write(
      AppStateDto(
        transactions: [...s.transactions, dto],
        debts: s.debts,
        profile: s.profile,
      ),
    );
  }

  @override
  Future<void> remove(String id) async {
    final s = _read();
    final updated = s.transactions.where((t) => t.id != id).toList();
    await _write(
      AppStateDto(transactions: updated, debts: s.debts, profile: s.profile),
    );
  }

  @override
  Future<void> clearAll() async {
    final s = _read();
    await _write(
      AppStateDto(transactions: const [], debts: s.debts, profile: s.profile),
    );
  }
}
