import 'dart:async';
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Expense> _allExpenses = [];
  StreamSubscription? _subscription;
  String _currentUid = '';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _currentCategoryFilter = 'All';
  String get currentCategoryFilter => _currentCategoryFilter;

  SortType _currentSort = SortType.date_desc;
  SortType get currentSort => _currentSort;

  List<Expense> get expenses {
    List<Expense> result = [..._allExpenses];

    if (_currentCategoryFilter != 'All') {
      result =
          result.where((e) => e.category == _currentCategoryFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
              (e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_currentSort == SortType.date_desc) {
      result.sort((a, b) => b.date.compareTo(a.date));
    } else if (_currentSort == SortType.amount_desc) {
      result.sort((a, b) => b.amount.compareTo(a.amount));
    }

    return result;
  }

  void updateUid(String uid) {
    _subscription?.cancel();
    _currentUid = uid;

    if (uid.isEmpty) {
      _allExpenses = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _subscription = _firestoreService.getExpenses(uid).listen((expenseList) {
      _allExpenses = expenseList;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addExpense(Expense expense) async {
    await _firestoreService.addExpense(expense);
  }

  Future<void> updateExpense(Expense expense) async {
    await _firestoreService.updateExpense(expense);
  }

  Future<void> deleteExpense(String id) async {
    await _firestoreService.deleteExpense(id, _currentUid);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _currentCategoryFilter = category;
    notifyListeners();
  }

  void setSortType(SortType sortType) {
    _currentSort = sortType;
    notifyListeners();
  }

  double getTotalExpense() {
    return _allExpenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  double getCategoryTotal(String category) {
    return _allExpenses
        .where((e) => e.category == category)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
