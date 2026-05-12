import '../../domain/entities/budget_entity.dart';

/// Data model for Budget - handles serialization to/from database
class BudgetModel extends BudgetEntity {
  const BudgetModel({
    super.id,
    required super.month,
    required super.year,
    required super.amount,
  });

  /// Create from database map
  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as int?,
      month: map['month'] as int,
      year: map['year'] as int,
      amount: (map['amount'] as num).toDouble(),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'month': month,
      'year': year,
      'amount': amount,
    };
  }

  /// Create from entity
  factory BudgetModel.fromEntity(BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      month: entity.month,
      year: entity.year,
      amount: entity.amount,
    );
  }
}
