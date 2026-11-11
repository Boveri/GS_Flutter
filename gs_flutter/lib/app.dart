import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'models/recibo_coleta.dart';
import 'screens/home_shell.dart';
import 'screens/lote_detalhe_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/recibo_screen.dart';
import 'screens/splash_screen.dart';

/// Widget raiz: tema e rotas nomeadas.
class ColetaAgendadaApp extends StatelessWidget {
  const ColetaAgendadaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ColetaAgendada',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: _gerarRota,
    );
  }

  /// Centraliza a criação das rotas e a leitura dos parâmetros.
  static Route<dynamic> _gerarRota(RouteSettings settings) {
    final Widget tela;
    switch (settings.name) {
      case AppRoutes.splash:
        tela = const SplashScreen();
      case AppRoutes.onboarding:
        tela = const OnboardingScreen();
      case AppRoutes.home:
        tela = const HomeShell();
      case AppRoutes.loteDetalhe:
        tela = LoteDetalheScreen(protocolo: settings.arguments as int);
      case AppRoutes.recibo:
        tela = ReciboScreen(recibo: settings.arguments as ReciboColeta);
      default:
        tela = const HomeShell();
    }
    return MaterialPageRoute(builder: (_) => tela, settings: settings);
  }
}
