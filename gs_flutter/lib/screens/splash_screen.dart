import 'dart:async';

import 'package:flutter/material.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../services/preferences_service.dart';
import '../widgets/app_logo.dart';

/// Splash: exibe o logo e decide se vai para a introdução ou para a Home
/// conforme a preferência salva no SharedPreferences.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _duracaoMinima = Duration(milliseconds: 2200);

  final PreferencesService _preferencesService = PreferencesService();

  @override
  void initState() {
    super.initState();
    _decidirProximaTela();
  }

  Future<void> _decidirProximaTela() async {
    final resultados = await Future.wait([
      _preferencesService.onboardingFoiVisto(),
      Future<void>.delayed(_duracaoMinima),
    ]);
    final jaViuIntroducao = resultados.first as bool;

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      jaViuIntroducao ? AppRoutes.home : AppRoutes.onboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutBack,
                builder: (context, escala, child) =>
                    Transform.scale(scale: escala, child: child),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const AppLogo(tamanho: 140),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'ColetaAgendada',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Recicláveis limpos, coleta na hora certa.',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const Spacer(),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'CitizenTech • Global Solution 2026',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
