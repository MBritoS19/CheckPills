import 'package:CheckPills/presentation/screens/configuration_screen.dart';
import 'package:CheckPills/presentation/screens/add_medication_screen.dart';
import 'package:CheckPills/presentation/providers/medication_provider.dart';
import 'package:CheckPills/presentation/providers/user_settings_provider.dart';
import 'package:CheckPills/presentation/widgets/custom_showcase_tooltip.dart';
import 'package:CheckPills/presentation/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:CheckPills/presentation/screens/onboarding_screen.dart';
import 'package:CheckPills/presentation/screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:CheckPills/core/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final AppDatabase database = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(database: database),
        ),
        ChangeNotifierProxyProvider<UserProvider, UserSettingsProvider>(
          create: (context) => UserSettingsProvider(
            database: database,
            userProvider: Provider.of<UserProvider>(context, listen: false),
          ),
          update: (context, userProvider, previousSettingsProvider) =>
              UserSettingsProvider(
            database: database,
            userProvider: userProvider,
          ),
        ),
        ChangeNotifierProxyProvider<UserProvider, MedicationProvider>(
          create: (context) => MedicationProvider(
            database: database,
            userProvider: Provider.of<UserProvider>(context, listen: false),
          ),
          update: (context, userProvider, previousMedicationProvider) =>
              MedicationProvider(
            database: database,
            userProvider: userProvider,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<UserSettingsProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settingsProvider.settings?.darkMode ?? false
          ? ThemeMode.dark
          : ThemeMode.light,
      home: const AppInitializer(),
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey _fabKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _calendarKey = GlobalKey();
  final GlobalKey _weekNavKey = GlobalKey();
  final GlobalKey _doseCardKey = GlobalKey();
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final List<Widget> screens = [
      HomeScreen(
        fabKey: _fabKey,
        profileKey: _profileKey,
        calendarKey: _calendarKey,
        weekNavKey: _weekNavKey,
        doseCardKey: _doseCardKey,
      ),
      const ConfigurationScreen(),
    ];

    // Esta é a estrutura final e limpa.
    return ShowCaseWidget(
      builder: (context) => TutorialController(
        showcaseKeys: [
          _profileKey,
          _weekNavKey,
          _calendarKey,
          _doseCardKey,
          _homeKey,
          _fabKey,
          _settingsKey
        ],
        child: Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
          floatingActionButton: Showcase.withWidget(
            // MUDANÇA 1
            key: _fabKey,
            width: 280,
            height: 120,
            container: CustomShowcaseTooltip(
              description:
                  'Use este botão a qualquer momento para adicionar um novo medicamento.',
              onNext: () => ShowCaseWidget.of(context).next(),
              onSkip: () => ShowCaseWidget.of(context).dismiss(),
            ),
            child: SizedBox(
              height: screenWidth * 0.18,
              width: screenWidth * 0.18,
              child: FloatingActionButton(
                shape: const CircleBorder(),
                child: Icon(
                  Icons.add,
                  size: screenWidth * 0.1,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20.0)),
                    ),
                    useSafeArea: true,
                    builder: (BuildContext context) {
                      return const AddMedicationScreen(
                          key: ValueKey('add_new_medication'));
                    },
                  );
                },
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 10.0,
            height: screenHeight * 0.09,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Showcase.withWidget(
                  // MUDANÇA 2
                  key: _homeKey,
                  width: 280,
                  height: 100,
                  container: CustomShowcaseTooltip(
                    description:
                        'Toque aqui para voltar à tela principal a qualquer momento.',
                    onNext: () => ShowCaseWidget.of(context).next(),
                    onSkip: () => ShowCaseWidget.of(context).dismiss(),
                  ),
                  child: Transform.translate(
                    offset: const Offset(0, -5.0),
                    child: IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: () => _onItemTapped(0),
                      color: _selectedIndex == 0
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                      iconSize: screenWidth * 0.09,
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.1),
                Showcase.withWidget(
                  // MUDANÇA 3
                  key: _settingsKey,
                  width: 280,
                  height: 100,
                  container: CustomShowcaseTooltip(
                    description:
                        'Acesse as configurações do perfil e do aplicativo aqui.',
                    onNext: () => ShowCaseWidget.of(context).next(),
                    onSkip: () => ShowCaseWidget.of(context).dismiss(),
                  ),
                  child: Transform.translate(
                    offset: const Offset(0, -5.0),
                    child: IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => _onItemTapped(1),
                      color: _selectedIndex == 1
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                      iconSize: screenWidth * 0.09,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum AppStatus { loading, onboarding, home }

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  AppStatus _status = AppStatus.loading;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.initializationDone;

    final prefs = await SharedPreferences.getInstance();
    final bool isCompleted = prefs.getBool('onboarding_concluido') ?? false;
    if (mounted) {
      setState(() {
        _status = isCompleted ? AppStatus.home : AppStatus.onboarding;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case AppStatus.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AppStatus.onboarding:
        return OnboardingScreen(onFinish: () {
          setState(() {
            _status = AppStatus.home;
          });
        });
      case AppStatus.home:
        return const MainScreen();
    }
  }
}

class TutorialController extends StatefulWidget {
  final Widget child;
  final List<GlobalKey> showcaseKeys;

  const TutorialController({
    super.key,
    required this.child,
    required this.showcaseKeys,
  });

  @override
  State<TutorialController> createState() => _TutorialControllerState();
}

class _TutorialControllerState extends State<TutorialController> {
  @override
  void initState() {
    super.initState();
    // Usamos addPostFrameCallback para garantir que tudo foi construído
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorial();
    });
  }

  void _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final bool tutorialShown =
        prefs.getBool('home_tutorial_concluido') ?? false;

    if (!tutorialShown && mounted) {
      // A CORREÇÃO ESTÁ AQUI: Adicionamos um pequeno atraso.
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          // Verificamos novamente se o widget ainda está na tela
          ShowCaseWidget.of(context).startShowCase(widget.showcaseKeys);
          prefs.setBool('home_tutorial_concluido', true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
