import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import 'budget_local_data_source.dart';
import 'transaction_local_data_source.dart';
import 'user_local_data_source.dart';

class FirestoreSyncService {
  final FirebaseFirestore _firestore;
  final UserLocalDataSource _userLocalDataSource;
  final TransactionLocalDataSource _transactionLocalDataSource;
  final BudgetLocalDataSource _budgetLocalDataSource;

  FirestoreSyncService({
    FirebaseFirestore? firestore,
    required UserLocalDataSource userLocalDataSource,
    required TransactionLocalDataSource transactionLocalDataSource,
    required BudgetLocalDataSource budgetLocalDataSource,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _userLocalDataSource = userLocalDataSource,
        _transactionLocalDataSource = transactionLocalDataSource,
        _budgetLocalDataSource = budgetLocalDataSource;

  Future<String?> _getUserId() async {
    final userId = await _userLocalDataSource.getCachedUserId();
    return userId?.toString();
  }

  // --- User Account Sync ---

  /// Saves user account to Firebase (called on register)
  Future<void> syncUser(UserModel user) async {
    try {
      await _firestore
          .collection('accounts')
          .doc(user.username)
          .set(user.toMap());
      debugPrint('User synced to Firestore: ${user.username}');
    } catch (e) {
      debugPrint('Error syncing user: $e');
    }
  }

  /// Attempts to find user credentials on Firebase (called when local login fails)
  Future<UserModel?> loginFromFirestore(String username, String password) async {
    try {
      final doc = await _firestore
          .collection('accounts')
          .doc(username)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      if (data['password'] != password) return null;

      return UserModel.fromMap(data);
    } catch (e) {
      debugPrint('Error logging in from Firestore: $e');
      return null;
    }
  }

  /// Pulls all data from Firestore for the current user and overwrites local data.
  Future<void> restoreDataFromFirestore() async {
    try {
      final userId = await _getUserId();
      if (userId == null) return;

      // 1. Restore Transactions
      final transactionsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();

      for (var doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final transaction = TransactionModel.fromMap(data);
        await _transactionLocalDataSource.restoreTransaction(transaction);
      }

      // 2. Restore Budgets
      final budgetsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .get();

      for (var doc in budgetsSnapshot.docs) {
        final data = doc.data();
        final budget = BudgetModel.fromMap(data);
        await _budgetLocalDataSource.restoreBudget(budget);
      }
      debugPrint('Restore from Firestore completed successfully.');
    } catch (e) {
      debugPrint('Error restoring from Firestore: $e');
    }
  }

  /// Pushes ALL local transactions and budgets to Firestore.
  Future<void> pushAllDataToFirestore() async {
    try {
      final userId = await _getUserId();
      if (userId == null) return;

      // 1. Push all transactions
      final transactions =
          await _transactionLocalDataSource.getAllTransactions();
      for (var tx in transactions) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc(tx.id.toString())
            .set(tx.toMap());
      }

      // 2. Push all budgets
      final budgets = await _budgetLocalDataSource.getAllBudgets();
      for (var budget in budgets) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('budgets')
            .doc(budget.id.toString())
            .set(budget.toMap());
      }

      debugPrint(
          'Push all data completed: ${transactions.length} transactions, ${budgets.length} budgets.');
    } catch (e) {
      debugPrint('Error pushing all data to Firestore: $e');
    }
  }

  // --- Transactions ---

  Future<void> syncTransaction(TransactionModel transaction) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return; // User not logged in

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transaction.id.toString());
          
      await docRef.set(transaction.toMap());
    } catch (e) {
      debugPrint('Error syncing transaction: $e');
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId.toString())
          .delete();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }

  // --- Budgets ---

  Future<void> syncBudget(BudgetModel budget) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return;

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budget.id.toString());
          
      await docRef.set(budget.toMap());
    } catch (e) {
      debugPrint('Error syncing budget: $e');
    }
  }

  Future<void> deleteBudget(int budgetId) async {
    try {
      final userId = await _getUserId();
      if (userId == null) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budgetId.toString())
          .delete();
    } catch (e) {
      debugPrint('Error deleting budget: $e');
    }
  }
}
