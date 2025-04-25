import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseProvider with ChangeNotifier {
  List<Map<String, dynamic>> _expenses = [];

  ExpenseProvider() {
    loadData();
  }

  List<Map<String, dynamic>> get expenses => _expenses;

  void addExpense(String description, int amount) {
    _expenses.add({
      "description": description,
      "amount": amount,
      "date": DateTime.now().toString(),
    });

    saveData();
    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('expenses', jsonEncode(_expenses));
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? expensesString = prefs.getString('expenses');

    if (expensesString != null) {
      _expenses = List<Map<String, dynamic>>.from(jsonDecode(expensesString));
      notifyListeners();
    }
  }
}
