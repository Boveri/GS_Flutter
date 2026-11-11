import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/onboarding_item.dart';

/// Página individual da introdução: ícone, título e descrição.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, required this.item});

  final OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: item.cor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: item.cor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icone, size: 64, color: item.cor),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            item.titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.descricao,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
