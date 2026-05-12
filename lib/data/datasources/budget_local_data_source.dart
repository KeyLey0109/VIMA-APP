import '../models/budget_model.dart';
import 'app_database.dart';
import 'database_helper.dart';

/// Local data source for budget operations
class BudgetLocalDataSource {
  final DatabaseHelper databaseHelper;

  BudgetLocalDataSource({required this.databaseHelper});

  Future<AppDatabase> get _db => databaseHelper.database;

  Future<BudgetModel?> getBudget(int month, int year) async {
    final db = await _db;
    final maps = await db.query(
      'budgets',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
    if (maps.isEmpty) return null;
    return BudgetModel.fromMap(maps.first);
  }

  Future<List<BudgetModel>> getAllBudgets() async {
    final db = await _db;
    final maps = await db.query(
      'budgets',
      orderBy: 'year DESC, month DESC',
    );
    return maps.map((map) => BudgetModel.fromMap(map)).toList();
  }

  Future<BudgetModel> setBudget(BudgetModel budget) async {
    final db = await _db;

    // Check if budget exists for this month/year
    final existing = await getBudget(budget.month, budget.year);

    if (existing != null) {
      // Update existing budget
      await db.update(
        'budgets',
        budget.toMap(),
        where: 'month = ? AND year = ?',
        whereArgs: [budget.month, budget.year],
      );
      return BudgetModel(
        id: existing.id,
        month: budget.month,
        year: budget.year,
        amount: budget.amount,
      );
    } else {
      // Insert new budget
      final id = await db.insert('budgets', budget.toMap());
      return BudgetModel(
        id: id,
        month: budget.month,
        year: budget.year,
        amount: budget.amount,
      );
    }
  }

  Future<void> restoreBudget(BudgetModel budget) async {
    final db = await _db;
    await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: 5,
    );
  }

  Future<void> deleteBudget(int id) async {
    final db = await _db;
    await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
