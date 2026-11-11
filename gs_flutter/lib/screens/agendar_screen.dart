import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../core/utils/view_state.dart';
import '../models/endereco.dart';
import '../models/gerador.dart';
import '../models/lote.dart';
import '../models/material_reciclavel.dart';
import '../services/lote_service.dart';
import '../services/viacep_service.dart';
import '../widgets/alert_banner.dart';
import '../widgets/endereco_viacep_card.dart';
import '../widgets/page_header_banner.dart';
import '../widgets/pin_box.dart';
import '../widgets/section_card.dart';
import 'home_shell.dart';

/// Formulário do ponto gerador para agendar um novo lote de coleta.
class AgendarScreen extends StatefulWidget {
  const AgendarScreen({super.key, required this.onNavegar});

  final ValueChanged<int> onNavegar;

  @override
  State<AgendarScreen> createState() => _AgendarScreenState();
}

class _AgendarScreenState extends State<AgendarScreen> {
  final LoteService _loteService = LoteService();
  final ViaCepService _viaCepService = ViaCepService();

  final _formKey = GlobalKey<FormState>();
  final _cnpjController = TextEditingController();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cepController = TextEditingController();
  final _pesoController = TextEditingController();

  MaterialReciclavel? _material = MaterialReciclavel.papelao;
  String? _horario;
  bool _enviando = false;

  // Estado da consulta ao WebService ViaCEP.
  ViewState _estadoCep = ViewState.initial;
  Endereco? _endereco;
  String? _erroCep;

  double? get _peso => _loteService.converterPeso(_pesoController.text);

  @override
  void dispose() {
    _cnpjController.dispose();
    _nomeController.dispose();
    _telefoneController.dispose();
    _cepController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // WebService ViaCEP
  // ---------------------------------------------------------------------------

  Future<void> _buscarCep() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _estadoCep = ViewState.loading;
      _erroCep = null;
    });

    try {
      final endereco = await _viaCepService.buscarEndereco(_cepController.text);
      if (!mounted) return;
      setState(() {
        _endereco = endereco;
        _estadoCep = ViewState.success;
      });
    } on ViaCepException catch (e) {
      if (!mounted) return;
      setState(() {
        _endereco = null;
        _erroCep = e.mensagem;
        _estadoCep = ViewState.error;
      });
    }
  }

  void _aoAlterarCep(String _) {
    if (_estadoCep != ViewState.initial) {
      setState(() {
        _estadoCep = ViewState.initial;
        _endereco = null;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Ações
  // ---------------------------------------------------------------------------

  Future<void> _escolherGeradorDemo() async {
    final geradores = await _loteService.listarGeradores();
    if (!mounted) return;

    final escolhido = await showModalBottomSheet<Gerador>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ListaGeradoresSheet(geradores: geradores),
    );
    if (escolhido == null) return;

    setState(() {
      _cnpjController.text = Formatters.cnpj(escolhido.cnpj);
      _nomeController.text = escolhido.nomeLocal;
      _telefoneController.text = escolhido.telefone;
      _cepController.text = Formatters.cep(escolhido.cep);
    });
    _buscarCep();
  }

  Future<void> _confirmarAgendamento() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (_estadoCep != ViewState.success) {
      _mostrarErro('Busque o CEP para validar o endereço antes de confirmar.');
      return;
    }

    setState(() => _enviando = true);
    try {
      final lote = await _loteService.criarLote(
        NovoLoteDados(
          cnpj: _cnpjController.text,
          nomeLocal: _nomeController.text,
          telefone: _telefoneController.text,
          cep: _cepController.text,
          material: _material,
          peso: _peso,
          horario: _horario,
        ),
      );
      if (!mounted) return;
      setState(() => _enviando = false);
      _mostrarSucesso(lote);
    } on RegraNegocioException catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);
      _mostrarErro(e.mensagem);
    }
  }

  void _limparFormulario() {
    _formKey.currentState?.reset();
    _cnpjController.clear();
    _nomeController.clear();
    _telefoneController.clear();
    _cepController.clear();
    _pesoController.clear();
    setState(() {
      _material = MaterialReciclavel.papelao;
      _horario = null;
      _estadoCep = ViewState.initial;
      _endereco = null;
    });
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.red,
          content: Row(
            children: [
              const Icon(Icons.block, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(mensagem)),
            ],
          ),
        ),
      );
  }

  Future<void> _mostrarSucesso(Lote lote) async {
    final irParaLotes = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SucessoDialog(lote: lote),
    );
    if (!mounted) return;
    _limparFormulario();
    if (irParaLotes == true) widget.onNavegar(HomeShell.abaLotes);
  }

  // ---------------------------------------------------------------------------
  // Interface
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final pesoOk = _loteService.atingePesoMinimo(_peso);
    final pesoDigitado = _pesoController.text.trim().isNotEmpty;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PageHeaderBanner(
            icone: Icons.apartment,
            titulo: 'Novo Agendamento de Coleta',
            subtitulo: 'Cadastre lotes de materiais recicláveis limpos para '
                'disponibilizar a coletores parceiros.',
          ),
          const SizedBox(height: 12),
          AlertBanner(
            tipo: pesoOk
                ? AlertBannerTipo.sucesso
                : pesoDigitado
                    ? AlertBannerTipo.erro
                    : AlertBannerTipo.info,
            mensagem: pesoOk
                ? 'Trava Logística OK: Peso mínimo de 10,0 kg atingido.'
                : pesoDigitado
                    ? 'Trava Logística: lotes abaixo de 10 kg não são aceitos.'
                    : 'Trava Logística: lotes a partir de 10 kg.',
          ),
          const SizedBox(height: 12),
          SectionCard(
            titulo: '1. Dados do Ponto Gerador',
            acao: TextButton.icon(
              onPressed: _escolherGeradorDemo,
              icon: const Icon(Icons.list_alt, size: 18),
              label: const Text('Homologados'),
            ),
            child: Column(
              children: [
                TextFormField(
                  controller: _cnpjController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [MascaraInputFormatter('##.###.###/####-##')],
                  decoration: const InputDecoration(
                    labelText: 'CNPJ do Estabelecimento',
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (v) =>
                      Formatters.somenteDigitos(v ?? '').length == 14
                          ? null
                          : 'Informe os 14 dígitos do CNPJ',
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nomeController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Local (Edifício / Loja)',
                    prefixIcon: Icon(Icons.storefront),
                  ),
                  validator: (v) => (v ?? '').trim().isEmpty
                      ? 'Informe o nome do local'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [MascaraInputFormatter('(##) #####-####')],
                  decoration: const InputDecoration(
                    labelText: 'Telefone da Portaria',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (v) =>
                      Formatters.somenteDigitos(v ?? '').length >= 10
                          ? null
                          : 'Informe um telefone com DDD',
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cepController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [MascaraInputFormatter('#####-###')],
                        onChanged: _aoAlterarCep,
                        onFieldSubmitted: (_) => _buscarCep(),
                        decoration: const InputDecoration(
                          labelText: 'CEP da Coleta',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (v) =>
                            Formatters.somenteDigitos(v ?? '').length == 8
                                ? null
                                : 'CEP com 8 dígitos',
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _estadoCep == ViewState.loading
                            ? null
                            : _buscarCep,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Buscar CEP'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                EnderecoViaCepCard(
                  estado: _estadoCep,
                  endereco: _endereco,
                  mensagemErro: _erroCep,
                  onRetry: _buscarCep,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            titulo: '2. Detalhes do Lote e Peso',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selecione o Material Principal:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final m in MaterialReciclavel.values)
                      ChoiceChip(
                        label: Text(
                          '${m.nome} (${Formatters.moeda(m.cotacaoPorKg)}/kg)',
                        ),
                        selected: _material == m,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _material = m),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pesoController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Peso Estimado em Kg (Mínimo 10,0 kg)',
                    prefixIcon: Icon(Icons.scale),
                    suffixText: 'kg',
                  ),
                  validator: (v) {
                    final peso = _loteService.converterPeso(v ?? '');
                    if (peso == null) return 'Informe o peso estimado';
                    if (!_loteService.atingePesoMinimo(peso)) {
                      return 'O peso mínimo para coleta é de 10 kg';
                    }
                    return null;
                  },
                ),
                if (pesoOk && _material != null) ...[
                  const SizedBox(height: 10),
                  _PreviaImpacto(peso: _peso!, material: _material!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            titulo: '3. Janela de Retirada',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final janela in LoteService.janelasHorario)
                  ChoiceChip(
                    avatar: Icon(
                      Icons.schedule,
                      size: 16,
                      color: _horario == janela
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    label: Text(janela),
                    selected: _horario == janela,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _horario = janela),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _enviando ? null : _confirmarAgendamento,
            icon: _enviando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_outline),
            label: const Text('Confirmar Agendamento'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _limparFormulario,
            child: const Text('Limpar formulário'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Prévia do impacto calculado enquanto o usuário digita o peso.
class _PreviaImpacto extends StatelessWidget {
  const _PreviaImpacto({required this.peso, required this.material});

  final double peso;
  final MaterialReciclavel material;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco, color: AppColors.primary, size: 18),
          const SizedBox(width: 6),
          Text(
            Formatters.co2(peso * LoteService.fatorCo2),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const Icon(Icons.monetization_on, color: AppColors.orange, size: 18),
          const SizedBox(width: 6),
          Text(
            Formatters.moeda(peso * material.cotacaoPorKg),
            style: const TextStyle(
              color: AppColors.orange,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista de geradores homologados para preencher o formulário rapidamente.
class _ListaGeradoresSheet extends StatelessWidget {
  const _ListaGeradoresSheet({required this.geradores});

  final List<Gerador> geradores;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Pontos geradores cadastrados',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: geradores.length,
              itemBuilder: (context, i) {
                final g = geradores[i];
                return ListTile(
                  leading: Icon(
                    g.ativo ? Icons.verified : Icons.block,
                    color: g.ativo ? AppColors.primary : AppColors.red,
                  ),
                  title: Text(g.nomeLocal),
                  subtitle: Text(
                    '${Formatters.cnpj(g.cnpj)} • '
                    '${g.ativo ? 'ATIVO' : 'INATIVO'}',
                  ),
                  onTap: () => Navigator.of(context).pop(g),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Diálogo exibido após o agendamento com o protocolo e o PIN gerados.
class _SucessoDialog extends StatelessWidget {
  const _SucessoDialog({required this.lote});

  final Lote lote;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.check_circle, color: AppColors.primary, size: 36),
      title: const Text(
        'Lote Agendado com Sucesso!',
        style: TextStyle(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Entregue o código PIN abaixo à portaria para que o coletor '
              'parceiro valide no momento da retirada presencial.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            PinBox(protocolo: lote.protocolo, pin: lote.pin),
            const SizedBox(height: 12),
            Text('• Material: ${lote.material.nome} '
                '(${Formatters.peso(lote.peso)})'),
            Text('• CO₂ Evitado: ${Formatters.peso(lote.co2Evitado)}'),
            Text('• Receita Estimada: '
                '${Formatters.moeda(lote.receitaEstimada)}'),
            Text('• Aberto em: ${Formatters.dataHora(lote.dataAbertura)}'),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ir para Lotes & Rotas'),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Agendar Outro Lote'),
            ),
          ],
        ),
      ],
    );
  }
}
