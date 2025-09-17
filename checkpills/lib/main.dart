import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:CheckPills/presentation/providers/medication_provider.dart';
import 'package:CheckPills/presentation/screens/add_medication_screen.dart';
import 'package:CheckPills/presentation/screens/configuration_screen.dart';
import 'package:CheckPills/presentation/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:CheckPills/data/datasources/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    Provider<AppDatabase>(
      create: (context) => AppDatabase(),
      dispose: (context, db) => db.close(),
      child: ChangeNotifierProvider(
        create: (context) => MedicationProvider(
          database: Provider.of<AppDatabase>(context, listen: false),
        ),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // A variável não precisa mais de ser nula. Começa sempre em 0.
  int _selectedIndex = 0;

  // A lista `_widgetOptions` desnecessária foi removida.

  void _onItemTapped(int index) {
    // A lógica de abrir o modal foi movida para o onPressed do FAB.
    // Esta função agora só precisa de atualizar o índice.
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // A lista de telas agora está aqui, de forma mais limpa.
    final List<Widget> screens = [
      const HomeScreen(), // Índice 0
      const ConfigurationScreen(), // Índice 1
    ];

    // A lógica para escolher a tela foi simplificada.
    // `_selectedIndex` nunca será nulo.
    final Widget currentScreen = screens[_selectedIndex];

    const blueColor = Color(0xFF23AFDC);

    return Scaffold(
      body: currentScreen,
      floatingActionButton: SizedBox(
        height: screenWidth * 0.18,
        width: screenWidth * 0.18,
        child: FloatingActionButton(
          backgroundColor: blueColor,
          shape: const CircleBorder(),
          child: Icon(
            Icons.add,
            size: screenWidth * 0.1,
            color: Colors.white,
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
              ),
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
                color: _selectedIndex == 0 ? blueColor : Colors.grey,
                iconSize: screenWidth * 0.09,
              ),
            ),
            SizedBox(width: screenWidth * 0.1),
            Transform.translate(
              offset: const Offset(0, -5.0),
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _onItemTapped(1),
                color: _selectedIndex == 1 ? blueColor : Colors.grey,
                iconSize: screenWidth * 0.09,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
