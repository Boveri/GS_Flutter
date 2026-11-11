import 'dart:math';

import '../core/utils/formatters.dart';
import '../models/gerador.dart';
import '../models/impacto_resumo.dart';
import '../models/lote.dart';
import '../models/material_reciclavel.dart';
import '../models/recibo_coleta.dart';
import '../models/status_lote.dart';
import '../repositories/gerador_repository.dart';
import '../repositories/lote_repository.dart';

/// Erro de regra de negócio, com mensagem pronta para exibir ao usuário.
class RegraNegocioException implements Exception {
  const RegraNegocioException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Filtros disponíveis na tela de Lotes & Rotas.
enum FiltroLote {
  todos('Todos'),
  disponiveis('Disponíveis'),
  reservados('Reservados'),
  coletados('Coletados'),
  favoritos('Favoritos');

  const FiltroLote(this.rotulo);

  final String rotulo;
}

/// Dados digitados no formulário de agendamento.
class NovoLoteDados {
  const NovoLoteDados({
    required this.cnpj,
    required this.nomeLocal,
    required this.telefone,
    required this.cep,
    required this.material,
    required this.peso,
    required this.horario,
  });

  final String cnpj;
  final String nomeLocal;
  final String telefone;
  final String cep;
  final MaterialReciclavel? material;
  final double? peso;
  final String? horario;
}

/// Concentra todas as regras de negócio do ColetaAgendada.
/// As telas apenas chamam estes métodos e exibem o resultado.
class LoteService {
  LoteService({
    LoteRepository? loteRepository,
    GeradorRepository? geradorRepository,
    Random? random,
  })  : _loteRepository = loteRepository ?? LoteRepository(),
        _geradorRepository = geradorRepository ?? GeradorRepository(),
        _random = random ?? Random.secure();

  /// Piso logístico: nenhum lote abaixo de 10 kg.
  static const double pesoMinimoKg = 10;

  /// Fator de CO₂ evitado por kg reciclado.
  static const double fatorCo2 = 1.5;

  static const int _primeiroProtocolo = 1001;

  static const List<String> janelasHorario = [
    '08:00 - 12:00',
    '12:00 - 14:00',
    '14:00 - 17:00',
    '17:00 - 20:00',
  ];

  final LoteRepository _loteRepository;
  final GeradorRepository _geradorRepository;
  final Random _random;

  // ---------------------------------------------------------------------------
  // Consultas
  // ---------------------------------------------------------------------------

  Future<List<Lote>> listarLotes() async {
    final lotes = await _loteRepository.listar();
    lotes.sort((a, b) => b.protocolo.compareTo(a.protocolo));
    return lotes;
  }

  Future<Lote?> buscarPorProtocolo(int protocolo) async {
    final lotes = await _loteRepository.listar();
    for (final lote in lotes) {
      if (lote.protocolo == protocolo) return lote;
    }
    return null;
  }

  Future<List<Gerador>> listarGeradores() => _geradorRepository.listarTodos();

  /// Filtra a lista por status/favorito e por texto (CEP, local ou material).
  List<Lote> filtrar(List<Lote> lotes, FiltroLote filtro, String busca) {
    final termo = busca.trim().toLowerCase();
    final termoDigitos = Formatters.somenteDigitos(termo);

    return lotes.where((lote) {
      final passaFiltro = switch (filtro) {
        FiltroLote.todos => true,
        FiltroLote.disponiveis => lote.status == StatusLote.disponivel,
        FiltroLote.reservados => lote.status == StatusLote.reservado,
        FiltroLote.coletados => lote.status == StatusLote.coletado,
        FiltroLote.favoritos => lote.favorito,
      };
      if (!passaFiltro) return false;
      if (termo.isEmpty) return true;

      final porTexto = lote.nomeLocal.toLowerCase().contains(termo) ||
          lote.material.nome.toLowerCase().contains(termo) ||
          lote.protocolo.toString().contains(termo);
      final porCep =
          termoDigitos.isNotEmpty && lote.cep.startsWith(termoDigitos);
      return porTexto || porCep;
    }).toList();
  }

  int contar(List<Lote> lotes, FiltroLote filtro) =>
      filtrar(lotes, filtro, '').length;

  /// Impacto acumulado considerando apenas lotes efetivamente coletados.
  ImpactoResumo calcularResumo(List<Lote> lotes) {
    final coletados =
        lotes.where((l) => l.status == StatusLote.coletado).toList();
    final peso = coletados.fold<double>(0, (soma, l) => soma + l.peso);
    final ganho =
        coletados.fold<double>(0, (soma, l) => soma + l.receitaEstimada);

    return ImpactoResumo(
      totalReciclado: peso,
      co2Evitado: peso * fatorCo2,
      ganhoEstimado: ganho,
      disponiveis:
          lotes.where((l) => l.status == StatusLote.disponivel).length,
      reservados: lotes.where((l) => l.status == StatusLote.reservado).length,
      coletados: coletados.length,
    );
  }

  // ---------------------------------------------------------------------------
  // Validações
  // ---------------------------------------------------------------------------

  bool atingePesoMinimo(double? peso) => peso != null && peso >= pesoMinimoKg;

  /// Converte o texto digitado (aceita vírgula) em número.
  double? converterPeso(String texto) =>
      double.tryParse(texto.trim().replaceAll(',', '.'));

  /// Regra 1: somente geradores cadastrados e ATIVOS podem publicar lotes.
  Future<Gerador> validarGerador(String cnpj) async {
    final digitos = Formatters.somenteDigitos(cnpj);
    if (digitos.length != 14) {
      throw const RegraNegocioException('Informe um CNPJ com 14 dígitos.');
    }
    final gerador = await _geradorRepository.buscarPorCnpj(digitos);
    if (gerador == null || !gerador.ativo) {
      throw const RegraNegocioException(
        'Ponto gerador não autorizado: este CNPJ não possui cadastro ativo.',
      );
    }
    return gerador;
  }

  // ---------------------------------------------------------------------------
  // Comandos
  // ---------------------------------------------------------------------------

  /// Regras 1, 2 e 4: valida dados, gera protocolo + PIN e salva DISPONIVEL.
  Future<Lote> criarLote(NovoLoteDados dados) async {
    if (dados.nomeLocal.trim().isEmpty ||
        dados.telefone.trim().isEmpty ||
        dados.material == null ||
        dados.horario == null ||
        dados.peso == null) {
      throw const RegraNegocioException(
        'Preencha todos os campos obrigatórios do agendamento.',
      );
    }
    if (!atingePesoMinimo(dados.peso)) {
      throw RegraNegocioException(
        'Trava logística: o peso mínimo para coleta é de '
        '${pesoMinimoKg.toStringAsFixed(0)} kg.',
      );
    }
    final cep = Formatters.somenteDigitos(dados.cep);
    if (cep.length != 8) {
      throw const RegraNegocioException('Informe um CEP válido.');
    }

    final gerador = await validarGerador(dados.cnpj);

    final lotes = await _loteRepository.listar();
    final maiorProtocolo = lotes.fold<int>(
      _primeiroProtocolo - 1,
      (maior, l) => max(maior, l.protocolo),
    );

    final novo = Lote(
      protocolo: maiorProtocolo + 1,
      pin: gerarPin(),
      cnpj: gerador.cnpj,
      nomeLocal: dados.nomeLocal.trim(),
      telefone: dados.telefone.trim(),
      cep: cep,
      material: dados.material!,
      peso: dados.peso!,
      horario: dados.horario!,
      dataAbertura: DateTime.now(),
      status: StatusLote.disponivel,
    );

    await _loteRepository.salvarTodos([...lotes, novo]);
    return novo;
  }

  /// PIN aleatório de 4 dígitos (0000 a 9999).
  String gerarPin() => _random.nextInt(10000).toString().padLeft(4, '0');

  /// DISPONIVEL -> RESERVADO (o lote sai do radar dos demais coletores).
  Future<Lote> reservar(int protocolo) async {
    final lote = await _obter(protocolo);
    if (lote.status != StatusLote.disponivel) {
      throw const RegraNegocioException(
        'Este lote já foi reservado por outro coletor.',
      );
    }
    return _atualizar(lote.copyWith(status: StatusLote.reservado));
  }

  /// RESERVADO -> DISPONIVEL (coletor desistiu da rota).
  Future<Lote> cancelarReserva(int protocolo) async {
    final lote = await _obter(protocolo);
    if (lote.status != StatusLote.reservado) {
      throw const RegraNegocioException('Este lote não está reservado.');
    }
    return _atualizar(lote.copyWith(status: StatusLote.disponivel));
  }

  /// RESERVADO -> COLETADO, somente com o PIN correto.
  Future<ReciboColeta> darBaixa(int protocolo, String pinInformado) async {
    final pin = pinInformado.trim();
    if (pin.isEmpty) {
      throw const RegraNegocioException('Digite o código PIN de 4 dígitos.');
    }
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw const RegraNegocioException(
        'O código PIN deve ter exatamente 4 números.',
      );
    }

    final lote = await _obter(protocolo);
    if (lote.status != StatusLote.reservado) {
      throw const RegraNegocioException(
        'Reserve o lote antes de confirmar a retirada.',
      );
    }
    if (lote.pin != pin) {
      throw const RegraNegocioException(
        'Código PIN inválido. Confira o código com a portaria.',
      );
    }

    final coletado = await _atualizar(
      lote.copyWith(status: StatusLote.coletado),
    );
    return ReciboColeta(lote: coletado, dataColeta: DateTime.now());
  }

  Future<Lote> alternarFavorito(int protocolo) async {
    final lote = await _obter(protocolo);
    return _atualizar(lote.copyWith(favorito: !lote.favorito));
  }

  Future<void> excluir(int protocolo) async {
    final lote = await _obter(protocolo);
    if (lote.status == StatusLote.coletado) {
      throw const RegraNegocioException(
        'Lotes já coletados não podem ser excluídos.',
      );
    }
    final lotes = await _loteRepository.listar();
    lotes.removeWhere((l) => l.protocolo == protocolo);
    await _loteRepository.salvarTodos(lotes);
  }

  Future<void> restaurarDemonstracao() =>
      _loteRepository.restaurarDemonstracao();

  // ---------------------------------------------------------------------------
  // Auxiliares
  // ---------------------------------------------------------------------------

  Future<Lote> _obter(int protocolo) async {
    final lote = await buscarPorProtocolo(protocolo);
    if (lote == null) {
      throw const RegraNegocioException('Lote não encontrado.');
    }
    return lote;
  }

  Future<Lote> _atualizar(Lote atualizado) async {
    final lotes = await _loteRepository.listar();
    final indice = lotes.indexWhere((l) => l.protocolo == atualizado.protocolo);
    if (indice < 0) {
      throw const RegraNegocioException('Lote não encontrado.');
    }
    lotes[indice] = atualizado;
    await _loteRepository.salvarTodos(lotes);
    return atualizado;
  }
}
