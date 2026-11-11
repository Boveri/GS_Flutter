import 'package:flutter/material.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/impacto_resumo.dart';
import '../models/lote.dart';
import '../models/ods.dart';
import '../models/status_lote.dart';
import '../services/lote_service.dart';
import '../widgets/feedback_views.dart';
import '../widgets/lote_card.dart';
import '../widgets/ods_tile.dart';
import '../widgets/section_card.dart';
import '../widgets/stat_card.dart';
import 'home_shell.dart';

/// Painel inicial com o impacto coletivo acumulado.
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key, required this.onNavegar});

  final ValueChanged<int> onNavegar;

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final LoteService _service = LoteService();

  bool _carregando = true;
  List<Lote> _lotes = [];
  ImpactoResumo? _resumo;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final lotes = await _service.listarLotes();
    if (!mounted) return;
    setState(() {
      _lotes = lotes;
      _resumo = _service.calcularResumo(lotes);
      _carregando = false;
    });
  }

  Future<void> _abrirDetalhe(Lote lote) async {
    await Navigator.of(context).pushNamed(
      AppRoutes.loteDetalhe,
      arguments: lote.protocolo,
    );
    _carregar();
  }

  Future<void> _alternarFavorito(Lote lote) async {
    await _service.alternarFavorito(lote.protocolo);
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) return const LoadingView(mensagem: 'Carregando painel...');

    final resumo = _resumo!;
    final disponiveis = _lotes
        .where((l) => l.status == StatusLote.disponivel)
        .take(2)
        .toList();

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _HeroBanner(),
          const SizedBox(height: 20),
          const _TituloSecao(
            icone: Icons.bar_chart,
            texto: 'Impacto Coletivo Acumulado',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icone: Icons.eco,
                  valor: Formatters.peso(resumo.totalReciclado),
                  rotulo: 'Total Reciclado',
                  cor: AppColors.primary,
                  corFundo: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  icone: Icons.check_circle,
                  valor: Formatters.peso(resumo.co2Evitado),
                  rotulo: 'CO₂ Evitado',
                  cor: AppColors.teal,
                  corFundo: AppColors.tealLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  icone: Icons.monetization_on,
                  valor: Formatters.moeda(resumo.ganhoEstimado),
                  rotulo: 'Ganho Estimado',
                  cor: AppColors.orange,
                  corFundo: AppColors.orangeLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionCard(
            titulo: 'Situação dos Lotes (${resumo.totalLotes})',
            icone: Icons.local_shipping_outlined,
            child: Row(
              children: [
                _ContadorStatus(
                  status: StatusLote.disponivel,
                  quantidade: resumo.disponiveis,
                ),
                _ContadorStatus(
                  status: StatusLote.reservado,
                  quantidade: resumo.reservados,
                ),
                _ContadorStatus(
                  status: StatusLote.coletado,
                  quantidade: resumo.coletados,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => widget.onNavegar(HomeShell.abaAgendar),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Agendar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.onNavegar(HomeShell.abaLotes),
                  icon: const Icon(Icons.route),
                  label: const Text('Ver rotas'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionCard(
            titulo: 'Objetivos de Desenvolvimento Sustentável (ODS)',
            icone: Icons.public,
            acao: IconButton(
              tooltip: 'Ver ODS e equipe',
              visualDensity: VisualDensity.compact,
              onPressed: () => widget.onNavegar(HomeShell.abaSobre),
              icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ods in Ods.doProjeto) OdsChip(ods: ods),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _TituloSecao(
            icone: Icons.near_me,
            texto: 'Lotes disponíveis para coleta',
          ),
          const SizedBox(height: 10),
          if (disponiveis.isEmpty)
            const EmptyView(
              icone: Icons.inbox_outlined,
              titulo: 'Nenhum lote disponível agora',
              mensagem: 'Novos lotes agendados aparecerão aqui.',
            )
          else
            for (final lote in disponiveis) ...[
              LoteCard(
                lote: lote,
                onTap: () => _abrirDetalhe(lote),
                onFavoritar: () => _alternarFavorito(lote),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.eco, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'CitizenTech • ColetaAgendada',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Transformando Recicláveis em Oportunidade e Sustentabilidade',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Conectando condomínios e comércios diretamente a coletores '
            'locais com piso mínimo de 10 kg e validação presencial por PIN '
            'de 4 dígitos.',
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _TituloSecao extends StatelessWidget {
  const _TituloSecao({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, size: 20, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ContadorStatus extends StatelessWidget {
  const _ContadorStatus({required this.status, required this.quantidade});

  final StatusLote status;
  final int quantidade;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$quantidade',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: status.cor,
            ),
          ),
          Text(
            status.rotulo,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
