import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const HalaApp());

class HalaApp extends StatelessWidget {
  const HalaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Hala2026',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006D77)),
      useMaterial3: true,
    ),
    home: const ExpenseTrackerPage(),
  );
}

class Expense {
  const Expense({
    required this.id,
    required this.amountCents,
    required this.category,
    required this.date,
    required this.note,
  });

  final String id;
  final int amountCents;
  final String category;
  final DateTime date;
  final String note;

  Map<String, dynamic> toJson() => {
    'id': id,
    'amountCents': amountCents,
    'category': category,
    'date': date.toIso8601String(),
    'note': note,
  };

  factory Expense.fromJson(Map<String, dynamic> json) {
    final storedCents = json['amountCents'];
    final amountCents = storedCents is num
        ? storedCents.round()
        : ((json['amount'] as num).toDouble() * 100).round();
    return Expense(
      id: json['id'] as String,
      amountCents: amountCents,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String? ?? '',
    );
  }
}

class ExpenseTrackerPage extends StatefulWidget {
  const ExpenseTrackerPage({super.key});

  @override
  State<ExpenseTrackerPage> createState() => _ExpenseTrackerPageState();
}

class _ExpenseTrackerPageState extends State<ExpenseTrackerPage> {
  static const _storageKey = 'expenses';
  static const _categories = [
    'Groceries',
    'Housing',
    'Transport',
    'Restaurants',
    'Health',
    'Entertainment',
    'Other',
  ];
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final List<Expense> _expenses = [];
  String _category = _categories.first;
  DateTime _date = DateTime.now();
  bool _loading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final loaded = <Expense>[];
    try {
      final preferences = await SharedPreferences.getInstance();
      for (final item in preferences.getStringList(_storageKey) ?? []) {
        try {
          loaded.add(
            Expense.fromJson(jsonDecode(item) as Map<String, dynamic>),
          );
        } on Object {
          // Preserve valid entries if one locally stored record is malformed.
        }
      }
    } on Object {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadFailed = true;
        });
      }
      return;
    }
    loaded.sort((a, b) => b.date.compareTo(a.date));
    if (!mounted) return;
    setState(() {
      _expenses
        ..clear()
        ..addAll(loaded);
      _loading = false;
      _loadFailed = false;
    });
  }

  Future<bool> _save(List<Expense> expenses) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return await preferences.setStringList(
        _storageKey,
        expenses.map((item) => jsonEncode(item.toJson())).toList(),
      );
    } on Object {
      return false;
    }
  }

  bool _currentMonth(Expense expense) {
    final today = DateTime.now();
    return expense.date.year == today.year && expense.date.month == today.month;
  }

  int get _monthlyTotal => _expenses
      .where(_currentMonth)
      .fold(0, (total, item) => total + item.amountCents);

  Map<String, int> get _categoryTotals {
    final totals = <String, int>{};
    for (final item in _expenses.where(_currentMonth)) {
      totals.update(
        item.category,
        (total) => total + item.amountCents,
        ifAbsent: () => item.amountCents,
      );
    }
    return totals;
  }

  String _money(int cents) => 'CA\$${(cents / 100).toStringAsFixed(2)}';

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (selected != null && mounted) setState(() => _date = selected);
  }

  Future<void> _add() async {
    if (!_formKey.currentState!.validate()) return;
    final item = Expense(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      amountCents:
          (double.parse(_amountController.text.replaceAll(',', '.')) * 100)
              .round(),
      category: _category,
      date: _date,
      note: _noteController.text.trim(),
    );
    final updated = [..._expenses, item]
      ..sort((a, b) => b.date.compareTo(a.date));
    final saved = await _save(updated);
    if (!saved) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save the expense. Please try again.'),
          ),
        );
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      _expenses
        ..clear()
        ..addAll(updated);
      _amountController.clear();
      _noteController.clear();
      _category = _categories.first;
      _date = DateTime.now();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense saved on this device.')),
      );
    }
  }

  Future<bool> _confirmDelete(Expense item) async {
    final updated = _expenses
        .where((expense) => expense.id != item.id)
        .toList();
    final saved = await _save(updated);
    if (!saved) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not delete the expense. Please try again.'),
          ),
        );
      }
      return false;
    }
    return true;
  }

  void _removeFromState(Expense item) {
    setState(() => _expenses.removeWhere((expense) => expense.id == item.id));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final totals = _categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Scaffold(
      appBar: AppBar(title: const Text('Hala2026')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadFailed
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Your saved expenses could not be loaded.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        setState(() => _loading = true);
                        _load();
                      },
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            )
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Expense tracker for Quebec',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Text('Amounts are tracked in Canadian dollars (CAD).'),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Spent in ${localizations.formatMonthYear(DateTime.now())}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _money(_monthlyTotal),
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Add an expense',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount (CAD)',
                            prefixText: 'CA\$ ',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            final amount = double.tryParse(
                              (value ?? '').replaceAll(',', '.'),
                            );
                            final cents = amount == null || !amount.isFinite
                                ? 0
                                : (amount * 100).round();
                            return amount == null ||
                                    !amount.isFinite ||
                                    amount <= 0 ||
                                    cents < 1
                                ? 'Enter an amount greater than zero.'
                                : null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _category,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: _categories
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _category = value!),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _noteController,
                          decoration: const InputDecoration(
                            labelText: 'Note (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(localizations.formatMediumDate(_date)),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _add,
                            icon: const Icon(Icons.add),
                            label: const Text('Save expense'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (totals.isNotEmpty) ...[
                    Text(
                      'This month by category',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    ...totals.map(
                      (entry) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(entry.key),
                        trailing: Text(_money(entry.value)),
                      ),
                    ),
                    const Divider(height: 32),
                  ],
                  Text(
                    'Recent expenses',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (_expenses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No expenses yet. Add your first expense above.',
                      ),
                    )
                  else
                    ..._expenses.map(
                      (item) => Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          color: Theme.of(context).colorScheme.error,
                          child: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.onError,
                          ),
                        ),
                        confirmDismiss: (_) => _confirmDelete(item),
                        onDismissed: (_) => _removeFromState(item),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.category),
                          subtitle: Text(
                            '${localizations.formatMediumDate(item.date)}${item.note.isEmpty ? '' : ' • ${item.note}'}',
                          ),
                          trailing: Text(_money(item.amountCents)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
