import 'package:app_finanzas/application/usecases/list_debts.dart';
import 'package:app_finanzas/application/usecases/list_transactions.dart';
import 'package:app_finanzas/core/utils/scoring.dart';
import 'package:app_finanzas/domain/entities/debt.dart';
import 'package:app_finanzas/domain/entities/transaction.dart';
import 'package:app_finanzas/domain/repositories/debts_repository.dart';
import 'package:app_finanzas/domain/repositories/transactions_repository.dart';
import 'package:app_finanzas/presentation/features/score/controller/score_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTransactionsRepository implements TransactionsRepository {
  _FakeTransactionsRepository(this._items);

  final List<FinanceTx> _items;

  @override
  Future<List<FinanceTx>> list() async => _items;

  @override
  Future<void> add(FinanceTx tx) {
    throw UnimplementedError();
  }

  @override
  Future<void> clearAll() {
    throw UnimplementedError();
  }

  @override
  Future<void> remove(String id) {
    throw UnimplementedError();
  }
}

class _FakeDebtsRepository implements DebtsRepository {
  _FakeDebtsRepository(this._items);

  final List<Debt> _items;

  @override
  Future<void> add(Debt debt) {
    throw UnimplementedError();
  }

  @override
  Future<void> clearAll() {
    throw UnimplementedError();
  }

  @override
  Future<List<Debt>> list() async => _items;

  @override
  Future<void> markPaid(String id) {
    throw UnimplementedError();
  }
}

void main() {
  group('ScoreController', () {
    test('calcula correctamente factores y puntajes para el mes y acumulado',
        () async {
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);

      final tx = <FinanceTx>[
        FinanceTx(
          id: 'inc-1',
          type: 'income',
          category: 'salary',
          amount: 2000,
          date: DateTime(now.year, now.month, now.day),
        ),
        FinanceTx(
          id: 'exp-1',
          type: 'expense',
          category: 'rent',
          amount: -800,
          date: DateTime(now.year, now.month, now.day),
        ),
        FinanceTx(
          id: 'inc-previous',
          type: 'income',
          category: 'bonus',
          amount: 1000,
          date: now.subtract(const Duration(days: 40)),
        ),
      ];

      final debts = <Debt>[
        Debt(
          id: 'debt-1',
          title: 'tarjeta',
          amount: 300,
          dueDate: DateTime(now.year, now.month, now.day),
          paid: false,
          totalDebt: 1200,
          creditLimit: 2000,
        ),
        Debt(
          id: 'debt-2',
          title: 'crédito',
          amount: 150,
          dueDate: now.add(const Duration(days: 40)),
          paid: false,
          totalDebt: 600,
          creditLimit: 1000,
        ),
      ];

      final controller = ScoreController(
        ListTransactions(_FakeTransactionsRepository(tx)),
        ListDebts(_FakeDebtsRepository(debts)),
      );

      await controller.load(forMonth: currentMonth);

      expect(controller.monthlyFactors, isNotNull);
      final monthly = controller.monthlyFactors!;
      expect(monthly.debtToIncome, closeTo(15, 0.0001));
      expect(monthly.savingsRate, closeTo(60, 0.0001));
      expect(monthly.utilization, closeTo(60, 0.0001));
      expect(controller.monthlyResult, isNotNull);
      expect(controller.monthlyResult!.score, 95);
      expect(
        controller.monthlyResult!.factors['utilization']!.status,
        'warning',
      );

      expect(controller.lifetimeFactors, isNotNull);
      final lifetime = controller.lifetimeFactors!;
      expect(lifetime.debtToIncome, closeTo(15, 0.0001));
      expect(lifetime.savingsRate, closeTo(73.3333, 0.001));
      expect(lifetime.utilization, closeTo(60, 0.0001));
      expect(controller.lifetimeResult, isNotNull);
      expect(controller.lifetimeResult!.score, 95);
    });
  });

  group('calculateScore', () {
    test('devuelve score óptimo con factores saludables', () {
      const factors = ScoreFactors(
        dpd: 0,
        debtToIncome: 10,
        utilization: 20,
        savingsRate: 40,
      );

      final result = calculateScore(factors, defaultThresholds);

      expect(result.score, 100);
      expect(result.status, 'good');
      expect(result.factors['dpd']!.status, 'good');
      expect(result.factors['debtToIncome']!.status, 'good');
      expect(result.factors['utilization']!.status, 'good');
      expect(result.factors['savings']!.status, 'good');
    });

    test('penaliza factores en zona de riesgo', () {
      const thresholds = Thresholds(
        debtToIncomeWarning: 30,
        utilizationWarning: 40,
        savingsTarget: 25,
      );

      const factors = ScoreFactors(
        dpd: 6,
        debtToIncome: 60,
        utilization: 80,
        savingsRate: 10,
      );

      final result = calculateScore(factors, thresholds);

      expect(result.score, lessThan(50));
      expect(result.status, 'danger');
      expect(result.factors['dpd']!.status, 'danger');
      expect(result.factors['debtToIncome']!.status, 'danger');
      expect(result.factors['utilization']!.status, 'danger');
      expect(result.factors['savings']!.status, 'danger');
    });
  });
}
