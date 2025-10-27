import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Data
//import 'package:app_finanzas/data/datasources/local/local_storage.dart';
//import 'package:app_finanzas/data/repositories/debts_repository_impl.dart';
//import 'package:app_finanzas/data/repositories/transactions_repository_impl.dart';
//import 'package:app_finanzas/data/repositories/profile_repository_impl.dart';

import 'package:app_finanzas/data/repositories/supabase_auth_repository.dart';

// Domain (interfaces si las necesitas tipadas)
import 'package:app_finanzas/domain/repositories/profile_repository.dart';

// Application / Usecases
import 'package:app_finanzas/application/usecases/list_debts.dart';
import 'package:app_finanzas/application/usecases/add_debt.dart';
import 'package:app_finanzas/application/usecases/mark_debt_paid.dart';
import 'package:app_finanzas/application/usecases/list_transactions.dart';
import 'package:app_finanzas/application/usecases/add_transaction.dart';
import 'package:app_finanzas/application/usecases/remove_transaction.dart';
import 'package:app_finanzas/application/usecases/get_profile.dart';
import 'package:app_finanzas/application/usecases/update_profile.dart';

// Presentation / Controllers
import 'package:app_finanzas/presentation/features/debts/controller/debts_controller.dart';
import 'package:app_finanzas/presentation/features/dashboard/controller/dashboard_controller.dart';
import 'package:app_finanzas/presentation/features/settings/controller/settings_controller.dart';
import 'package:app_finanzas/presentation/features/simulator/controller/simulator_controller.dart';
import 'package:app_finanzas/presentation/features/transactions/controller/transactions_controller.dart';
import 'package:app_finanzas/presentation/features/score/controller/score_controller.dart';

//import 'package:app_finanzas/data/repositories/auth_repository_impl.dart';
import 'package:app_finanzas/presentation/features/auth/controller/auth_controller.dart';

//SUPABASE
import 'package:app_finanzas/data/repositories/supabase_transactions_repository.dart';
import 'package:app_finanzas/data/repositories/supabase_debts_repository.dart';
import 'package:app_finanzas/data/repositories/supabase_profile_repository.dart';

Future<List<SingleChildWidget>> buildProviders(SharedPreferences prefs) async {
  //final storage = LocalStorage(prefs);

  // Repositorios REMOTOS
  final txRepo = SupabaseTransactionsRepository();
  final debtsRepo = SupabaseDebtsRepository();
  final ProfileRepository profileRepo = SupabaseProfileRepository();

  // Repositorios
  //final debtsRepo = DebtsRepositoryImpl(storage);
  //final txRepo = TransactionsRepositoryImpl(storage);
  // TIPAR como interfaz para evitar ambigüedades
  //final ProfileRepository profileRepo = ProfileRepositoryImpl(storage);

  // NUEVO: Auth
  //final authRepo = AuthRepositoryImpl(prefs);
  // Auth con Supabase
  final authRepo = SupabaseAuthRepository(prefs);

  // Use cases
  final listDebts = ListDebts(debtsRepo);
  final addDebtUC = AddDebt(debtsRepo);
  final markPaidUC = MarkDebtPaid(debtsRepo);

  final listTx = ListTransactions(txRepo);
  final addTx = AddTransaction(txRepo);
  final removeTx = RemoveTransaction(txRepo);

  final getProfile = GetProfile(profileRepo);
  final updateProfile = UpdateProfile(profileRepo);

  // Providers
  return [
    // NUEVO: AuthController (restaura sesión al crear)
    ChangeNotifierProvider(
      create: (_) => AuthController(authRepo)..checkSession(),
    ),

    // Settings depende de la sesión: carga perfil solo si está autenticado
    ChangeNotifierProxyProvider<AuthController, SettingsController>(
      create: (_) => SettingsController(getProfile.call, updateProfile.call),
      update: (_, auth, settings) {
        final controller =
            settings ?? SettingsController(getProfile.call, updateProfile.call);
        if (!auth.isAuthenticated) {
          controller.reset();
        } else if (!controller.busy && controller.profile == null) {
          controller.load();
        }
        return controller;
      },
    ),
    ChangeNotifierProxyProvider<SettingsController, DebtsController>(
      create: (_) => DebtsController(listDebts, addDebtUC, markPaidUC, addTx),
      update: (_, settings, debts) {
        final controller =
            debts ?? DebtsController(listDebts, addDebtUC, markPaidUC, addTx);
        final reminders = settings.profile?.reminders ?? false;
        controller.setRemindersEnabled(reminders);
        return controller;
      },
    ),
    ChangeNotifierProvider(create: (_) => DashboardController(listTx)),
    ChangeNotifierProvider(create: (_) => SimulatorController(listTx)),
    ChangeNotifierProvider(
      create: (_) => TransactionsController(
        listTx: listTx,
        addTx: addTx,
        removeTx: removeTx,
      ),
    ),
    ChangeNotifierProxyProvider3<SettingsController, TransactionsController,
        DebtsController, ScoreController>(
      create: (_) => ScoreController(listTx, listDebts),
      update: (_, settings, txVm, debtsVm, score) {
        final controller = score ?? ScoreController(listTx, listDebts);
        final thresholds = settings.thresholds;

        final thresholdsChanged =
            controller.thresholds.debtToIncomeWarning !=
                thresholds.debtToIncomeWarning ||
            controller.thresholds.utilizationWarning !=
                thresholds.utilizationWarning ||
            controller.thresholds.savingsTarget != thresholds.savingsTarget;

        final dataChanged =
            controller.monthlyFactors == null ||
            controller.lastSyncedTxVersion != txVm.version ||
            controller.lastSyncedDebtVersion != debtsVm.version;

        if (thresholdsChanged || dataChanged) {
          controller.load(
            thresholds: thresholds,
            txVersion: txVm.version,
            debtVersion: debtsVm.version,
          );
        }
        return controller;
      },
    ),
  ];
}
