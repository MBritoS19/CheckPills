import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:primeiro_flutter/presentation/providers/medication_provider.dart';
import 'package:primeiro_flutter/presentation/screens/add_medication_screen.dart';
import 'package:primeiro_flutter/presentation/screens/configuration_screen.dart';
import 'package:primeiro_flutter/presentation/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:primeiro_flutter/data/datasources/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  // 2. Envolvemos nosso aplicativo com o ChangeNotifierProvider
  runApp(
    Provider<AppDatabase>(
      create: (context) => AppDatabase(),
      dispose: (context, db) => db.close(),
      child: ChangeNotifierProvider(
        create: (context) => MedicationProvider(
          // Passamos a instância do AppDatabase para o MedicationProvider
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
      home: MainScreen(),
    );
  }
}

// O resto do arquivo continua exatamente igual...
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int? _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {
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
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final List<Widget> screens = [
      const HomeScreen(),
      const ConfigurationScreen(),
    ];

    final Widget currentScreen = (_selectedIndex ?? 0) >= screens.length
        ? screens[0]
        : screens[_selectedIndex ?? 0];

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
