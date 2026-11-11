import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Objetivo de Desenvolvimento Sustentável atendido pelo projeto.
class Ods {
  const Ods({
    required this.numero,
    required this.titulo,
    required this.tituloCurto,
    required this.descricao,
    required this.cor,
  });

  final int numero;
  final String titulo;
  final String tituloCurto;
  final String descricao;
  final Color cor;

  static const List<Ods> doProjeto = [
    Ods(
      numero: 10,
      titulo: 'Redução das Desigualdades',
      tituloCurto: 'Redução Desigualdades',
      descricao: 'Gera renda direta, previsibilidade de rota e dignidade de '
          'trabalho para coletores autônomos e cooperativas.',
      cor: AppColors.ods10,
    ),
    Ods(
      numero: 11,
      titulo: 'Cidades e Comunidades Sustentáveis',
      tituloCurto: 'Cidades Sustentáveis',
      descricao: 'Evita o acúmulo de caixas e resíduos nas calçadas, '
          'organizando a zeladoria e a logística reversa nos bairros.',
      cor: AppColors.ods11,
    ),
    Ods(
      numero: 13,
      titulo: 'Ação Contra a Mudança Global do Clima',
      tituloCurto: 'Ação Climática',
      descricao: 'Amplia o volume de reciclagem efetiva e contabiliza a '
          'redução da pegada de carbono (CO₂ evitado).',
      cor: AppColors.ods13,
    ),
  ];
}
