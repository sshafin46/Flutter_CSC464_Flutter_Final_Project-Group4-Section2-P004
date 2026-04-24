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
      date: data['date'] is DateTime
          ? data['date']
          : DateTime.parse(data['date']),
      category: data['category'] ?? 'Other',
      description: data['description'],
      createdAt: data['createdAt'] is DateTime
          ? data['createdAt']
          : DateTime.parse(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
