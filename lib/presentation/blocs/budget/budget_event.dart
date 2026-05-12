import 'package:equatable/equatable.dart';
import '../../../domain/entities/budget_entity.dart';

/// Budget BLoC events
abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

class LoadBudget extends BudgetEvent {
  final int month;
  final int year;

  const LoadBudget(this.month, this.year);

  @override
  List<Object?> get props => [month, year];
}

class SetBudget extends BudgetEvent {
  final BudgetEntity budget;

  const SetBudget(this.budget);

  @override
  List<Object?> get props => [budget];
}
