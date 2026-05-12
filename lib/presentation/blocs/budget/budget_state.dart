import 'package:equatable/equatable.dart';
import '../../../domain/entities/budget_entity.dart';

/// Budget BLoC states
abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final BudgetEntity? budget;

  const BudgetLoaded({this.budget});

  @override
  List<Object?> get props => [budget];
}

class BudgetSaved extends BudgetState {
  final BudgetEntity budget;

  const BudgetSaved(this.budget);

  @override
  List<Object?> get props => [budget];
}

class BudgetError extends BudgetState {
  final String message;

  const BudgetError(this.message);

  @override
  List<Object?> get props => [message];
}
