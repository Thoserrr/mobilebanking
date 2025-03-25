class FinanceRecord {
  String description;
  double amount;
  String category;
  DateTime date;
  String? referenceId;

  static const collectionName = 'myapp';
  static const colDescription = 'description';
  static const colAmount = 'amount';
  static const colCategory = 'category';
  static const colDate = 'date';

  FinanceRecord({
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    this.referenceId,
  });

  Map<String, dynamic> toJson() {
    return {
      colDescription: description,
      colAmount: amount,
      colCategory: category,
      colDate: date.toIso8601String(),
    };
  }
}

class Budget {
  double limit;
  double currentExpenses;
  DateTime startDate;
  DateTime endDate;

  Budget({
    required this.limit,
    this.currentExpenses = 0,
    required this.startDate,
    required this.endDate,
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      limit: map['limit'],
      currentExpenses: map['currentExpenses'] ?? 0,
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'limit': limit,
      'currentExpenses': currentExpenses,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}
