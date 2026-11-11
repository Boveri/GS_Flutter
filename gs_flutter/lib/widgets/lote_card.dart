import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/lote.dart';
import 'impacto_material_box.dart';
import 'status_badge.dart';

/// Card de um lote na lista de Lotes & Rotas.
class LoteCard extends StatelessWidget {
  const LoteCard({
    super.key,
    required this.lote,
    required this.onTap,
    required this.onFavoritar,
  });

  final Lote lote;
  final VoidCallback onTap;
  final VoidCallback onFavoritar;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Protocolo #${lote.protocolo}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  StatusBadge(status: lote.status),
                  IconButton(
                    tooltip: lote.favorito
                        ? 'Remover dos favoritos'
                        : 'Adicionar aos favoritos',
                    visualDensity: VisualDensity.compact,
                    onPressed: onFavoritar,
                    icon: Icon(
                      lote.favorito ? Icons.star : Icons.star_border,
                      color: lote.favorito
                          ? AppColors.orange
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                lote.nomeLocal,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppColors.teal),
                  const SizedBox(width: 4),
                  Text(
                    'CEP ${Formatters.cep(lote.cep)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.schedule, size: 16, color: AppColors.teal),
                  const SizedBox(width: 4),
                  Text(
                    lote.horario,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ImpactoMaterialBox(lote: lote),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver Detalhes & Ações',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
