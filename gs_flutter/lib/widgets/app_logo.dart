import 'package:flutter/material.dart';

/// Logo do aplicativo carregado dos assets.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.tamanho = 120});

  static const String caminho = 'assets/images/logo.png';

  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      caminho,
      width: tamanho,
      height: tamanho,
      fit: BoxFit.contain,
    );
  }
}
