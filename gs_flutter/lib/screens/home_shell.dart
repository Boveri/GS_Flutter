import 'package:flutter/material.dart';

import 'agendar_screen.dart';
import 'inicio_screen.dart';
import 'lotes_screen.dart';
import 'sobre_screen.dart';

/// Estrutura principal com AppBar e barra de navegação inferior
/// alternando entre as 4 telas principais.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  static const int abaInicio = 0;
  static const int abaAgendar = 1;
  static const int abaLotes = 2;
  static const int abaSobre = 3;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _abaAtual = HomeShell.abaInicio;

  void _selecionarAba(int aba) => setState(() => _abaAtual = aba);

  Widget _telaAtual() {
    // Cada aba é recriada ao ser selecionada, recarregando os dados salvos.
    switch (_abaAtual) {
      case HomeShell.abaAgendar:
        return AgendarScreen(onNavegar: _selecionarAba);
      case HomeShell.abaLotes:
        return const LotesScreen();
      case HomeShell.abaSobre:
        return const SobreScreen();
      default:
        return InicioScreen(onNavegar: _selecionarAba);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Botão "voltar" do Android retorna para a aba Início antes de sair.
      canPop: _abaAtual == HomeShell.abaInicio,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _selecionarAba(HomeShell.abaInicio);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.eco),
              SizedBox(width: 10),
              Text('ColetaAgendada'),
            ],
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: KeyedSubtree(
            key: ValueKey(_abaAtual),
            child: _telaAtual(),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _abaAtual,
          onDestinationSelected: _selecionarAba,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Início',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Agendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Lotes & Rotas',
            ),
            NavigationDestination(
              icon: Icon(Icons.info_outline),
              selectedIcon: Icon(Icons.info),
              label: 'ODS & Equipe',
            ),
          ],
        ),
      ),
    );
  }
}
