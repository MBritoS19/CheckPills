import 'package:flutter/material.dart';
import 'package:primeiro_flutter/screens/add_medication_screen.dart';
import 'package:primeiro_flutter/screens/configuration_screen.dart';
import 'package:primeiro_flutter/screens/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart'; // 1. Importe esta biblioteca

// 2. Transformamos a função main em `async` para poder "esperar" a inicialização
Future<void> main() async {
  // 3. Esta linha garante que o Flutter esteja pronto antes de executarmos nosso código
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Esta é a linha que resolve o erro!
  // Ela carrega os dados de formatação para o português do Brasil.
  await initializeDateFormatting('pt_BR', null);

  runApp(const MyApp());
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

// ... O resto do arquivo continua exatamente igual ...

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddMedicationScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      const ConfigurationScreen(),
    ];

    final Widget currentScreen = _selectedIndex > 1 ? screens[1] : screens[0];

    return Scaffold(
      body: currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded),
            label: 'Adicionar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
