import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Card branco com título e ícone, usado para agrupar blocos de conteúdo.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.titulo,
    required this.child,
    this.icone,
    this.corIcone = AppColors.teal,
    this.acao,
    this.corFundo,
  });

  final String titulo;
  final IconData? icone;
  final Color corIcone;
  final Widget child;
  final Widget? acao;
  final Color? corFundo;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: corFundo,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icone != null) ...[
                  Icon(icone, size: 20, color: corIcone),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal,
                    ),
                  ),
                ),
                ?acao,
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
