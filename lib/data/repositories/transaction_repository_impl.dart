import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/firestore_sync_service.dart';
import '../datasources/transaction_local_data_source.dart';
import '../models/transaction_model.dart';

/// Implementation of TransactionRepository using local SQLite database
/// and syncing to Firestore.
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;
  final FirestoreSyncService firestoreSyncService;

  TransactionRepositoryImpl({
    required this.localDataSource,
    required this.firestoreSyncService,
  });

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    return await localDataSource.getAllTransactions();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByDate(DateTime date) async {
    return await localDataSource.getTransactionsByDate(date);
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByMonth(
      int month, int year) async {
    return await localDataSource.getTransactionsByMonth(month, year);
  }

  @override
  Future<TransactionEntity> addTransaction(
      TransactionEntity transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    final savedModel = await localDataSource.addTransaction(model);
    
    // Sync to Firestore in background (non-blocking)
    firestoreSyncService.syncTransaction(savedModel);
    
    return savedModel;
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await localDataSource.updateTransaction(model);
    
    // Sync to Firestore in background (non-blocking)
    firestoreSyncService.syncTransaction(model);
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await localDataSource.deleteTransaction(id);
    
    // Sync to Firestore in background (non-blocking)
    firestoreSyncService.deleteTransaction(id);
  }

  @override
  Future<double> getTotalSpendingByDate(DateTime date) async {
    return await localDataSource.getTotalSpendingByDate(date);
  }

  @override
  Future<double> getTotalSpendingByMonth(int month, int year) async {
    return await localDataSource.getTotalSpendingByMonth(month, year);
  }

  @override
  Future<Map<DateTime, List<TransactionEntity>>> getTransactionsGroupedByDate(
      int month, int year) async {
    final transactions =
        await localDataSource.getTransactionsByMonth(month, year);
    final Map<DateTime, List<TransactionEntity>> grouped = {};

    for (final transaction in transactions) {
      final dateKey = DateTime(
        transaction.dateTime.year,
        transaction.dateTime.month,
        transaction.dateTime.day,
      );
      grouped.putIfAbsent(dateKey, () => []).add(transaction);
    }

    return grouped;
  }
}
