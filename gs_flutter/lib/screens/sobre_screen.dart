import 'package:flutter/material.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../models/integrante.dart';
import '../models/ods.dart';
import '../services/lote_service.dart';
import '../services/preferences_service.dart';
import '../widgets/ods_tile.dart';
import '../widgets/page_header_banner.dart';
import '../widgets/section_card.dart';

/// Informações do projeto: equipe, ODS, regras de negócio e configurações.
class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  static const List<(String, String)> _diferenciais = [
    (
      'Trava Logística (Piso de 10 kg)',
      'Garante que o deslocamento do coletor sempre compense financeiramente.',
    ),
    (
      'Reserva Exclusiva de Rota',
      'Quando um coletor reserva o lote, ele sai do radar dos demais.',
    ),
    (
      'Check-in por PIN de 4 Dígitos',
      'Segurança na portaria e nenhuma baixa falsa no sistema.',
    ),
    (
      'Impacto calculado na hora',
      'CO₂ evitado = peso × 1,5 • Receita = peso × cotação do material.',
    ),
  ];

  Future<void> _reverIntroducao(BuildContext context) async {
    await PreferencesService().salvarOnboardingVisto(false);
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.onboarding,
      (route) => false,
    );
  }

  Future<void> _restaurarDados(BuildContext context) async {
    await LoteService().restaurarDemonstracao();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados de demonstração restaurados.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const PageHeaderBanner(
          icone: Icons.public,
          titulo: 'Global Solution 2026 • CitizenTech',
          subtitulo: 'Plataforma ColetaAgendada para Impacto Social e '
              'Ambiental Urbano',
        ),
        const SizedBox(height: 14),
        SectionCard(
          titulo: 'Equipe / Startup ColetaAgendada',
          icone: Icons.groups,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final integrante in Integrante.equipe)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${integrante.nome} — RM: ${integrante.rm}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          titulo: 'Conexão com os ODS da ONU (Agenda 2030)',
          icone: Icons.language,
          child: Column(
            children: [for (final ods in Ods.doProjeto) OdsTile(ods: ods)],
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          titulo: 'Diferenciais e Regras de Negócio',
          icone: Icons.rocket_launch,
          child: Column(
            children: [
              for (final (titulo, descricao) in _diferenciais)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titulo,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              descricao,
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
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const SectionCard(
          titulo: 'Tecnologia e WebService',
          icone: Icons.cloud_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'App mobile em Flutter/Dart consumindo a API REST pública '
                'ViaCEP com o pacote http:',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 6),
              SelectableText(
                'GET https://viacep.com.br/ws/{cep}/json/',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: AppColors.teal,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Persistência local com SharedPreferences (introdução, lotes '
                'e favoritos).',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          titulo: 'Configurações',
          icone: Icons.settings,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: () => _reverIntroducao(context),
                icon: const Icon(Icons.slideshow),
                label: const Text('Rever introdução'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _restaurarDados(context),
                icon: const Icon(Icons.restore),
                label: const Text('Restaurar dados de demonstração'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
