/// Endereço retornado pelo WebService ViaCEP
/// (`https://viacep.com.br/ws/{cep}/json/`).
class Endereco {
  const Endereco({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.cidade,
    required this.uf,
  });

  final String cep;
  final String logradouro;
  final String complemento;
  final String bairro;
  final String cidade;
  final String uf;

  /// Converte o JSON do ViaCEP em objeto Dart.
  factory Endereco.fromJson(Map<String, dynamic> json) {
    return Endereco(
      cep: json['cep'] as String? ?? '',
      logradouro: json['logradouro'] as String? ?? '',
      complemento: json['complemento'] as String? ?? '',
      bairro: json['bairro'] as String? ?? '',
      cidade: json['localidade'] as String? ?? '',
      uf: json['uf'] as String? ?? '',
    );
  }

  String get linhaPrincipal =>
      logradouro.isEmpty ? 'Logradouro não informado' : logradouro;

  String get linhaSecundaria {
    final partes = [
      if (bairro.isNotEmpty) bairro,
      '$cidade - $uf',
    ];
    return partes.join(' • ');
  }
}
