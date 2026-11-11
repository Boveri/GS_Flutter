import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Caixa de destaque com o protocolo e o PIN de 4 dígitos.
class PinBox extends StatelessWidget {
  const PinBox({super.key, required this.protocolo, required this.pin});

  final int protocolo;
  final String pin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Text(
            'NÚMERO DO PROTOCOLO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          Text(
            '#$protocolo',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.key, size: 18, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'CÓDIGO PIN (4 DÍGITOS)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          Text(
            pin.split('').join(' '),
            style: const TextStyle(
              fontSize: 34,
              letterSpacing: 4,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
