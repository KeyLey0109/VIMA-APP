import '../entities/transaction_entity.dart';

/// Abstract repository for transaction operations
abstract class TransactionRepository {
  Future<List<TransactionEntity>> getAllTransactions();
  Future<List<TransactionEntity>> getTransactionsByDate(DateTime date);
  Future<List<TransactionEntity>> getTransactionsByMonth(int month, int year);
  Future<TransactionEntity> addTransaction(TransactionEntity transaction);
  Future<void> updateTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(int id);
  Future<double> getTotalSpendingByDate(DateTime date);
  Future<double> getTotalSpendingByMonth(int month, int year);
  Future<Map<DateTime, List<TransactionEntity>>> getTransactionsGroupedByDate(
      int month, int year);
}
