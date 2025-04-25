import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/salary_provider.dart';

class SalaryScreen extends StatefulWidget {
  @override
  _SalaryScreenState createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  final TextEditingController _headController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now()); // Default to current month

  void _showAddHeadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Salary Head"),
          content: TextField(
            controller: _headController,
            decoration: InputDecoration(labelText: "Enter Head Name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Provider.of<SalaryProvider>(context, listen: false)
                    .addSalaryHead(_headController.text);
                Navigator.pop(context);
                _headController.clear();
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showAddSalaryDialog(BuildContext context, String head) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Salary to $head"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                int amount = int.tryParse(_amountController.text) ?? 0;
                if (amount > 0) {
                  Provider.of<SalaryProvider>(context, listen: false)
                      .addSalary(head, _descriptionController.text, amount);
                }
                Navigator.pop(context);
                _descriptionController.clear();
                _amountController.clear();
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final salaryProvider = Provider.of<SalaryProvider>(context);
    final salaryHeads = salaryProvider.salaryHeads.keys.toList();

    return Scaffold(
      appBar: AppBar(title: Text("Salary Heads")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHeadDialog(context),
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: salaryHeads.length,
        itemBuilder: (context, index) {
          String head = salaryHeads[index];
          int totalAmount = salaryProvider.getTotalForHead(head);
          var salariesByMonth = salaryProvider.getSalariesByMonth(head);

          return Card(
            child: ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(head),
                  Text("Total: ${totalAmount}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
              children: [
                DropdownButton<String>(
                  value: _selectedMonth,
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value!;
                    });
                  },
                  items: salariesByMonth.keys.map((month) {
                    return DropdownMenuItem(
                      value: month,
                      child: Text(DateFormat('MMMM yyyy').format(DateTime.parse("$month-01"))),
                    );
                  }).toList(),
                ),
                ...salaryProvider.filterSalariesByMonth(head, _selectedMonth).map((salary) {
                  return ListTile(
                    title: Text("${salary['description']}"),
                    subtitle: Text("Date: ${salary['date']}"),
                    trailing: Text("${salary['amount']}"),
                  );
                }).toList(),
                TextButton(
                  onPressed: () => _showAddSalaryDialog(context, head),
                  child: Text("Add Salary"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
