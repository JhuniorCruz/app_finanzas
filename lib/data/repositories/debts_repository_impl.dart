import '../../domain/entities/debt.dart';
import '../../domain/repositories/debts_repository.dart';
import '../datasources/local/local_storage.dart';
import '../dtos/app_state_dto.dart';
import '../dtos/debt_dto.dart';

class DebtsRepositoryImpl implements DebtsRepository {
  final LocalStorage storage;
  DebtsRepositoryImpl(this.storage);

  AppStateDto _read() {
    final raw = storage.readRaw();
    return raw == null ? AppStateDto.empty() : AppStateDto.fromJsonString(raw);
  }

  Future<void> _write(AppStateDto s) => storage.writeRaw(s.toJsonString());

  @override
  Future<List<Debt>> list() async {
    final s = _read();
    return s.debts
        .map(
          (d) => Debt(
            id: d.id,
            title: d.title,
            amount: d.amount,
            dueDate: DateTime.parse(d.dueDate),
            paid: d.paid,
            totalDebt: d.totalDebt,
            creditLimit: d.creditLimit,
          ),
        )
        .toList();
  }

  @override
  Future<void> add(Debt debt) async {
    final s = _read();
    final dto = DebtDto(
      id: debt.id,
      title: debt.title,
      amount: debt.amount,
      dueDate: debt.dueDate.toIso8601String(),
      paid: debt.paid,
      totalDebt: debt.totalDebt,
      creditLimit: debt.creditLimit,
    );
    await _write(
      AppStateDto(
        transactions: s.transactions,
        debts: [...s.debts, dto],
        profile: s.profile,
      ),
    );
  }

  @override
  Future<void> markPaid(String id) async {
    final s = _read();
    final updated = s.debts
        .map(
          (d) => d.id == id
              ? DebtDto(
                  id: d.id,
                  title: d.title,
                  amount: d.amount,
                  dueDate: d.dueDate,
                  paid: true,
                  totalDebt: d.totalDebt,
                  creditLimit: d.creditLimit,
                )
              : d,
        )
        .toList();
    await _write(
      AppStateDto(
        transactions: s.transactions,
        debts: updated,
        profile: s.profile,
      ),
    );
  }

  @override
  Future<void> clearAll() async {
    final s = _read();
    await _write(
      AppStateDto(
        transactions: s.transactions,
        debts: const [],
        profile: s.profile,
      ),
    );
  }
}
