import 'package:flutter/material.dart';

/// Conteúdo de uma página da introdução.
class OnboardingItem {
  const OnboardingItem({
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.cor,
  });

  final IconData icone;
  final String titulo;
  final String descricao;
  final Color cor;
}
