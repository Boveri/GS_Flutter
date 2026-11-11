import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Ciclo de vida do lote: DISPONIVEL -> RESERVADO -> COLETADO.
enum StatusLote {
  disponivel('DISPONIVEL', 'Disponível', AppColors.primary, AppColors.primaryLight, Icons.circle),
  reservado('RESERVADO', 'Reservado', AppColors.orange, AppColors.orangeLight, Icons.schedule),
  coletado('COLETADO', 'Coletado', AppColors.blue, AppColors.blueLight, Icons.check_circle);

  const StatusLote(
    this.codigo,
    this.rotulo,
    this.cor,
    this.corFundo,
    this.icone,
  );

  /// Valor persistido (equivalente à coluna `st_lote`).
  final String codigo;
  final String rotulo;
  final Color cor;
  final Color corFundo;
  final IconData icone;

  static StatusLote fromCodigo(String codigo) {
    return StatusLote.values.firstWhere(
      (s) => s.codigo == codigo,
      orElse: () => StatusLote.disponivel,
    );
  }
}
