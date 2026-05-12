import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

class GetBudgetUseCase {
  final BudgetRepository repository;

  GetBudgetUseCase(this.repository);

  Future<BudgetEntity?> call(int month, int year) =>
      repository.getBudget(month, year);
}

class GetAllBudgetsUseCase {
  final BudgetRepository repository;

  GetAllBudgetsUseCase(this.repository);

  Future<List<BudgetEntity>> call() => repository.getAllBudgets();
}

class SetBudgetUseCase {
  final BudgetRepository repository;

  SetBudgetUseCase(this.repository);

  Future<BudgetEntity> call(BudgetEntity budget) =>
      repository.setBudget(budget);
}

class DeleteBudgetUseCase {
  final BudgetRepository repository;

  DeleteBudgetUseCase(this.repository);

  Future<void> call(int id) => repository.deleteBudget(id);
}
