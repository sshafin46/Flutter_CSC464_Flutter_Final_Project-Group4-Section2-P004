import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String? id;
  final String userId;
  final String name;
  final double amount;
  final DateTime date;
  final String category;
  final String? description;
  final DateTime createdAt;

  Expense({
    this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
    this.description,
    required this.createdAt,
  });

  factory Expense.fromMap(Map<String, dynamic> data, String id) {
    return Expense(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: data['date'] is Timestamp
          ? (data['date'] as Timestamp).toDate()
          : (data['date'] is DateTime
              ? data['date']
              : DateTime.parse(data['date'].toString())),
      category: data['category'] ?? 'Other',
      description: data['description'],
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : (data['createdAt'] is DateTime
              ? data['createdAt']
              : DateTime.parse(data['createdAt'].toString())),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'category': category,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

