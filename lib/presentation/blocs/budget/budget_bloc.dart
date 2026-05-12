import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/budget_usecases.dart';
import 'budget_event.dart';
import 'budget_state.dart';

/// Budget BLoC - manages budget state
class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final GetBudgetUseCase getBudget;
  final SetBudgetUseCase setBudget;

  BudgetBloc({
    required this.getBudget,
    required this.setBudget,
  }) : super(BudgetInitial()) {
    on<LoadBudget>(_onLoadBudget);
    on<SetBudget>(_onSetBudget);
  }

  Future<void> _onLoadBudget(
    LoadBudget event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final budget = await getBudget(event.month, event.year);
      emit(BudgetLoaded(budget: budget));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onSetBudget(
    SetBudget event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      final budget = await setBudget(event.budget);
      emit(BudgetSaved(budget));
      // Emit BudgetLoaded immediately to update UI with latest budget
      emit(BudgetLoaded(budget: budget));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }
}
