import 'package:flutter/material.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../models/lote.dart';
import '../services/lote_service.dart';
import '../widgets/feedback_views.dart';
import '../widgets/lote_card.dart';

/// Lista de lotes com busca por CEP/local/material e filtros por status.
class LotesScreen extends StatefulWidget {
  const LotesScreen({super.key});

  @override
  State<LotesScreen> createState() => _LotesScreenState();
}

class _LotesScreenState extends State<LotesScreen> {
  final LoteService _service = LoteService();
  final TextEditingController _buscaController = TextEditingController();

  bool _carregando = true;
  List<Lote> _lotes = [];
  FiltroLote _filtro = FiltroLote.todos;

  List<Lote> get _lotesFiltrados =>
      _service.filtrar(_lotes, _filtro, _buscaController.text);

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final lotes = await _service.listarLotes();
    if (!mounted) return;
    setState(() {
      _lotes = lotes;
      _carregando = false;
    });
  }

  Future<void> _abrirDetalhe(Lote lote) async {
    // Passagem de parâmetro: protocolo do lote para a tela de detalhes.
    await Navigator.of(context).pushNamed(
      AppRoutes.loteDetalhe,
      arguments: lote.protocolo,
    );
    _carregar();
  }

  Future<void> _alternarFavorito(Lote lote) async {
    final atualizado = await _service.alternarFavorito(lote.protocolo);
    if (!mounted) return;
    setState(() {
      final i = _lotes.indexWhere((l) => l.protocolo == lote.protocolo);
      if (i >= 0) _lotes[i] = atualizado;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
            atualizado.favorito
                ? '⭐ Lote #${lote.protocolo} adicionado aos favoritos'
                : 'Lote #${lote.protocolo} removido dos favoritos',
          ),
        ),
      );
  }

  void _limparBusca() {
    _buscaController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) return const LoadingView(mensagem: 'Carregando lotes...');

    final filtrados = _lotesFiltrados;

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _buscaController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Filtrar por CEP, Local ou Material...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _buscaController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpar busca',
                      onPressed: _limparBusca,
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final filtro in FiltroLote.values)
                ChoiceChip(
                  label: Text(
                    '${filtro.rotulo} (${_service.contar(_lotes, filtro)})',
                  ),
                  avatar: filtro == FiltroLote.favoritos
                      ? Icon(
                          Icons.star,
                          size: 16,
                          color: _filtro == filtro
                              ? Colors.white
                              : AppColors.orange,
                        )
                      : null,
                  selected: _filtro == filtro,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _filtro = filtro),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${filtrados.length} lote(s) encontrado(s) • puxe para atualizar',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          if (filtrados.isEmpty)
            EmptyView(
              icone: Icons.search_off,
              titulo: 'Nenhum lote encontrado',
              mensagem: 'Ajuste a busca ou selecione outro filtro.',
              acao: OutlinedButton(
                onPressed: () {
                  _buscaController.clear();
                  setState(() => _filtro = FiltroLote.todos);
                },
                child: const Text('Limpar filtros'),
              ),
            )
          else
            for (final lote in filtrados) ...[
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
