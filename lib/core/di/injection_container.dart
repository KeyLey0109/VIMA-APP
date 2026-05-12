import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/budget_local_data_source.dart';
import '../../data/datasources/database_helper.dart';
import '../../data/datasources/firestore_sync_service.dart';
import '../../data/datasources/transaction_local_data_source.dart';
import '../../data/datasources/user_local_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/budget_usecases.dart';
import '../../domain/usecases/transaction_usecases.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/budget/budget_bloc.dart';
import '../../presentation/blocs/transaction/transaction_bloc.dart';
import '../../presentation/blocs/theme/theme_cubit.dart';
import '../utils/image_helper.dart';

final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initDependencies() async {
  // ─── External ──────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // ─── Database ──────────────────────────────────
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);

  // ─── Data Sources ──────────────────────────────
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionLocalDataSource(databaseHelper: sl()),
  );
  sl.registerLazySingleton<BudgetLocalDataSource>(
    () => BudgetLocalDataSource(databaseHelper: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(databaseHelper: sl()),
  );
  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<FirestoreSyncService>(
    () => FirestoreSyncService(
      userLocalDataSource: sl(),
      transactionLocalDataSource: sl(),
      budgetLocalDataSource: sl(),
    ),
  );

  // ─── Repositories ─────────────────────────────
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(
      localDataSource: sl(),
      firestoreSyncService: sl(),
    ),
  );
  sl.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(
      localDataSource: sl(),
      firestoreSyncService: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: sl(),
      firestoreSyncService: sl(),
    ),
  );

  // ─── Use Cases (Transaction) ──────────────────
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => GetTransactionsByDateUseCase(sl()));
  sl.registerLazySingleton(() => GetTransactionsByMonthUseCase(sl()));
  sl.registerLazySingleton(() => AddTransactionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTransactionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTransactionUseCase(sl()));
  sl.registerLazySingleton(() => GetTotalSpendingByDateUseCase(sl()));
  sl.registerLazySingleton(() => GetTotalSpendingByMonthUseCase(sl()));
  sl.registerLazySingleton(() => GetTransactionsGroupedByDateUseCase(sl()));

  // ─── Use Cases (Budget) ───────────────────────
  sl.registerLazySingleton(() => GetBudgetUseCase(sl()));
  sl.registerLazySingleton(() => GetAllBudgetsUseCase(sl()));
  sl.registerLazySingleton(() => SetBudgetUseCase(sl()));
  sl.registerLazySingleton(() => DeleteBudgetUseCase(sl()));

  // ─── Use Cases (Auth) ─────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => CheckUsernameUseCase(sl()));
  sl.registerLazySingleton(() => GetUserByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(sl()));

  // ─── Utilities ────────────────────────────────
  sl.registerLazySingleton(() => ImageHelper());

  // ─── BLoCs ────────────────────────────────────
  sl.registerFactory(() => TransactionBloc(
        getTransactions: sl(),
        getTransactionsByDate: sl(),
        getTransactionsByMonth: sl(),
        addTransaction: sl(),
        deleteTransaction: sl(),
        getTotalSpendingByDate: sl(),
        getTotalSpendingByMonth: sl(),
        getTransactionsGroupedByDate: sl(),
      ));

  sl.registerFactory(() => BudgetBloc(
        getBudget: sl(),
        setBudget: sl(),
      ));

  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        checkUsernameUseCase: sl(),
        getUserByIdUseCase: sl(),
        updateUserUseCase: sl(),
        userLocalDataSource: sl(),
        firestoreSyncService: sl(),
      ));

  sl.registerLazySingleton(() => ThemeCubit(sharedPreferences: sl()));
}
