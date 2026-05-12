import '../models/transaction_model.dart';
import 'app_database.dart';
import 'database_helper.dart';

/// Local data source for transaction operations
class TransactionLocalDataSource {
  final DatabaseHelper databaseHelper;

  TransactionLocalDataSource({required this.databaseHelper});

  Future<AppDatabase> get _db => databaseHelper.database;

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await _db;
    final maps = await db.query(
      'transactions',
      orderBy: 'date_time DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByDate(DateTime date) async {
    final db = await _db;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final maps = await db.query(
      'transactions',
      where: 'date_time >= ? AND date_time < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'date_time DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByMonth(
      int month, int year) async {
    final db = await _db;
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 1);

    final maps = await db.query(
      'transactions',
      where: 'date_time >= ? AND date_time < ?',
      whereArgs: [
        startOfMonth.toIso8601String(),
        endOfMonth.toIso8601String(),
      ],
      orderBy: 'date_time DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    final db = await _db;
    final id = await db.insert('transactions', transaction.toMap());
    return TransactionModel(
      id: id,
      amount: transaction.amount,
      category: transaction.category,
      dateTime: transaction.dateTime,
      imagePath: transaction.imagePath,
    );
  }

  Future<void> restoreTransaction(TransactionModel transaction) async {
    final db = await _db;
    await db.insert(
      'transactions',
      transaction.toMap(),
      // 5 = ConflictAlgorithm.replace
      conflictAlgorithm: 5,
    );
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final db = await _db;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(int id) async {
    final db = await _db;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalSpendingByDate(DateTime date) async {
    final db = await _db;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE date_time >= ? AND date_time < ?',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalSpendingByMonth(int month, int year) async {
    final db = await _db;
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 1);

    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE date_time >= ? AND date_time < ?',
      [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
