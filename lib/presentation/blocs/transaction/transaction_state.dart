import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction_entity.dart';

/// Transaction BLoC states
abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  final double totalSpendingToday;
  final double totalSpendingMonth;
  final Map<DateTime, List<TransactionEntity>> groupedTransactions;

  const TransactionLoaded({
    this.transactions = const [],
    this.totalSpendingToday = 0,
    this.totalSpendingMonth = 0,
    this.groupedTransactions = const {},
  });

  TransactionLoaded copyWith({
    List<TransactionEntity>? transactions,
    double? totalSpendingToday,
    double? totalSpendingMonth,
    Map<DateTime, List<TransactionEntity>>? groupedTransactions,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      totalSpendingToday: totalSpendingToday ?? this.totalSpendingToday,
      totalSpendingMonth: totalSpendingMonth ?? this.totalSpendingMonth,
      groupedTransactions: groupedTransactions ?? this.groupedTransactions,
    );
  }

  @override
  List<Object?> get props => [
        transactions,
        totalSpendingToday,
        totalSpendingMonth,
        groupedTransactions,
      ];
}

class TransactionAdded extends TransactionState {}

class TransactionDeleted extends TransactionState {}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
