import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../core/utils/view_state.dart';
import '../models/endereco.dart';
import '../models/lote.dart';
import '../models/status_lote.dart';
import '../services/lote_service.dart';
import '../services/viacep_service.dart';
import '../widgets/endereco_viacep_card.dart';
import '../widgets/feedback_views.dart';
import '../widgets/impacto_material_box.dart';
import '../widgets/info_row.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';

/// Detalhes de um lote. Recebe o número do protocolo como parâmetro.
class LoteDetalheScreen extends StatefulWidget {
  const LoteDetalheScreen({super.key, required this.protocolo});

  final int protocolo;

  @override
  State<LoteDetalheScreen> createState() => _LoteDetalheScreenState();
}

class _LoteDetalheScreenState extends State<LoteDetalheScreen> {
  final LoteService _service = LoteService();
  final ViaCepService _viaCepService = ViaCepService();
  final TextEditingController _pinController = TextEditingController();

  bool _carregando = true;
  bool _processando = false;
  bool _pinVisivel = false;
  Lote? _lote;
  String? _erroPin;

  ViewState _estadoEndereco = ViewState.initial;
  Endereco? _endereco;
  String? _erroEndereco;

  @override
  void initState() {
    super.initState();
    _carregarLote();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _carregarLote() async {
    final lote = await _service.buscarPorProtocolo(widget.protocolo);
    if (!mounted) return;
    setState(() {
      _lote = lote;
      _carregando = false;
    });
    if (lote != null) _carregarEndereco();
  }

  Future<void> _carregarEndereco() async {
    setState(() => _estadoEndereco = ViewState.loading);
    try {
      final endereco = await _viaCepService.buscarEndereco(_lote!.cep);
      if (!mounted) return;
      setState(() {
        _endereco = endereco;
        _estadoEndereco = ViewState.success;
      });
    } on ViaCepException catch (e) {
      if (!mounted) return;
      setState(() {
        _erroEndereco = e.mensagem;
        _estadoEndereco = ViewState.error;
      });
    }
  }

  /// Executa uma ação do serviço, atualizando o lote e tratando erros.
  Future<void> _executar(
    Future<Lote> Function() acao,
    String mensagemSucesso,
  ) async {
    setState(() => _processando = true);
    try {
      final atualizado = await acao();
      if (!mounted) return;
      setState(() {
        _lote = atualizado;
        _processando = false;
      });
      _mostrarMensagem(mensagemSucesso);
    } on RegraNegocioException catch (e) {
      if (!mounted) return;
      setState(() => _processando = false);
      _mostrarMensagem(e.mensagem, erro: true);
    }
  }

  Future<void> _reservar() => _executar(
        () => _service.reservar(widget.protocolo),
        '🚚 Rota reservada! O lote saiu do radar dos demais coletores.',
      );

  Future<void> _cancelarReserva() => _executar(
        () => _service.cancelarReserva(widget.protocolo),
        'Reserva cancelada. O lote voltou a ficar disponível.',
      );

  Future<void> _alternarFavorito() => _executar(
        () => _service.alternarFavorito(widget.protocolo),
        _lote!.favorito ? 'Removido dos favoritos' : '⭐ Adicionado aos favoritos',
      );

  Future<void> _concluirColeta() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _processando = true;
      _erroPin = null;
    });
    try {
      final recibo =
          await _service.darBaixa(widget.protocolo, _pinController.text);
      if (!mounted) return;
      setState(() {
        _lote = recibo.lote;
        _processando = false;
      });
      _pinController.clear();
      _mostrarMensagem(
        '🎉 Coleta concluída! ${Formatters.co2(recibo.co2Evitado)} evitado.',
      );
      Navigator.of(context).pushNamed(AppRoutes.recibo, arguments: recibo);
    } on RegraNegocioException catch (e) {
      if (!mounted) return;
      setState(() {
        _processando = false;
        _erroPin = e.mensagem;
      });
    }
  }

  Future<void> _excluir() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline, color: AppColors.red),
        title: Text('Excluir lote #${widget.protocolo}?'),
        content: const Text(
          'O agendamento será cancelado e o lote deixará de aparecer para '
          'os coletores.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;

    try {
      await _service.excluir(widget.protocolo);
      if (!mounted) return;
      _mostrarMensagem('Lote #${widget.protocolo} excluído.');
      Navigator.of(context).pop(true);
    } on RegraNegocioException catch (e) {
      _mostrarMensagem(e.mensagem, erro: true);
    }
  }

  void _mostrarMensagem(String mensagem, {bool erro = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: erro ? AppColors.red : null,
          content: Text(mensagem),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final lote = _lote;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Lote #${widget.protocolo}'),
        actions: [
          if (lote != null) ...[
            IconButton(
              tooltip: 'Favoritar',
              onPressed: _processando ? null : _alternarFavorito,
              icon: Icon(lote.favorito ? Icons.star : Icons.star_border),
            ),
            if (lote.status != StatusLote.coletado)
              IconButton(
                tooltip: 'Excluir lote',
                onPressed: _processando ? null : _excluir,
                icon: const Icon(Icons.delete),
              ),
          ],
        ],
      ),
      body: _carregando
          ? const LoadingView(mensagem: 'Carregando lote...')
          : lote == null
              ? EmptyView(
                  icone: Icons.search_off,
                  titulo: 'Lote não encontrado',
                  mensagem: 'Ele pode ter sido excluído.',
                  acao: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Voltar'),
                  ),
                )
              : _conteudo(lote),
    );
  }

  Widget _conteudo(Lote lote) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatusHeader(
          lote: lote,
          pinVisivel: _pinVisivel,
          onAlternarPin: () => setState(() => _pinVisivel = !_pinVisivel),
        ),
        const SizedBox(height: 14),
        SectionCard(
          titulo: 'Ponto Gerador Cadastrado',
          icone: Icons.push_pin,
          corIcone: AppColors.red,
          child: Column(
            children: [
              InfoRow(
                icone: Icons.apartment,
                texto: lote.nomeLocal,
                subtitulo: 'CNPJ: ${Formatters.cnpj(lote.cnpj)}',
                destaque: true,
              ),
              InfoRow(
                icone: Icons.location_on,
                texto: 'CEP da Região: ${Formatters.cep(lote.cep)}',
              ),
              InfoRow(
                icone: Icons.schedule,
                texto: 'Janela de Retirada: ${lote.horario}',
              ),
              InfoRow(
                icone: lote.contatoLiberado ? Icons.phone : Icons.lock,
                corIcone: lote.contatoLiberado
                    ? AppColors.primary
                    : AppColors.textSecondary,
                texto: lote.contatoLiberado
                    ? 'Portaria: ${lote.telefone}'
                    : 'Contato protegido',
                subtitulo: lote.contatoLiberado
                    ? null
                    : 'Liberado após a reserva do lote (privacidade).',
              ),
              InfoRow(
                icone: Icons.event,
                texto: 'Aberto em ${Formatters.dataHora(lote.dataAbertura)}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          titulo: 'Endereço da Coleta (ViaCEP)',
          icone: Icons.map_outlined,
          child: EnderecoViaCepCard(
            estado: _estadoEndereco,
            endereco: _endereco,
            mensagemErro: _erroEndereco,
            onRetry: _carregarEndereco,
            mensagemInicial: 'Preparando consulta do endereço...',
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          titulo: 'Especificação do Lote & Impacto Ambiental',
          icone: Icons.balance,
          child: ImpactoMaterialBox(lote: lote, grande: true),
        ),
        const SizedBox(height: 14),
        _acoes(lote),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _acoes(Lote lote) {
    switch (lote.status) {
      case StatusLote.disponivel:
        return SectionCard(
          titulo: 'Reserva Exclusiva de Rota',
          icone: Icons.route,
          corIcone: AppColors.orange,
          corFundo: AppColors.primaryLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ao reservar, este lote sai do radar dos demais coletores '
                'e o contato da portaria é liberado para você.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _processando ? null : _reservar,
                icon: const Icon(Icons.bookmark_add),
                label: const Text('Reservar Coleta'),
              ),
            ],
          ),
        );
      case StatusLote.reservado:
        return SectionCard(
          titulo: 'Validação Presencial e Fluxo de Coleta',
          icone: Icons.key,
          corIcone: AppColors.orange,
          corFundo: AppColors.primaryLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Digite o código PIN de 4 dígitos informado pela portaria do '
                'local para validar a retirada e gerar o recibo de impacto '
                'ambiental:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) {
                  if (_erroPin != null) setState(() => _erroPin = null);
                },
                style: const TextStyle(fontSize: 20, letterSpacing: 6),
                decoration: InputDecoration(
                  labelText: 'Código PIN (4 Dígitos)',
                  prefixIcon: const Icon(Icons.key),
                  errorText: _erroPin,
                  counterText: '',
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _processando ? null : _concluirColeta,
                icon: const Icon(Icons.verified),
                label: const Text('Concluir Coleta'),
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: _processando ? null : _cancelarReserva,
                icon: const Icon(Icons.undo),
                label: const Text('Cancelar reserva'),
              ),
            ],
          ),
        );
      case StatusLote.coletado:
        return Card(
          color: AppColors.primaryLight,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.check_circle, color: AppColors.primary, size: 40),
                const SizedBox(height: 8),
                const Text(
                  'Coleta Finalizada com Sucesso!',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Certificado de Impacto: ${Formatters.co2(lote.co2Evitado)} '
                  'evitado e ${Formatters.moeda(lote.receitaEstimada)} '
                  'injetados na economia circular.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        );
    }
  }
}

/// Faixa superior com o status atual e o PIN (oculto por padrão).
class _StatusHeader extends StatelessWidget {
  const _StatusHeader({
    required this.lote,
    required this.pinVisivel,
    required this.onAlternarPin,
  });

  final Lote lote;
  final bool pinVisivel;
  final VoidCallback onAlternarPin;

  @override
  Widget build(BuildContext context) {
    final status = lote.status;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: status.corFundo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STATUS ATUAL DA COLETA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: status.cor,
                  ),
                ),
                const SizedBox(height: 6),
                StatusBadge(status: status, grande: true),
              ],
            ),
          ),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onAlternarPin,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'PIN: ${pinVisivel ? lote.pin : '••••'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      pinVisivel ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
