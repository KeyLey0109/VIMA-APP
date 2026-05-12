import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction_entity.dart';

/// Transaction BLoC events
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {}

class LoadTransactionsByDate extends TransactionEvent {
  final DateTime date;

  const LoadTransactionsByDate(this.date);

  @override
  List<Object?> get props => [date];
}

class LoadTransactionsByMonth extends TransactionEvent {
  final int month;
  final int year;

  const LoadTransactionsByMonth(this.month, this.year);

  @override
  List<Object?> get props => [month, year];
}

class AddTransaction extends TransactionEvent {
  final TransactionEntity transaction;

  const AddTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransaction extends TransactionEvent {
  final int id;

  const DeleteTransaction(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadDashboardData extends TransactionEvent {
  final int month;
  final int year;

  const LoadDashboardData(this.month, this.year);

  @override
  List<Object?> get props => [month, year];
}

class LoadCalendarData extends TransactionEvent {
  final int month;
  final int year;

  const LoadCalendarData(this.month, this.year);

  @override
  List<Object?> get props => [month, year];
}
