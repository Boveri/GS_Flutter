import 'package:flutter/material.dart';

import '../models/status_lote.dart';

/// Etiqueta colorida com o status do lote.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.grande = false});

  final StatusLote status;
  final bool grande;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: grande ? 12 : 8,
        vertical: grande ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: status.corFundo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icone, size: grande ? 16 : 11, color: status.cor),
          const SizedBox(width: 5),
          Text(
            status.rotulo.toUpperCase(),
            style: TextStyle(
              fontSize: grande ? 15 : 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: status.cor,
            ),
          ),
        ],
      ),
    );
  }
}
