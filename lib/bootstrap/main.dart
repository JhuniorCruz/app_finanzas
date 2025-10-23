// lib/bootstrap/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:app_finanzas/core/theme/app_theme.dart';
import 'package:app_finanzas/presentation/app/di.dart';
import 'package:app_finanzas/presentation/app/router.dart';

// Rutas con nombre (pantallas modales desde el dashboard)
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

  // 1) Carga variables del entorno
  await dotenv.load(fileName: '.env');
  final supabaseUrl = (dotenv.env['SUPABASE_URL'] ?? '').trim();
  final supabaseAnonKey = (dotenv.env['SUPABASE_ANON_KEY'] ?? '').trim();
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception('Faltan SUPABASE_URL o SUPABASE_ANON_KEY en .env');
  }

  // 2) Inicializa Supabase (PKCE para deep-links en móvil)
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    // persistSession es true por defecto en v2; no se expone como opción.
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
    ),
  );

  // 3) DI (providers)
  final prefs = await SharedPreferences.getInstance();
  final providers = await buildProviders(prefs);

  // 4) Lanza la app
  runZonedGuarded(
    () => runApp(MultiProvider(providers: providers, child: const MyApp())),
    (error, stack) {
      // Opcional: loguear errores globales
      // debugPrint('Uncaught error: $error\n$stack');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control Financiero',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,

      // Limitar textScale para evitar overflows de UI
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

      // Rutas con nombre (navegación simple desde el dashboard)
      routes: {
        AppRoutes.addIncome: (_) => const AddIncomePage(),
        AppRoutes.addExpense: (_) => const AddExpensePage(),
        AppRoutes.addDebt: (_) => const AddDebtPage(),
      },

      // Generación dinámica (detalle de deuda con argumento)
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
