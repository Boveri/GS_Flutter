import 'package:flutter/material.dart';

/// Tipos de material aceitos, com a cotação por kg definida nas regras de
/// negócio (Papelão R$ 0,80 | Plástico R$ 1,50 | Alumínio R$ 6,00 |
/// Vidro R$ 0,40).
enum MaterialReciclavel {
  papelao('PAPELAO', 'Papelão', 0.80, Icons.inventory_2_outlined, Color(0xFF8D6E63)),
  plastico('PLASTICO', 'Plástico', 1.50, Icons.local_drink_outlined, Color(0xFFD32F2F)),
  aluminio('ALUMINIO', 'Alumínio', 6.00, Icons.recycling, Color(0xFFF9A825)),
  vidro('VIDRO', 'Vidro', 0.40, Icons.wine_bar_outlined, Color(0xFF2E7D32));

  const MaterialReciclavel(
    this.codigo,
    this.nome,
    this.cotacaoPorKg,
    this.icone,
    this.cor,
  );

  /// Valor persistido (equivalente à coluna `tp_material`).
  final String codigo;
  final String nome;
  final double cotacaoPorKg;
  final IconData icone;
  final Color cor;

  static MaterialReciclavel fromCodigo(String codigo) {
    return MaterialReciclavel.values.firstWhere(
      (m) => m.codigo == codigo,
      orElse: () => MaterialReciclavel.papelao,
    );
  }
}
