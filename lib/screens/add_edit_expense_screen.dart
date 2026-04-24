import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddEditExpenseScreen({super.key, this.expense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late double _amount;
  late DateTime _date;
  late String _category;
  String? _description;

  @override
  void initState() {
    super.initState();
    final isEdit = widget.expense != null;

    _name = isEdit ? widget.expense!.name : '';
    _amount = isEdit ? widget.expense!.amount : 0.0;
    _date = isEdit ? widget.expense!.date : DateTime.now();
    _category = isEdit ? widget.expense!.category : DEFAULT_CATEGORIES.first;
    _description = isEdit ? widget.expense!.description : '';
  }

  Future<void> _presentDatePicker() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D32),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final authProvider = context.read<AuthProvider>();
      final expenseProvider = context.read<ExpenseProvider>();
      final String userId = authProvider.currentUser?.uid ?? '';

      if (userId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: User not authenticated.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final newOrUpdatedExpense = Expense(
        id: widget.expense?.id,
        userId: userId,
        name: _name,
        amount: _amount,
        date: _date,
        category: _category,
        description: _description,
        createdAt: widget.expense?.createdAt ?? DateTime.now(),
      );

      // SOLUTION OPTION 1: Fire and Forget
      // We do not 'await' these calls so the UI can proceed immediately to pop()
      if (widget.expense == null) {
        expenseProvider.addExpense(newOrUpdatedExpense);
      } else {
        expenseProvider.updateExpense(newOrUpdatedExpense);
      }

      // Navigate back to Home Screen immediately
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.expense != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Expense' : 'Add New Expense'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: 'Expense Name',
                  hintText: 'e.g. Lunch, Bus fare',
                  prefixIcon: const Icon(
                    Icons.edit_note,
                    color: Color(0xFF2E7D32),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF2E7D32),
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name.' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _amount == 0.0 ? '' : _amount.toString(),
                decoration: InputDecoration(
                  labelText: 'Amount (৳)',
                  hintText: 'e.g. 500',
                  prefixIcon: const Icon(
                    Icons.monetization_on,
                    color: Color(0xFF2E7D32),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF2E7D32),
                      width: 2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty ||
                      double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Please enter a valid amount.';
                  }
                  return null;
                },
                onSaved: (value) => _amount = double.parse(value!),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Date: ${DateFormat('EEE, MMM d, yyyy').format(_date)}',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    TextButton(
                      onPressed: _presentDatePicker,
                      child: const Text(
                        'Change',
                        style: TextStyle(color: Color(0xFF2E7D32)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(
                    Icons.category,
                    color: Color(0xFF2E7D32),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF2E7D32),
                      width: 2,
                    ),
                  ),
                ),
                items: DEFAULT_CATEGORIES.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _category = value!),
                onSaved: (value) => _category = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add a note...',
                  prefixIcon: const Icon(
                    Icons.description,
                    color: Color(0xFF2E7D32),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF2E7D32),
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 3,
                onSaved: (value) => _description = value,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: Icon(isEdit ? Icons.save : Icons.add),
                  label: Text(
                    isEdit ? 'Save Changes' : 'Add Expense',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}