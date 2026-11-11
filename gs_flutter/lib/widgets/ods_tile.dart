import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/ods.dart';

/// Quadrado colorido com o número do ODS.
class OdsNumero extends StatelessWidget {
  const OdsNumero({super.key, required this.ods, this.tamanho = 34});

  final Ods ods;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ods.cor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${ods.numero}',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: tamanho * 0.42,
        ),
      ),
    );
  }
}

/// Versão compacta do ODS, usada no painel inicial.
class OdsChip extends StatelessWidget {
  const OdsChip({super.key, required this.ods});

  final Ods ods;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
      decoration: BoxDecoration(
        color: ods.cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ods.cor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OdsNumero(ods: ods, tamanho: 24),
          const SizedBox(width: 8),
          Text(
            ods.tituloCurto,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// Versão completa do ODS com título e descrição.
class OdsTile extends StatelessWidget {
  const OdsTile({super.key, required this.ods});

  final Ods ods;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OdsNumero(ods: ods),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ODS ${ods.numero} • ${ods.titulo}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: ods.cor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  ods.descricao,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
