import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/user_local_data_source.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/widgets/animated_rainbow.dart';

import 'presentation/blocs/theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase not configured. Please run flutterfire configure: $e');
  }

  // Initialize Vietnamese locale for date formatting
  await initializeDateFormatting('vi_VN', null);

  // Initialize dependency injection
  await initDependencies();

  // Initialize notifications
  await NotificationService().initNotifications();

  // Check initial auth status
  final userLocalDataSource = sl<UserLocalDataSource>();
  final userId = await userLocalDataSource.getCachedUserId();

  runApp(
    RainbowAnimationGroup(
      child: MoneyApp(isLoggedIn: userId != null),
    ),
  );
}

class MoneyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MoneyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(CheckAuthStatus()),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => sl<ThemeCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'VIMA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }
}
