import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_finanzas/core/theme/app_theme.dart';
import 'package:app_finanzas/presentation/app/di.dart';
import 'package:app_finanzas/presentation/app/router.dart';

// Rutas con nombre
import 'package:app_finanzas/presentation/features/transactions/view/add_income_page.dart';
import 'package:app_finanzas/presentation/features/transactions/view/add_expense_page.dart';
import 'package:app_finanzas/presentation/features/debts/view/add_debt_page.dart';
import 'package:app_finanzas/presentation/features/debts/view/debt_detail_page.dart';

class AppRoutes {
  static const addIncome = '/addIncome';
  static const addExpense = '/addExpense';
  static const addDebt = '/addDebt';
  static const debtDetail = '/debtDetail';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final providers = await buildProviders(prefs);
  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control Financiero',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaleFactor: mq.textScaleFactor.clamp(1.0, 1.2),
          ),
          child: child!,
        );
      },

      // Router raíz que decide AuthFlow vs AppShell
      home: const AppRouter(),

      // rutas con nombre que se usan desde el dashboard/etc
      routes: {
        AppRoutes.addIncome: (_) => const AddIncomePage(),
        AppRoutes.addExpense: (_) => const AddExpensePage(),
        AppRoutes.addDebt: (_) => const AddDebtPage(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.debtDetail) {
          final id = settings.arguments as String;
          return MaterialPageRoute(builder: (_) => DebtDetailPage(debtId: id));
        }
        return null;
      },
    );
  }
}
