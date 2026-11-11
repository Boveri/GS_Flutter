import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/recibo_coleta.dart';
import '../widgets/app_logo.dart';
import '../widgets/info_row.dart';
import '../widgets/stat_card.dart';

/// Certificado de impacto exibido após a baixa da coleta.
/// Recebe um [ReciboColeta] como parâmetro de navegação.
class ReciboScreen extends StatelessWidget {
  const ReciboScreen({super.key, required this.recibo});

  final ReciboColeta recibo;

  @override
  Widget build(BuildContext context) {
    final lote = recibo.lote;

    return Scaffold(
      appBar: AppBar(title: const Text('Certificado de Impacto')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const AppLogo(tamanho: 72),
                  const SizedBox(height: 12),
                  const Text(
                    'Coleta Concluída!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Protocolo #${lote.protocolo} • '
                    '${Formatters.dataHora(recibo.dataColeta)}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icone: Icons.scale,
                          valor: Formatters.peso(recibo.pesoColetado),
                          rotulo: 'Coletado',
                          cor: AppColors.primary,
                          corFundo: AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          icone: Icons.eco,
                          valor: Formatters.peso(recibo.co2Evitado),
                          rotulo: 'CO₂ Evitado',
                          cor: AppColors.teal,
                          corFundo: AppColors.tealLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          icone: Icons.monetization_on,
                          valor: Formatters.moeda(recibo.valorEstimado),
                          rotulo: 'Ganho',
                          cor: AppColors.orange,
                          corFundo: AppColors.orangeLight,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  InfoRow(icone: Icons.apartment, texto: lote.nomeLocal),
                  InfoRow(
                    icone: lote.material.icone,
                    texto: 'Material: ${lote.material.nome} '
                        '(${Formatters.moeda(lote.material.cotacaoPorKg)}/kg)',
                  ),
                  InfoRow(
                    icone: Icons.location_on,
                    texto: 'CEP ${Formatters.cep(lote.cep)}',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Obrigado! Esta coleta contribui com os ODS 10, 11 e 13 '
                      'da Agenda 2030 da ONU.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Voltar ao lote'),
          ),
        ],
      ),
    );
  }
}
