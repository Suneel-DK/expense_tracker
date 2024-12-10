import 'package:expense_tracker/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'transaction_list.dart';

class HomePage extends StatelessWidget {
  final Box<TransactionModel> transactionBox = Hive.box<TransactionModel>('transactions');

  @override
  Widget build(BuildContext context) {
    double totalIncome = transactionBox.values
        .where((transaction) => transaction.isIncome)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);

    double totalExpense = transactionBox.values
        .where((transaction) => !transaction.isIncome)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);

    double balance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(title: Text('Expense Tracker')),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryCard("Income", totalIncome, Colors.green),
                    _buildSummaryCard("Expense", totalExpense, Colors.red),
                    _buildSummaryCard("Balance", balance, Colors.blue),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text("Add Transaction"),
                  onPressed: () => _showTransactionDialog(context),
                ),
              ],
            ),
          ),
          Expanded(child: TransactionList()),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title),
        SizedBox(height: 5),
        Text('\$${amount.toStringAsFixed(2)}', style: TextStyle(color: color)),
      ],
    );
  }

  void _showTransactionDialog(BuildContext context) {
    String reason = '';
    double amount = 0.0;
    bool isIncome = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Reason'),
              onChanged: (value) => reason = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) => amount = double.tryParse(value) ?? 0,
            ),
            SwitchListTile(
              title: Text("Income"),
              value: isIncome,
              onChanged: (value) => isIncome = value,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              final newTransaction = TransactionModel()
                ..reason = reason
                ..amount = amount
                ..dateTime = DateTime.now()
                ..isIncome = isIncome;
              Hive.box<TransactionModel>('transactions').add(newTransaction);
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}
