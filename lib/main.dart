import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login/iniciosesion.dart';
import 'pantallas/principal.dart';
import 'core/theme/app_theme.dart';
import 'features/matches/application/providers/match_provider.dart';
import 'features/statistics/application/providers/statistics_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
      ],
      child: MaterialApp(
        title: 'Soccer Life',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const InicioSesionPage(),
          '/home': (context) => const PrincipalPage(),
        },
      ),
    );
  }
}
