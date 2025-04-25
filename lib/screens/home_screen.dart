import 'package:flutter/material.dart';
import 'salary_screen.dart';
import 'expense_screen.dart';  // You may need to create this file for expenses

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    SalaryScreen(),  // Show Salary Screen
    ExpenseScreen(), // Show Expense Screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: "Salaries"),
          BottomNavigationBarItem(icon: Icon(Icons.money_off), label: "Expenses"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
