import '../models/gerador.dart';

/// Fonte de dados dos pontos geradores homologados.
///
/// No projeto completo estes dados vêm do endpoint
/// `GET /api/geradores/{cnpj}` (Java + Oracle). No app mobile eles ficam
/// em uma base local para que o fluxo funcione sem o back-end.
class GeradorRepository {
  static const List<Gerador> _geradores = [
    Gerador(
      cnpj: '12345678000190',
      nomeLocal: 'Condomínio Grand Plaza',
      cep: '01310100',
      telefone: '(11) 3251-1000',
      ativo: true,
    ),
    Gerador(
      cnpj: '98765432000111',
      nomeLocal: 'Mercado da Vila',
      cep: '04538133',
      telefone: '(11) 3078-2200',
      ativo: true,
    ),
    Gerador(
      cnpj: '11222333000144',
      nomeLocal: 'Condomínio Edifício Paulista',
      cep: '01310100',
      telefone: '(11) 3285-4400',
      ativo: true,
    ),
    Gerador(
      cnpj: '44555666000177',
      nomeLocal: 'Padaria Pão Dourado',
      cep: '01001000',
      telefone: '(11) 3104-7788',
      ativo: true,
    ),
    Gerador(
      cnpj: '55666777000188',
      nomeLocal: 'Restaurante Parque Verde',
      cep: '04094050',
      telefone: '(11) 5084-3300',
      ativo: true,
    ),
    Gerador(
      cnpj: '99888777000166',
      nomeLocal: 'Loja Centro (cadastro suspenso)',
      cep: '01001000',
      telefone: '(11) 3333-0000',
      ativo: false,
    ),
  ];

  Future<List<Gerador>> listarTodos() async => List.unmodifiable(_geradores);

  Future<Gerador?> buscarPorCnpj(String cnpj) async {
    for (final gerador in _geradores) {
      if (gerador.cnpj == cnpj) return gerador;
    }
    return null;
  }
}
