import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/utils/formatters.dart';
import '../models/endereco.dart';

/// Erro amigável retornado pelo [ViaCepService].
class ViaCepException implements Exception {
  const ViaCepException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Consumo do WebService REST ViaCEP com o pacote `http`.
class ViaCepService {
  ViaCepService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://viacep.com.br/ws';
  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;

  /// GET https://viacep.com.br/ws/{cep}/json/
  Future<Endereco> buscarEndereco(String cep) async {
    final digitos = Formatters.somenteDigitos(cep);
    if (digitos.length != 8) {
      throw const ViaCepException('O CEP deve conter 8 dígitos.');
    }

    final uri = Uri.parse('$_baseUrl/$digitos/json/');

    try {
      final resposta = await _client.get(uri).timeout(_timeout);

      if (resposta.statusCode == 400) {
        throw const ViaCepException('CEP em formato inválido.');
      }
      if (resposta.statusCode != 200) {
        throw ViaCepException(
          'O serviço de CEP respondeu com erro (${resposta.statusCode}). '
          'Tente novamente em instantes.',
        );
      }

      final json = jsonDecode(utf8.decode(resposta.bodyBytes));
      if (json is! Map<String, dynamic>) {
        throw const ViaCepException('Resposta inesperada do serviço de CEP.');
      }

      // O ViaCEP responde 200 com {"erro": true} para CEP inexistente.
      if (json['erro'] == true || json['erro'] == 'true') {
        throw const ViaCepException(
          'CEP não encontrado. Confira os números digitados.',
        );
      }

      return Endereco.fromJson(json);
    } on ViaCepException {
      rethrow;
    } on TimeoutException {
      throw const ViaCepException(
        'A consulta demorou demais. Verifique sua conexão e tente novamente.',
      );
    } on http.ClientException {
      throw const ViaCepException(
        'Sem conexão com o serviço de CEP. Verifique sua internet e tente '
        'novamente.',
      );
    } on FormatException {
      throw const ViaCepException('Resposta inválida do serviço de CEP.');
    } catch (_) {
      throw const ViaCepException(
        'Não foi possível consultar o CEP agora. Tente novamente.',
      );
    }
  }
}
