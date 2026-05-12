import '../../domain/entities/transaction_entity.dart';

/// Data model for Transaction - handles serialization to/from database
class TransactionModel extends TransactionEntity {
  const TransactionModel({
    super.id,
    required super.amount,
    required super.category,
    required super.dateTime,
    super.imagePath,
  });

  /// Create from database map
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      dateTime: DateTime.parse(map['date_time'] as String),
      imagePath: map['image_path'] as String?,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'category': category,
      'date_time': dateTime.toIso8601String(),
      'image_path': imagePath,
    };
  }

  /// Create from entity
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      amount: entity.amount,
      category: entity.category,
      dateTime: entity.dateTime,
      imagePath: entity.imagePath,
    );
  }
}
