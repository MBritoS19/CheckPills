import 'package:flutter/material.dart';
import 'package:checkpills/core/constants/app_constants.dart';
import 'package:checkpills/presentation/screens/add_medication_screen.dart';
import 'package:checkpills/presentation/screens/configuration_screen.dart';
import 'package:checkpills/presentation/screens/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {
      _showAddMedicationSheet();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showAddMedicationSheet() {
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
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final List<Widget> screens = [
      const HomeScreen(),
      const ConfigurationScreen(),
    ];

    final Widget currentScreen =
        _selectedIndex >= screens.length ? screens[0] : screens[_selectedIndex];

    return Scaffold(
      body: currentScreen,
      floatingActionButton: SizedBox(
        height: screenWidth * 0.18,
        width: screenWidth * 0.18,
        child: FloatingActionButton(
          backgroundColor: AppColors.primaryBlue,
          shape: const CircleBorder(),
          child: Icon(
            Icons.add,
            size: screenWidth * 0.1,
            color: Colors.white,
          ),
          onPressed: _showAddMedicationSheet,
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
                color:
                    _selectedIndex == 0 ? AppColors.primaryBlue : Colors.grey,
                iconSize: screenWidth * 0.09,
              ),
            ),
            SizedBox(width: screenWidth * 0.1),
            Transform.translate(
              offset: const Offset(0, -5.0),
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _onItemTapped(1),
                color:
                    _selectedIndex == 1 ? AppColors.primaryBlue : Colors.grey,
                iconSize: screenWidth * 0.09,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
