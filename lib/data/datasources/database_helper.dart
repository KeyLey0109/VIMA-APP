// This file acts as the main entry point for DatabaseHelper.
// It uses conditional imports to pick the right implementation.
export 'database_helper_mobile.dart'
    if (dart.library.html) 'database_helper_web.dart';
