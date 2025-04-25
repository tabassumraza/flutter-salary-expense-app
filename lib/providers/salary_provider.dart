import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // 📅 For date formatting

class SalaryProvider with ChangeNotifier {
  Map<String, List<Map<String, dynamic>>> _salaryHeads = {};

  Map<String, List<Map<String, dynamic>>> get salaryHeads => _salaryHeads;

  SalaryProvider() {
    _loadFromPrefs();
  }

  void addSalaryHead(String head) {
    if (!_salaryHeads.containsKey(head)) {
      _salaryHeads[head] = [];
      _saveToPrefs();
      notifyListeners();
    }
  }

  void addSalary(String head, String description, int amount) {
    if (_salaryHeads.containsKey(head)) {
      DateTime now = DateTime.now();
      _salaryHeads[head]!.add({
        'description': description,
        'amount': amount,
        'date': now.toIso8601String(),
        'month': DateFormat('yyyy-MM').format(now), // 📅 Store month for filtering
      });
      _saveToPrefs();
      notifyListeners();
    }
  }

  int getTotalForHead(String head) {
    if (!_salaryHeads.containsKey(head)) return 0;
    return _salaryHeads[head]!
        .fold<int>(0, (sum, item) => sum + (item['amount'] as int));
  }

  Map<String, List<Map<String, dynamic>>> getSalariesByMonth(String head) {
    if (!_salaryHeads.containsKey(head)) return {};
    Map<String, List<Map<String, dynamic>>> grouped = {};
    
    for (var salary in _salaryHeads[head]!) {
      String month = salary['month'];
      if (!grouped.containsKey(month)) {
        grouped[month] = [];
      }
      grouped[month]!.add(salary);
    }

    return grouped;
  }

  List<Map<String, dynamic>> filterSalariesByMonth(String head, String month) {
    if (!_salaryHeads.containsKey(head)) return [];
    return _salaryHeads[head]!.where((item) => item['month'] == month).toList();
  }

  void _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('salary_heads', jsonEncode(_salaryHeads));
  }

  void _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('salary_heads');
    if (data != null) {
      _salaryHeads = Map<String, List<Map<String, dynamic>>>.from(
        jsonDecode(data).map((key, value) => MapEntry(
            key, List<Map<String, dynamic>>.from(value))),
      );
      notifyListeners();
    }
  }
}
