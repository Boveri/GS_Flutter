import 'package:flutter/services.dart';

/// Funções de formatação de textos exibidos na interface.
class Formatters {
  Formatters._();

  static String somenteDigitos(String valor) =>
      valor.replaceAll(RegExp(r'[^0-9]'), '');

  /// 12345678000190 -> 12.345.678/0001-90
  static String cnpj(String valor) {
    final d = somenteDigitos(valor);
    if (d.length != 14) return valor;
    return '${d.substring(0, 2)}.${d.substring(2, 5)}.${d.substring(5, 8)}/'
        '${d.substring(8, 12)}-${d.substring(12)}';
  }

  /// 01310100 -> 01310-100
  static String cep(String valor) {
    final d = somenteDigitos(valor);
    if (d.length != 8) return valor;
    return '${d.substring(0, 5)}-${d.substring(5)}';
  }

  static String peso(double kg) => '${kg.toStringAsFixed(1)} kg';

  static String co2(double kg) => '${kg.toStringAsFixed(1)} kg CO₂';

  static String moeda(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  static String dataHora(DateTime data) {
    String dois(int n) => n.toString().padLeft(2, '0');
    return '${dois(data.day)}/${dois(data.month)}/${data.year} '
        '${dois(data.hour)}:${dois(data.minute)}';
  }
}

/// Máscara genérica baseada em um padrão com '#' para cada dígito.
/// Ex.: '##.###.###/####-##' para CNPJ e '#####-###' para CEP.
class MascaraInputFormatter extends TextInputFormatter {
  MascaraInputFormatter(this.mascara);

  final String mascara;

  int get _maxDigitos => '#'.allMatches(mascara).length;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digitos = Formatters.somenteDigitos(newValue.text);
    if (digitos.length > _maxDigitos) {
      digitos = digitos.substring(0, _maxDigitos);
    }

    final buffer = StringBuffer();
    var i = 0;
    for (final char in mascara.split('')) {
      if (i >= digitos.length) break;
      if (char == '#') {
        buffer.write(digitos[i]);
        i++;
      } else {
        buffer.write(char);
      }
    }

    final texto = buffer.toString();
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
