import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_finanzas/core/theme/app_theme.dart';
import 'package:app_finanzas/presentation/app/di.dart';
import 'package:app_finanzas/presentation/app/router.dart';

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
      // (opcional) limita el textScale para evitar desbordes
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final clamped = mq.textScaleFactor.clamp(1.0, 1.2);
        return MediaQuery(
          data: mq.copyWith(textScaleFactor: clamped),
          child: child!,
        );
      },
      home: const AppShell(), // <<<<<<<< aquí
      debugShowCheckedModeBanner: false,
    );
  }
}
