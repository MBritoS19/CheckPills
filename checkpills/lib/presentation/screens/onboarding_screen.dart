import 'package:CheckPills/presentation/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  // AQUI ESTÁ A NOVA PROPRIEDADE QUE ESTAVA FALTANDO
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  int _currentPage = 0;
  bool _isNameValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      if (mounted) {
        setState(() {
          _isNameValid = _nameController.text.trim().isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // FUNÇÃO DE FINALIZAÇÃO ATUALIZADA (SEM NAVEGAÇÃO)
  Future<void> _finishOnboarding() async {
    if (!_isNameValid) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Remove o 'Perfil Principal' padrão, se ele existir
    if (userProvider.allUsers.any((user) => user.name == 'Perfil Principal')) {
      final defaultUser = userProvider.allUsers
          .firstWhere((user) => user.name == 'Perfil Principal');
      await userProvider.deleteUser(defaultUser.id);
    }
    // Adiciona o novo perfil criado pelo usuário
    await userProvider.addUser(_nameController.text.trim());

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_concluido', true);

    // Apenas chama a função de callback para avisar que terminou
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildPage(
        icon: Icons.waving_hand_rounded,
        title: 'Bem-vindo ao CheckPills!',
        subtitle:
            'Seu novo assistente para nunca mais esquecer um medicamento.',
      ),
      _buildPage(
        icon: Icons.medication_rounded,
        title: 'Cadastre seus Medicamentos',
        subtitle:
            'Adicione detalhes, intervalos e estoque para um controle completo.',
      ),
      _buildPage(
        icon: Icons.notifications_active_rounded,
        title: 'Receba Lembretes',
        subtitle: 'O aplicativo te notifica na hora certa para cada dose.',
      ),
      _buildNamePage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              if (_currentPage < pages.length - 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _pageController.animateToPage(
                        pages.length - 1,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Pular'),
                  ),
                )
              else
                const SizedBox(height: 48),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: pages,
                ),
              ),

              // BARRA DE NAVEGAÇÃO INFERIOR ATUALIZADA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BOTÃO VOLTAR
                  FloatingActionButton.small(
                    onPressed: _currentPage == 0
                        ? null
                        : () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                    elevation: 0,
                    backgroundColor: _currentPage == 0
                        ? Colors.grey.withOpacity(0.2)
                        : Theme.of(context).colorScheme.surface,
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: _currentPage == 0
                          ? Colors.grey
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  // INDICADOR DE "BOLINHAS" CENTRALIZADO
                  Row(
                    children: List.generate(pages.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }),
                  ),

                  // BOTÃO PRÓXIMO / CONCLUIR
                  FloatingActionButton.small(
                    onPressed: () {
                      if (_currentPage == pages.length - 1) {
                        if (_isNameValid) _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Icon(
                      _currentPage == pages.length - 1
                          ? Icons.check
                          : Icons.arrow_forward_ios,
                    ),
                    backgroundColor:
                        (_currentPage == pages.length - 1 && !_isNameValid)
                            ? Colors.grey
                            : Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 100, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 24),
        Text(title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Text(subtitle,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildNamePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Como podemos chamar você?',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Text(
          'Este será o nome do seu primeiro perfil. Você poderá adicionar outros mais tarde.',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _nameController,
          textAlign: TextAlign.center,
          maxLength: 30,
          inputFormatters: [
            LengthLimitingTextInputFormatter(30),
          ],
          decoration: const InputDecoration(
            labelText: 'Seu nome ou apelido',
            border: OutlineInputBorder(),
            counterText: "", // Oculta o contador padrão
          ),
        ),
      ],
    );
  }
}
