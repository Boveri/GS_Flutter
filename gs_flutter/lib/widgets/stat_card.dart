import 'package:flutter/material.dart';

/// Indicador numérico compacto (ex.: total reciclado, CO₂ evitado).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icone,
    required this.valor,
    required this.rotulo,
    required this.cor,
    required this.corFundo,
  });

  final IconData icone;
  final String valor;
  final String rotulo;
  final Color cor;
  final Color corFundo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: cor, size: 22),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: cor,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            rotulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.5, color: cor),
          ),
        ],
      ),
    );
  }
}
