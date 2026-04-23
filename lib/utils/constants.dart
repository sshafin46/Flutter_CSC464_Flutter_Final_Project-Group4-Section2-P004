import 'package:flutter/material.dart';
const List<String> DEFAULT_CATEGORIES = [
  'Food',
  'Transport',
  'Shopping',
  'Health',
  'Education',
  'Bills',
  'Entertainment',
  'Other',
];

const Map<String, dynamic> CATEGORY_COLORS = {
  'Food': Color(0xFFEF5350),
  'Transport': Color(0xFF42A5F5),
  'Shopping': Color(0xFFAB47BC),
  'Health': Color(0xFF26A69A),
  'Education': Color(0xFFFFA726),
  'Bills': Color(0xFF78909C),
  'Entertainment': Color(0xFFEC407A),
  'Other': Color(0xFF8D6E63),
};

enum SortType {
  date_desc,
  amount_desc,
}