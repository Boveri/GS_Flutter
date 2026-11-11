import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/lote.dart';

/// Caixa com material, peso e impacto (CO₂ e receita) de um lote.
/// Reutilizada no card da lista e na tela de detalhes.
class ImpactoMaterialBox extends StatelessWidget {
  const ImpactoMaterialBox({super.key, required this.lote, this.grande = false});

  final Lote lote;
  final bool grande;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(grande ? 14 : 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: lote.material.cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              lote.material.icone,
              color: lote.material.cor,
              size: grande ? 26 : 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Material: ${lote.material.nome}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: grande ? 16 : 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Peso: ${Formatters.peso(lote.peso)} (Piso ≥ 10 kg OK)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.eco, size: 15, color: AppColors.primary),
                  const SizedBox(width: 3),
                  Text(
                    Formatters.co2(lote.co2Evitado),
                    style: TextStyle(
                      fontSize: grande ? 15 : 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                Formatters.moeda(lote.receitaEstimada),
                style: TextStyle(
                  fontSize: grande ? 16 : 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
