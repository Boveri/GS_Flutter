import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/lote.dart';
import '../models/material_reciclavel.dart';
import '../models/status_lote.dart';

/// Persistência local dos lotes em SharedPreferences (formato JSON).
class LoteRepository {
  static const String _chaveLotes = 'lotes_v1';

  Future<List<Lote>> listar() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_chaveLotes);

    if (json == null) {
      final iniciais = lotesDemonstracao();
      await salvarTodos(iniciais);
      return iniciais;
    }

    final lista = jsonDecode(json) as List<dynamic>;
    return lista
        .map((item) => Lote.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> salvarTodos(List<Lote> lotes) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(lotes.map((l) => l.toJson()).toList());
    await prefs.setString(_chaveLotes, json);
  }

  Future<void> restaurarDemonstracao() async {
    await salvarTodos(lotesDemonstracao());
  }

  /// Massa de testes inicial (mesma ideia dos inserts no Oracle).
  static List<Lote> lotesDemonstracao() {
    final agora = DateTime.now();
    return [
      Lote(
        protocolo: 1001,
        pin: '4821',
        cnpj: '11222333000144',
        nomeLocal: 'Condomínio Edifício Paulista',
        telefone: '(11) 3285-4400',
        cep: '01310100',
        material: MaterialReciclavel.papelao,
        peso: 45,
        horario: '08:00 - 12:00',
        dataAbertura: agora.subtract(const Duration(hours: 5)),
        status: StatusLote.disponivel,
      ),
      Lote(
        protocolo: 1002,
        pin: '1234',
        cnpj: '98765432000111',
        nomeLocal: 'Mercado da Vila',
        telefone: '(11) 3078-2200',
        cep: '04538133',
        material: MaterialReciclavel.plastico,
        peso: 22,
        horario: '14:00 - 17:00',
        dataAbertura: agora.subtract(const Duration(hours: 9)),
        status: StatusLote.reservado,
      ),
      Lote(
        protocolo: 1003,
        pin: '7390',
        cnpj: '44555666000177',
        nomeLocal: 'Padaria Pão Dourado',
        telefone: '(11) 3104-7788',
        cep: '01001000',
        material: MaterialReciclavel.aluminio,
        peso: 15,
        horario: '08:00 - 12:00',
        dataAbertura: agora.subtract(const Duration(days: 1)),
        status: StatusLote.coletado,
      ),
      Lote(
        protocolo: 1004,
        pin: '5062',
        cnpj: '55666777000188',
        nomeLocal: 'Restaurante Parque Verde',
        telefone: '(11) 5084-3300',
        cep: '04094050',
        material: MaterialReciclavel.vidro,
        peso: 30,
        horario: '17:00 - 20:00',
        dataAbertura: agora.subtract(const Duration(hours: 2)),
        status: StatusLote.disponivel,
      ),
    ];
  }
}
