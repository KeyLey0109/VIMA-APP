/// Budget entity - Domain layer
/// Represents a monthly budget
class BudgetEntity {
  final int? id;
  final int month;
  final int year;
  final double amount;

  const BudgetEntity({
    this.id,
    required this.month,
    required this.year,
    required this.amount,
  });

  BudgetEntity copyWith({
    int? id,
    int? month,
    int? year,
    double? amount,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      month: month ?? this.month,
      year: year ?? this.year,
      amount: amount ?? this.amount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetEntity &&
        other.id == id &&
        other.month == month &&
        other.year == year &&
        other.amount == amount;
  }

  @override
  int get hashCode =>
      id.hashCode ^ month.hashCode ^ year.hashCode ^ amount.hashCode;
}
