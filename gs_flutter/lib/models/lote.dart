import 'material_reciclavel.dart';
import 'status_lote.dart';

/// Lote de recicláveis agendado para coleta (equivalente à `TB_LOTE`).
class Lote {
  const Lote({
    required this.protocolo,
    required this.pin,
    required this.cnpj,
    required this.nomeLocal,
    required this.telefone,
    required this.cep,
    required this.material,
    required this.peso,
    required this.horario,
    required this.dataAbertura,
    required this.status,
    this.favorito = false,
  });

  final int protocolo;
  final String pin;
  final String cnpj;
  final String nomeLocal;
  final String telefone;
  final String cep;
  final MaterialReciclavel material;
  final double peso;
  final String horario;
  final DateTime dataAbertura;
  final StatusLote status;
  final bool favorito;

  /// Regra de negócio: CO₂ evitado = peso × 1,5.
  double get co2Evitado => peso * 1.5;

  /// Regra de negócio: receita = peso × cotação do material.
  double get receitaEstimada => peso * material.cotacaoPorKg;

  /// Dados de contato só são liberados após a reserva (privacidade).
  bool get contatoLiberado => status != StatusLote.disponivel;

  Lote copyWith({StatusLote? status, bool? favorito}) {
    return Lote(
      protocolo: protocolo,
      pin: pin,
      cnpj: cnpj,
      nomeLocal: nomeLocal,
      telefone: telefone,
      cep: cep,
      material: material,
      peso: peso,
      horario: horario,
      dataAbertura: dataAbertura,
      status: status ?? this.status,
      favorito: favorito ?? this.favorito,
    );
  }

  factory Lote.fromJson(Map<String, dynamic> json) {
    return Lote(
      protocolo: json['protocolo'] as int,
      pin: json['pin'] as String,
      cnpj: json['cnpj'] as String,
      nomeLocal: json['nomeLocal'] as String,
      telefone: json['telefone'] as String? ?? '',
      cep: json['cep'] as String,
      material: MaterialReciclavel.fromCodigo(json['material'] as String),
      peso: (json['peso'] as num).toDouble(),
      horario: json['horario'] as String,
      dataAbertura: DateTime.parse(json['dataAbertura'] as String),
      status: StatusLote.fromCodigo(json['status'] as String),
      favorito: json['favorito'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protocolo': protocolo,
      'pin': pin,
      'cnpj': cnpj,
      'nomeLocal': nomeLocal,
      'telefone': telefone,
      'cep': cep,
      'material': material.codigo,
      'peso': peso,
      'horario': horario,
      'dataAbertura': dataAbertura.toIso8601String(),
      'status': status.codigo,
      'favorito': favorito,
    };
  }
}
