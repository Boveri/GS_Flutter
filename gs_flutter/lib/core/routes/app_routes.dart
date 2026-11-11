/// Nomes das rotas nomeadas do aplicativo.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';

  /// Recebe como argumento o número do protocolo do lote (int).
  static const String loteDetalhe = '/lote-detalhe';

  /// Recebe como argumento um objeto ReciboColeta.
  static const String recibo = '/recibo';
}
