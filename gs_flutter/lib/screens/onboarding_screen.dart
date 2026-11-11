import 'package:flutter/material.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../models/onboarding_item.dart';
import '../services/preferences_service.dart';
import '../widgets/onboarding_page.dart';

/// Introdução com 4 páginas explicando a proposta do app.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const List<OnboardingItem> _paginas = [
    OnboardingItem(
      icone: Icons.inventory_2_outlined,
      titulo: 'Reciclável limpo não é lixo',
      descricao: 'Condomínios e comércios acumulam papelão, plástico, latas '
          'e vidro todos os dias. Com o ColetaAgendada esse material deixa '
          'de ir para a calçada e vira renda.',
      cor: AppColors.primary,
    ),
    OnboardingItem(
      icone: Icons.event_available,
      titulo: 'Agende lotes a partir de 10 kg',
      descricao: 'O ponto gerador cadastra o lote, escolhe a janela de '
          'retirada e o endereço é preenchido pelo CEP. O sistema gera um '
          'protocolo e um PIN de 4 dígitos.',
      cor: AppColors.teal,
    ),
    OnboardingItem(
      icone: Icons.route,
      titulo: 'Coletor reserva a rota',
      descricao: 'O coletor vê os lotes disponíveis na sua região e reserva '
          'com exclusividade — sem viagens perdidas para locais onde outro '
          'coletor já passou.',
      cor: AppColors.orange,
    ),
    OnboardingItem(
      icone: Icons.verified,
      titulo: 'PIN na portaria e impacto real',
      descricao: 'Na retirada, o coletor valida o PIN informado pela portaria '
          'e recebe o certificado com o CO₂ evitado e o ganho estimado.',
      cor: AppColors.blue,
    ),
  ];

  final PageController _pageController = PageController();
  final PreferencesService _preferencesService = PreferencesService();

  int _paginaAtual = 0;
  bool _naoMostrarNovamente = false;

  bool get _ehPrimeira => _paginaAtual == 0;
  bool get _ehUltima => _paginaAtual == _paginas.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _irPara(int pagina) {
    _pageController.animateToPage(
      pagina,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finalizar() async {
    // Respeita a opção: só grava "visto" se o usuário marcou a caixa.
    await _preferencesService.salvarOnboardingVisto(_naoMostrarNovamente);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finalizar,
                child: const Text('Pular'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _paginas.length,
                onPageChanged: (pagina) =>
                    setState(() => _paginaAtual = pagina),
                itemBuilder: (context, indice) =>
                    OnboardingPage(item: _paginas[indice]),
              ),
            ),
            _Indicadores(total: _paginas.length, atual: _paginaAtual),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _naoMostrarNovamente,
              onChanged: (valor) =>
                  setState(() => _naoMostrarNovamente = valor ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              title: const Text(
                'Não mostrar novamente',
                style: TextStyle(fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _ehPrimeira ? null : () => _irPara(_paginaAtual - 1),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Voltar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _ehUltima
                          ? _finalizar
                          : () => _irPara(_paginaAtual + 1),
                      icon: Icon(_ehUltima ? Icons.check : Icons.arrow_forward),
                      iconAlignment: IconAlignment.end,
                      label: Text(_ehUltima ? 'Começar' : 'Avançar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Indicadores extends StatelessWidget {
  const _Indicadores({required this.total, required this.atual});

  final int total;
  final int atual;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final ativo = i == atual;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: ativo ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: ativo ? AppColors.primary : AppColors.primarySoft,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
