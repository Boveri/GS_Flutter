/// Indicadores consolidados exibidos no painel inicial.
class ImpactoResumo {
  const ImpactoResumo({
    required this.totalReciclado,
    required this.co2Evitado,
    required this.ganhoEstimado,
    required this.disponiveis,
    required this.reservados,
    required this.coletados,
  });

  final double totalReciclado;
  final double co2Evitado;
  final double ganhoEstimado;
  final int disponiveis;
  final int reservados;
  final int coletados;

  int get totalLotes => disponiveis + reservados + coletados;
}
