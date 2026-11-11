/// Ponto gerador homologado (equivalente à `TB_GERADOR`).
class Gerador {
  const Gerador({
    required this.cnpj,
    required this.nomeLocal,
    required this.cep,
    required this.telefone,
    required this.ativo,
  });

  final String cnpj;
  final String nomeLocal;
  final String cep;
  final String telefone;
  final bool ativo;
}
