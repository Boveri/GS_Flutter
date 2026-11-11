import 'package:shared_preferences/shared_preferences.dart';

/// Acesso às preferências do usuário salvas localmente.
class PreferencesService {
  static const String _chaveOnboardingVisto = 'onboarding_visto';

  /// Indica se o usuário marcou "Não mostrar novamente" na introdução.
  Future<bool> onboardingFoiVisto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chaveOnboardingVisto) ?? false;
  }

  Future<void> salvarOnboardingVisto(bool visto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveOnboardingVisto, visto);
  }
}
