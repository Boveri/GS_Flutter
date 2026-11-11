import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

enum AlertBannerTipo { sucesso, erro, info }

/// Faixa de aviso que muda de cor conforme o estado (sucesso / erro / info).
class AlertBanner extends StatelessWidget {
  const AlertBanner({super.key, required this.mensagem, required this.tipo});

  final String mensagem;
  final AlertBannerTipo tipo;

  @override
  Widget build(BuildContext context) {
    final (cor, fundo, icone) = switch (tipo) {
      AlertBannerTipo.sucesso => (
          AppColors.primary,
          AppColors.primaryLight,
          Icons.check_circle,
        ),
      AlertBannerTipo.erro => (
          AppColors.red,
          AppColors.redLight,
          Icons.warning_amber_rounded,
        ),
      AlertBannerTipo.info => (
          AppColors.teal,
          AppColors.tealLight,
          Icons.info,
        ),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor),
      ),
      child: Row(
        children: [
          Icon(icone, color: cor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensagem,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: cor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
