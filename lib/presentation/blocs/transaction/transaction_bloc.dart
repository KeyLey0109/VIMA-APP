import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/transaction_usecases.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

/// Transaction BLoC - manages transaction state
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsUseCase getTransactions;
  final GetTransactionsByDateUseCase getTransactionsByDate;
  final GetTransactionsByMonthUseCase getTransactionsByMonth;
  final AddTransactionUseCase addTransaction;
  final DeleteTransactionUseCase deleteTransaction;
  final GetTotalSpendingByDateUseCase getTotalSpendingByDate;
  final GetTotalSpendingByMonthUseCase getTotalSpendingByMonth;
  final GetTransactionsGroupedByDateUseCase getTransactionsGroupedByDate;

  TransactionBloc({
    required this.getTransactions,
    required this.getTransactionsByDate,
    required this.getTransactionsByMonth,
    required this.addTransaction,
    required this.deleteTransaction,
    required this.getTotalSpendingByDate,
    required this.getTotalSpendingByMonth,
    required this.getTransactionsGroupedByDate,
  }) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadTransactionsByMonth>(_onLoadTransactionsByMonth);
    on<AddTransaction>(_onAddTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<LoadDashboardData>(_onLoadDashboardData);
    on<LoadCalendarData>(_onLoadCalendarData);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await getTransactions();
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onLoadTransactionsByMonth(
    LoadTransactionsByMonth event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions =
          await getTransactionsByMonth(event.month, event.year);
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      // Add a 3-second timeout for the database operation on Web
      await addTransaction(event.transaction)
          .timeout(const Duration(seconds: 3), onTimeout: () {
        throw Exception('Lưu chi tiêu quá lâu. Vui lòng thử lại.');
      });
      emit(TransactionAdded());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await deleteTransaction(event.id);
      emit(TransactionDeleted());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final now = DateTime.now();
      final transactions =
          await getTransactionsByMonth(event.month, event.year);
      final totalToday = await getTotalSpendingByDate(now);
      final totalMonth =
          await getTotalSpendingByMonth(event.month, event.year);
      final grouped =
          await getTransactionsGroupedByDate(event.month, event.year);

      emit(TransactionLoaded(
        transactions: transactions,
        totalSpendingToday: totalToday,
        totalSpendingMonth: totalMonth,
        groupedTransactions: grouped,
      ));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onLoadCalendarData(
    LoadCalendarData event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions =
          await getTransactionsByMonth(event.month, event.year);
      final totalMonth =
          await getTotalSpendingByMonth(event.month, event.year);
      final grouped =
          await getTransactionsGroupedByDate(event.month, event.year);

      emit(TransactionLoaded(
        transactions: transactions,
        totalSpendingMonth: totalMonth,
        groupedTransactions: grouped,
      ));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
