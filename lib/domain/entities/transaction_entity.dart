/// Transaction entity - Domain layer
/// Represents a single expense transaction
class TransactionEntity {
  final int? id;
  final double amount;
  final String category;
  final DateTime dateTime;
  final String? imagePath;

  const TransactionEntity({
    this.id,
    required this.amount,
    required this.category,
    required this.dateTime,
    this.imagePath,
  });

  TransactionEntity copyWith({
    int? id,
    double? amount,
    String? category,
    DateTime? dateTime,
    String? imagePath,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionEntity &&
        other.id == id &&
        other.amount == amount &&
        other.category == category &&
        other.dateTime == dateTime &&
        other.imagePath == imagePath;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      amount.hashCode ^
      category.hashCode ^
      dateTime.hashCode ^
      imagePath.hashCode;
}
