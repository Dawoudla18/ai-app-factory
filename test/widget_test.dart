import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hala2026/main.dart';

void main() {
  String storedExpense({required double amount, required String category}) =>
      jsonEncode({
        'id': 'saved-expense',
        'amountCents': (amount * 100).round(),
        'category': category,
        'date': DateTime.now().toIso8601String(),
        'note': 'Saved locally',
      });

  testWidgets('shows the empty Quebec expense tracker', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const HalaApp());
    await tester.pumpAndSettle();

    expect(find.text('Expense tracker for Quebec'), findsOneWidget);
    expect(find.text('Amount (CAD)'), findsOneWidget);
    expect(find.text('Save expense'), findsOneWidget);
  });

  testWidgets('rejects a non-finite amount', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const HalaApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'NaN');
    await tester.tap(find.text('Save expense'));
    await tester.pump();

    expect(find.text('Enter an amount greater than zero.'), findsOneWidget);
  });

  testWidgets('rejects an amount that rounds to zero cents', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const HalaApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '0.001');
    await tester.tap(find.text('Save expense'));
    await tester.pump();

    expect(find.text('Enter an amount greater than zero.'), findsOneWidget);
  });

  testWidgets('adds an expense and updates the monthly total', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const HalaApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '12.50');
    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();

    expect(find.text('CA\$12.50'), findsWidgets);
  });

  testWidgets('loads an expense saved on the device', (tester) async {
    SharedPreferences.setMockInitialValues({
      'expenses': [storedExpense(amount: 23.45, category: 'Groceries')],
    });
    await tester.pumpWidget(const HalaApp());
    await tester.pumpAndSettle();

    expect(find.text('CA\$23.45'), findsOneWidget);
  });

  testWidgets('deletes a saved expense with a swipe', (tester) async {
    SharedPreferences.setMockInitialValues({
      'expenses': [storedExpense(amount: 10, category: 'Groceries')],
    });
    await tester.pumpWidget(const HalaApp());
    await tester.pumpAndSettle();

    final expenseRow = find.byType(Dismissible).last;
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.drag(expenseRow, const Offset(-500, 0));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getStringList('expenses'), isEmpty);
  });
}
