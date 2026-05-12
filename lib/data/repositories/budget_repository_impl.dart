import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_data_source.dart';
import '../datasources/firestore_sync_service.dart';
import '../models/budget_model.dart';

/// Implementation of BudgetRepository using local SQLite database
class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;
  final FirestoreSyncService firestoreSyncService;

  BudgetRepositoryImpl({
    required this.localDataSource,
    required this.firestoreSyncService,
  });

  @override
  Future<BudgetEntity?> getBudget(int month, int year) async {
    return await localDataSource.getBudget(month, year);
  }

  @override
  Future<List<BudgetEntity>> getAllBudgets() async {
    return await localDataSource.getAllBudgets();
  }

  @override
  Future<BudgetEntity> setBudget(BudgetEntity budget) async {
    final model = BudgetModel.fromEntity(budget);
    final savedModel = await localDataSource.setBudget(model);
    
    // Sync in background (non-blocking)
    firestoreSyncService.syncBudget(savedModel);
    
    return savedModel;
  }

  @override
  Future<void> deleteBudget(int id) async {
    await localDataSource.deleteBudget(id);
    // Sync in background (non-blocking)
    firestoreSyncService.deleteBudget(id);
  }
}
