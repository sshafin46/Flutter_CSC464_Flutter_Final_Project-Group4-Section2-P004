import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  /// Get expenses stream for a specific user with real-time updates from Firestore
  Stream<List<Expense>> getExpenses(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Expense.fromMap(doc.data(), doc.id))
              .toList();
        })
        .handleError((error) {
          print('Error fetching expenses: $error');
          return [];
        });
  }

  /// Add a new expense to Firestore
  Future<void> addExpense(Expense expense) async {
    try {
      final docRef = _firestore.collection('expenses').doc();
      final expenseWithId = Expense(
        id: docRef.id,
        userId: expense.userId,
        name: expense.name,
        amount: expense.amount,
        date: expense.date,
        category: expense.category,
        description: expense.description,
        createdAt: DateTime.now(),
      );
      await docRef.set(expenseWithId.toMap());
    } catch (e) {
      print('Error adding expense: $e');
      rethrow;
    }
  }

  /// Update an existing expense in Firestore
  Future<void> updateExpense(Expense expense) async {
    try {
      if (expense.id == null || expense.id!.isEmpty) {
        throw Exception('Expense ID cannot be null or empty');
      }
      await _firestore
          .collection('expenses')
          .doc(expense.id)
          .update(expense.toMap());
    } catch (e) {
      print('Error updating expense: $e');
      rethrow;
    }
  }

  /// Delete an expense from Firestore
  Future<void> deleteExpense(String id, String userId) async {
    try {
      await _firestore.collection('expenses').doc(id).delete();
    } catch (e) {
      print('Error deleting expense: $e');
      rethrow;
    }
  }

  /// Get total expense for analytics (can be called from Firestore or locally)
  Future<double> getTotalExpenseForUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        total += (data['amount'] as num?)?.toDouble() ?? 0;
      }
      return total;
    } catch (e) {
      print('Error calculating total: $e');
      return 0;
    }
  }

  /// Get category-wise totals for analytics
  Future<Map<String, double>> getCategoryWiseTotals(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .get();

      final Map<String, double> categoryTotals = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] as String? ?? 'Other';
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;

        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      }
      return categoryTotals;
    } catch (e) {
      print('Error calculating category totals: $e');
      return {};
    }
  }
}
