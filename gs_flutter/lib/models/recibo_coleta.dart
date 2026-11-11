import 'lote.dart';

/// Recibo/certificado de impacto gerado na baixa da coleta.
class ReciboColeta {
  const ReciboColeta({
    required this.lote,
    required this.dataColeta,
  });

  final Lote lote;
  final DateTime dataColeta;

  double get pesoColetado => lote.peso;
  double get co2Evitado => lote.co2Evitado;
  double get valorEstimado => lote.receitaEstimada;
}
