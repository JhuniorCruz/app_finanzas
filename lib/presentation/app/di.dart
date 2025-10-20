import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/repositories/debts_repository_impl.dart';
import '../../data/repositories/transactions_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../application/usecases/list_debts.dart';
import '../../application/usecases/add_debt.dart';
import '../../application/usecases/mark_debt_paid.dart';
import '../../application/usecases/list_transactions.dart';
import '../../application/usecases/add_transaction.dart';
import '../../application/usecases/remove_transaction.dart';
import '../../application/usecases/get_profile.dart';
import '../../application/usecases/update_profile.dart';
import '../features/debts/controller/debts_controller.dart';
import '../features/dashboard/controller/dashboard_controller.dart';
import '../features/settings/controller/settings_controller.dart';
import '../features/simulator/controller/simulator_controller.dart';
import '../features/transactions/controller/transactions_controller.dart';
import '../features/score/controller/score_controller.dart';

import 'package:provider/single_child_widget.dart';

Future<List<SingleChildWidget>> buildProviders(SharedPreferences prefs) async {
  final storage = LocalStorage(prefs);

  // Repos
  final debtsRepo = DebtsRepositoryImpl(storage);
  final txRepo = TransactionsRepositoryImpl(storage);
  final profRepo = ProfileRepositoryImpl(storage);

  // UseCases
  final listDebts = ListDebts(debtsRepo);
  final addDebtUC = AddDebt(debtsRepo);
  final markPaidUC = MarkDebtPaid(debtsRepo);

  final listTx = ListTransactions(txRepo);
  final addTx = AddTransaction(txRepo);
  final removeTx = RemoveTransaction(txRepo);

  final getProfile = GetProfile(profRepo);
  final updateProfile = UpdateProfile(profRepo);

  return [
    // Controllers (ChangeNotifier)
    ChangeNotifierProvider(
      create: (_) => DebtsController(listDebts, addDebtUC, markPaidUC),
    ),
    ChangeNotifierProvider(create: (_) => DashboardController(listTx)),
    ChangeNotifierProvider(
      create: (_) => SettingsController(getProfile, updateProfile),
    ),
    ChangeNotifierProvider(
      create: (_) => SimulatorController(listTx),
    ), // si tu simulador lee transacciones
    ChangeNotifierProvider(
      create: (_) => TransactionsController(
        listTx: listTx,
        addTx: addTx,
        removeTx: removeTx,
      ),
    ),
    ChangeNotifierProvider(create: (_) => ScoreController(listTx, listDebts)),
  ];
}
