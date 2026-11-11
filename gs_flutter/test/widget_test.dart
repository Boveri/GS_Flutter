import 'package:flutter_test/flutter_test.dart';
import 'package:gs_flutter/models/material_reciclavel.dart';
import 'package:gs_flutter/models/status_lote.dart';
import 'package:gs_flutter/services/lote_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

NovoLoteDados _dados({
  String cnpj = '12.345.678/0001-90',
  double? peso = 20,
  MaterialReciclavel? material = MaterialReciclavel.papelao,
}) {
  return NovoLoteDados(
    cnpj: cnpj,
    nomeLocal: 'Condomínio Grand Plaza',
    telefone: '(11) 3251-1000',
    cep: '01310-100',
    material: material,
    peso: peso,
    horario: '14:00 - 17:00',
  );
}

void main() {
  late LoteService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = LoteService();
  });

  group('CT01 / CT02 / CT03 - Agendamento de lote', () {
    test('CT01: gera protocolo e PIN de 4 dígitos para lote válido', () async {
      final lote = await service.criarLote(_dados());

      expect(lote.protocolo, 1005);
      expect(lote.pin, matches(RegExp(r'^\d{4}$')));
      expect(lote.status, StatusLote.disponivel);
      expect(lote.co2Evitado, 30);
      expect(lote.receitaEstimada, closeTo(16, 0.001));
    });

    test('CT02: bloqueia lote abaixo de 10 kg', () async {
      expect(
        () => service.criarLote(_dados(peso: 3)),
        throwsA(isA<RegraNegocioException>()),
      );
    });

    test('CT03: bloqueia gerador sem cadastro ativo', () async {
      expect(
        () => service.criarLote(_dados(cnpj: '99.888.777/0001-66')),
        throwsA(isA<RegraNegocioException>()),
      );
      expect(
        () => service.criarLote(_dados(cnpj: '00.000.000/0000-00')),
        throwsA(isA<RegraNegocioException>()),
      );
    });
  });

  group('CT04 / CT05 - Baixa da coleta com PIN', () {
    test('CT04: PIN correto conclui a coleta', () async {
      // Lote 1002 da massa de testes está RESERVADO com PIN 1234.
      final recibo = await service.darBaixa(1002, '1234');

      expect(recibo.lote.status, StatusLote.coletado);
      expect(recibo.co2Evitado, 33);
      expect(recibo.valorEstimado, closeTo(33, 0.001));
    });

    test('CT05: PIN incorreto mantém o lote pendente', () async {
      expect(
        () => service.darBaixa(1002, '9999'),
        throwsA(isA<RegraNegocioException>()),
      );
      final lote = await service.buscarPorProtocolo(1002);
      expect(lote!.status, StatusLote.reservado);
    });
  });

  test('Reserva retira o lote dos disponíveis', () async {
    final antes = await service.listarLotes();
    final disponiveisAntes = service.contar(antes, FiltroLote.disponiveis);

    await service.reservar(1001);

    final depois = await service.listarLotes();
    expect(service.contar(depois, FiltroLote.disponiveis), disponiveisAntes - 1);
  });

  test('Busca encontra lote por CEP e por material', () async {
    final lotes = await service.listarLotes();
    expect(service.filtrar(lotes, FiltroLote.todos, '01310').length, 1);
    expect(service.filtrar(lotes, FiltroLote.todos, 'vidro').length, 1);
  });
}
