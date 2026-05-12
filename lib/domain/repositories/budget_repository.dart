import '../entities/budget_entity.dart';

/// Abstract repository for budget operations
abstract class BudgetRepository {
  Future<BudgetEntity?> getBudget(int month, int year);
  Future<List<BudgetEntity>> getAllBudgets();
  Future<BudgetEntity> setBudget(BudgetEntity budget);
  Future<void> deleteBudget(int id);
}
