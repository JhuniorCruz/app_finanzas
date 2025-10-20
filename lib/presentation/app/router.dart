import 'package:flutter/material.dart';

import '../features/dashboard/view/dashboard_page.dart';
import '../features/debts/view/debts_page.dart';
import '../features/simulator/view/simulator_page.dart';
import '../features/settings/view/settings_page.dart';
import '../widgets/bottom_nav.dart';

/// Shell principal con BottomNav y persistencia de estado por tab.
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
    SimulatorPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cada tab mantiene su estado con IndexedStack
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNav(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
