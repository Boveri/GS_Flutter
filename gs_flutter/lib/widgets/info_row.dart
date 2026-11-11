import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Linha com ícone + texto (e subtítulo opcional).
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icone,
    required this.texto,
    this.subtitulo,
    this.destaque = false,
    this.corIcone = AppColors.primary,
  });

  final IconData icone;
  final String texto;
  final String? subtitulo;
  final bool destaque;
  final Color corIcone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 22, color: corIcone),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  texto,
                  style: TextStyle(
                    fontSize: destaque ? 17 : 14,
                    fontWeight: destaque ? FontWeight.w700 : FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitulo != null)
                  Text(
                    subtitulo!,
                    style: const TextStyle(
                      fontSize: 12,
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
