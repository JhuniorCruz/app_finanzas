import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/dashboard/view/dashboard_page.dart';
import '../features/debts/view/debts_page.dart';
import '../features/simulator/view/simulator_page.dart';
import '../features/settings/view/settings_page.dart';
import '../features/advisor/view/advisor_page.dart';
import '../widgets/bottom_nav.dart';

// Auth pages (flujo)
import '../features/auth/view/login_page.dart';
import '../features/auth/view/register_page.dart';
import '../features/auth/view/forgot_password_page.dart';

// Controller
import '../features/auth/controller/auth_controller.dart';

/// Decide si mostrar AuthFlow o AppShell según el estado de sesión.
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    // Mientras restaura sesión de SharedPreferences (checkSession)
    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Si está logueado → AppShell; si no → AuthFlow
    return auth.isLoggedIn ? const AppShell() : const _AuthFlow();
  }
}

/// Navigator independiente para /login → /register → /forgot.
class _AuthFlow extends StatelessWidget {
  const _AuthFlow();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(
              builder: (_) => const LoginPage(),
              settings: settings,
            );
          case '/register':
            return MaterialPageRoute(
              builder: (_) => const RegisterPage(),
              settings: settings,
            );
          case '/forgot':
            return MaterialPageRoute(
              builder: (_) => const ForgotPasswordPage(),
              settings: settings,
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const LoginPage(),
              settings: settings,
            );
        }
      },
    );
  }
}

/// Zona autenticada con BottomNav (mantiene estado por pestaña).
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _pages = const [
    DashboardPage(),
    DebtsPage(),
    AdvisorPage(),
    SimulatorPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNav(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
