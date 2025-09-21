// lib/main.dart

import 'package:CheckPills/presentation/screens/configuration_screen.dart';
import 'package:CheckPills/presentation/screens/add_medication_screen.dart';
import 'package:CheckPills/presentation/providers/medication_provider.dart';
import 'package:CheckPills/presentation/providers/settings_provider.dart';
import 'package:CheckPills/presentation/screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:CheckPills/core/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// lib/main.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final AppDatabase database = AppDatabase();

  // Buscamos as configurações salvas ANTES de rodar o app.
  final Setting? initialSettings = await database.settingsDao.getSettings();

  runApp(
    Provider<AppDatabase>.value(
      value: database,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => MedicationProvider(
              database: database,
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => SettingsProvider(
              database: database,
              // Passamos as configurações iniciais para o provider.
              initialSettings: initialSettings,
            ),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Nossos temas centralizados agora são a única fonte da verdade para o design
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode:
          settingsProvider.settings.darkMode ? ThemeMode.dark : ThemeMode.light,

      home: const MainScreen(),
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
      const HomeScreen(),
      const ConfigurationScreen(),
    ];

    final Widget currentScreen = screens[_selectedIndex];

    // REMOVEMOS a constante de cor local.
    // const blueColor = Color(0xFF23AFDC);

    return Scaffold(
      body: currentScreen,
      floatingActionButton: SizedBox(
        height: screenWidth * 0.18,
        width: screenWidth * 0.18,
        child: FloatingActionButton(
          // REMOVIDO: backgroundColor: blueColor,
          // A cor agora é definida pelo 'floatingActionButtonTheme' em app_theme.dart.
          shape: const CircleBorder(),
          child: Icon(
            Icons.add,
            size: screenWidth * 0.1,
            // REMOVIDO: color: Colors.white,
            // A cor do ícone também é definida pelo tema ('onPrimary').
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
              ),
              useSafeArea: true,
              builder: (BuildContext context) {
                return const AddMedicationScreen();
              },
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        height: screenHeight * 0.09,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Transform.translate(
              offset: const Offset(0, -5.0),
              child: IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => _onItemTapped(0),
                // ALTERADO: Usamos a cor primária do tema.
                color: _selectedIndex == 0
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                iconSize: screenWidth * 0.09,
              ),
            ),
            SizedBox(width: screenWidth * 0.1),
            Transform.translate(
              offset: const Offset(0, -5.0),
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _onItemTapped(1),
                // ALTERADO: Usamos a cor primária do tema.
                color: _selectedIndex == 1
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                iconSize: screenWidth * 0.09,
              ),
            ),
          ],
        ),
      ),
    );
  }
}