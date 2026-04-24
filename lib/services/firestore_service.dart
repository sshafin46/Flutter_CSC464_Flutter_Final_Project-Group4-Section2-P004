import 'dart:async';
import '../models/expense.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  final Map<String, List<Expense>> _expensesByUser = {};
  final Map<String, StreamController<List<Expense>>> _streamControllers = {};

  FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  Stream<List<Expense>> getExpenses(String userId) {
    if (!_streamControllers.containsKey(userId)) {
      _streamControllers[userId] = StreamController<List<Expense>>.broadcast();
      if (_expensesByUser.containsKey(userId)) {
        _streamControllers[userId]!.add(_expensesByUser[userId]!);
      }
    }
    return _streamControllers[userId]!.stream;
  }

  Future<void> addExpense(Expense expense) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final expenses = _expensesByUser.putIfAbsent(expense.userId, () => []);
    final newExpense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: expense.userId,
      name: expense.name,
      amount: expense.amount,
      date: expense.date,
      category: expense.category,
      description: expense.description,
      createdAt: DateTime.now(),
    );
    expenses.add(newExpense);
    _streamControllers[expense.userId]?.add(List.from(expenses));
  }

  Future<void> updateExpense(Expense expense) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_expensesByUser.containsKey(expense.userId)) {
      final expenses = _expensesByUser[expense.userId]!;
      final index = expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        expenses[index] = expense;
        _streamControllers[expense.userId]?.add(List.from(expenses));
      }
    }
  }

  Future<void> deleteExpense(String id, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_expensesByUser.containsKey(userId)) {
      _expensesByUser[userId]!.removeWhere((e) => e.id == id);
      _streamControllers[userId]?.add(List.from(_expensesByUser[userId]!));
    }
  }
}
