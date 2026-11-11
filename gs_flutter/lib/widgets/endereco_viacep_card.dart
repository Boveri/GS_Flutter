import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/view_state.dart';
import '../models/endereco.dart';

/// Exibe o resultado da consulta ao WebService ViaCEP nos 4 estados:
/// inicial, carregamento, sucesso e erro (com opção de tentar novamente).
class EnderecoViaCepCard extends StatelessWidget {
  const EnderecoViaCepCard({
    super.key,
    required this.estado,
    required this.onRetry,
    this.endereco,
    this.mensagemErro,
    this.mensagemInicial = 'Informe o CEP e toque em "Buscar CEP" para '
        'preencher o endereço automaticamente.',
  });

  final ViewState estado;
  final Endereco? endereco;
  final String? mensagemErro;
  final String mensagemInicial;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(estado),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _corFundo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _corBorda),
        ),
        child: _conteudo(),
      ),
    );
  }

  Color get _corFundo => switch (estado) {
        ViewState.initial => AppColors.background,
        ViewState.loading => AppColors.background,
        ViewState.success => AppColors.primaryLight,
        ViewState.error => AppColors.redLight,
      };

  Color get _corBorda => switch (estado) {
        ViewState.success => AppColors.primarySoft,
        ViewState.error => const Color(0xFFFFCDD2),
        _ => AppColors.border,
      };

  Widget _conteudo() {
    switch (estado) {
      case ViewState.initial:
        return Row(
          children: [
            const Icon(Icons.travel_explore, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                mensagemInicial,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        );
      case ViewState.loading:
        return const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            SizedBox(width: 12),
            Text(
              'Consultando ViaCEP...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        );
      case ViewState.success:
        final e = endereco!;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.linhaPrincipal,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (e.complemento.isNotEmpty)
                    Text(
                      e.complemento,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    e.linhaSecundaria,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.teal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Fonte: ViaCEP',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case ViewState.error:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: AppColors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    mensagemErro ?? 'Não foi possível consultar o CEP.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, color: AppColors.red),
                label: const Text(
                  'Tentar novamente',
                  style: TextStyle(color: AppColors.red),
                ),
              ),
            ),
          ],
        );
    }
  }
}
