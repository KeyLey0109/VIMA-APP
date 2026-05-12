import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  final TransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<List<TransactionEntity>> call() => repository.getAllTransactions();
}

class GetTransactionsByDateUseCase {
  final TransactionRepository repository;

  GetTransactionsByDateUseCase(this.repository);

  Future<List<TransactionEntity>> call(DateTime date) =>
      repository.getTransactionsByDate(date);
}

class GetTransactionsByMonthUseCase {
  final TransactionRepository repository;

  GetTransactionsByMonthUseCase(this.repository);

  Future<List<TransactionEntity>> call(int month, int year) =>
      repository.getTransactionsByMonth(month, year);
}

class AddTransactionUseCase {
  final TransactionRepository repository;

  AddTransactionUseCase(this.repository);

  Future<TransactionEntity> call(TransactionEntity transaction) =>
      repository.addTransaction(transaction);
}

class UpdateTransactionUseCase {
  final TransactionRepository repository;

  UpdateTransactionUseCase(this.repository);

  Future<void> call(TransactionEntity transaction) =>
      repository.updateTransaction(transaction);
}

class DeleteTransactionUseCase {
  final TransactionRepository repository;

  DeleteTransactionUseCase(this.repository);

  Future<void> call(int id) => repository.deleteTransaction(id);
}

class GetTotalSpendingByDateUseCase {
  final TransactionRepository repository;

  GetTotalSpendingByDateUseCase(this.repository);

  Future<double> call(DateTime date) =>
      repository.getTotalSpendingByDate(date);
}

class GetTotalSpendingByMonthUseCase {
  final TransactionRepository repository;

  GetTotalSpendingByMonthUseCase(this.repository);

  Future<double> call(int month, int year) =>
      repository.getTotalSpendingByMonth(month, year);
}

class GetTransactionsGroupedByDateUseCase {
  final TransactionRepository repository;

  GetTransactionsGroupedByDateUseCase(this.repository);

  Future<Map<DateTime, List<TransactionEntity>>> call(int month, int year) =>
      repository.getTransactionsGroupedByDate(month, year);
}
