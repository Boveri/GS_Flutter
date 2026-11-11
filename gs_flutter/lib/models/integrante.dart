/// Integrante da equipe ColetaAgendada.
class Integrante {
  const Integrante({required this.nome, required this.rm});

  final String nome;
  final String rm;

  // TODO(equipe): preencher com o NOME COMPLETO e o RM de cada integrante.
  static const List<Integrante> equipe = [
    Integrante(nome: 'Felipe Boveri', rm: '555055'),
    Integrante(nome: 'Clara de Fonte', rm: '554321'),
  ];
}
