import 'package:CheckPills/presentation/screens/configuration_screen.dart';
import 'package:CheckPills/presentation/screens/add_medication_screen.dart';
import 'package:CheckPills/presentation/providers/medication_provider.dart';
import 'package:CheckPills/presentation/providers/user_settings_provider.dart';
import 'package:CheckPills/presentation/providers/user_provider.dart';
import 'package:CheckPills/presentation/screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:CheckPills/data/datasources/database.dart';
import 'package:CheckPills/core/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
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

    return Scaffold(
      body: currentScreen,
      floatingActionButton: SizedBox(
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

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    
    // Print do estado atual toda vez que o widget for reconstruído
    print("🔄 [AppInitializer] Reconstruindo. Estado: isInitialized=${userProvider.isInitialized}, activeUser=${userProvider.activeUser?.name}");

    if (!userProvider.isInitialized || userProvider.activeUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    print("🚀 [AppInitializer] Condição satisfeita! Mostrando a MainScreen.");
    return const MainScreen();
  }
}