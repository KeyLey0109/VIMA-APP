import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_database.dart';

/// Web implementation of AppDatabase using SharedPreferences JSON storage.
/// Provides full query/insert/update/delete with basic WHERE/ORDER BY support.
class _WebAppDatabase implements AppDatabase {
  final SharedPreferences _prefs;
  int _nextId;

  _WebAppDatabase(this._prefs) : _nextId = 1 {
    // Compute max id across all tables for auto-increment
    for (final table in ['users', 'budgets', 'transactions']) {
      final rows = _getTable(table);
      for (final row in rows) {
        final id = row['id'];
        if (id is int && id >= _nextId) {
          _nextId = id + 1;
        }
      }
    }

    _seedAdminUser();
  }

  void _seedAdminUser() {
    final users = _getTable('users');
    if (users.isEmpty) {
      final adminUser = {
        'id': _nextId++,
        'username': 'admin',
        'password': 'admin123',
        'display_name': 'VIMA Admin',
        'avatar_path': null,
        'created_at': DateTime.now().toIso8601String(),
      };
      users.add(adminUser);
      _saveTable('users', users);
    }
  }

  List<Map<String, dynamic>> _getTable(String table) {
    final json = _prefs.getString('web_db_$table');
    if (json == null || json.isEmpty) return [];
    try {
      return (jsonDecode(json) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveTable(
      String table, List<Map<String, dynamic>> rows) async {
    await _prefs.setString('web_db_$table', jsonEncode(rows));
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    var rows = _getTable(table);

    if (where != null && whereArgs != null) {
      rows = _filterRows(rows, where, whereArgs);
    }

    if (orderBy != null) {
      rows = _sortRows(rows, orderBy);
    }

    if (offset != null) rows = rows.skip(offset).toList();
    if (limit != null) rows = rows.take(limit).toList();

    return rows;
  }

  @override
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? nullColumnHack,
    dynamic conflictAlgorithm,
  }) async {
    final rows = _getTable(table);
    final isIgnore = conflictAlgorithm?.toString().contains('4') == true;

    // Check UNIQUE constraints
    if (table == 'users' && values.containsKey('username')) {
      if (rows.any((r) => r['username'] == values['username'])) {
        if (isIgnore) return -1;
        rows.removeWhere((r) => r['username'] == values['username']);
      }
    }
    if (table == 'budgets' &&
        values.containsKey('month') &&
        values.containsKey('year')) {
      if (rows.any((r) =>
          r['month'] == values['month'] && r['year'] == values['year'])) {
        if (isIgnore) return -1;
        rows.removeWhere((r) =>
            r['month'] == values['month'] && r['year'] == values['year']);
      }
    }

    final id = _nextId++;
    final row = Map<String, dynamic>.from(values);
    if (!row.containsKey('id') || row['id'] == null) {
      row['id'] = id;
    }
    rows.add(row);
    await _saveTable(table, rows);
    return row['id'] as int;
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
    dynamic conflictAlgorithm,
  }) async {
    final rows = _getTable(table);
    int count = 0;

    for (int i = 0; i < rows.length; i++) {
      if (where == null ||
          (whereArgs != null && _matchRow(rows[i], where, whereArgs))) {
        rows[i] = {...rows[i], ...values};
        count++;
      }
    }

    await _saveTable(table, rows);
    return count;
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final rows = _getTable(table);
    int count = 0;
    final remaining = <Map<String, dynamic>>[];

    for (final row in rows) {
      if (where != null &&
          whereArgs != null &&
          _matchRow(row, where, whereArgs)) {
        count++;
      } else {
        remaining.add(row);
      }
    }

    await _saveTable(table, remaining);
    return count;
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    // Handle COALESCE(SUM(amount), 0) queries
    if (sql.toUpperCase().contains('SUM(AMOUNT)')) {
      final tableMatch = RegExp(r'FROM\s+(\w+)', caseSensitive: false)
          .firstMatch(sql);
      final table = tableMatch?.group(1) ?? 'transactions';
      var rows = _getTable(table);

      // Apply WHERE
      final whereMatch =
          RegExp(r'WHERE\s+(.+)$', caseSensitive: false).firstMatch(sql);
      if (whereMatch != null && arguments != null) {
        rows = _filterRows(rows, whereMatch.group(1)!, arguments);
      }

      final total = rows.fold<double>(
        0,
        (sum, row) => sum + ((row['amount'] as num?)?.toDouble() ?? 0),
      );
      return [
        {'total': total}
      ];
    }
    return [];
  }

  // ─── WHERE clause helpers ──────────────────────────────────

  List<Map<String, dynamic>> _filterRows(
    List<Map<String, dynamic>> rows,
    String where,
    List<Object?> args,
  ) =>
      rows.where((row) => _matchRow(row, where, args)).toList();

  bool _matchRow(
    Map<String, dynamic> row,
    String where,
    List<Object?> args,
  ) {
    // Split on AND
    final conditions =
        where.trim().split(RegExp(r'\s+AND\s+', caseSensitive: false));
    int argIdx = 0;

    for (final condition in conditions) {
      if (argIdx >= args.length) break;
      final col = _extractColumn(condition);
      final rowVal = row[col]?.toString() ?? '';
      final argVal = args[argIdx]?.toString() ?? '';

      bool matches;
      if (condition.contains('>=')) {
        matches = rowVal.compareTo(argVal) >= 0;
      } else if (condition.contains('<=')) {
        matches = rowVal.compareTo(argVal) <= 0;
      } else if (RegExp(r'\s<\s').hasMatch(condition)) {
        matches = rowVal.compareTo(argVal) < 0;
      } else if (RegExp(r'\s>\s').hasMatch(condition)) {
        matches = rowVal.compareTo(argVal) > 0;
      } else if (condition.contains('=')) {
        // Numeric equality
        final rowNum = num.tryParse(rowVal);
        final argNum = num.tryParse(argVal);
        if (rowNum != null && argNum != null) {
          matches = rowNum == argNum;
        } else {
          matches = rowVal == argVal;
        }
      } else {
        matches = true;
      }

      if (!matches) return false;
      argIdx++;
    }
    return true;
  }

  String _extractColumn(String condition) {
    return condition
        .replaceAll('>= ?', '')
        .replaceAll('<= ?', '')
        .replaceAll('< ?', '')
        .replaceAll('> ?', '')
        .replaceAll('= ?', '')
        .replaceAll('>=', '')
        .replaceAll('<=', '')
        .replaceAll('>', '')
        .replaceAll('<', '')
        .replaceAll('=', '')
        .replaceAll('?', '')
        .trim();
  }

  List<Map<String, dynamic>> _sortRows(
    List<Map<String, dynamic>> rows,
    String orderBy,
  ) {
    final sorted = List<Map<String, dynamic>>.from(rows);
    final parts = orderBy.split(RegExp(r',\s*'));

    sorted.sort((a, b) {
      for (final part in parts) {
        final tokens = part.trim().split(RegExp(r'\s+'));
        final col = tokens[0];
        final desc = tokens.length > 1 && tokens[1].toUpperCase() == 'DESC';

        final aVal = a[col]?.toString() ?? '';
        final bVal = b[col]?.toString() ?? '';
        final cmp = aVal.compareTo(bVal);
        if (cmp != 0) return desc ? -cmp : cmp;
      }
      return 0;
    });
    return sorted;
  }
}

/// Web implementation of DatabaseHelper (SharedPreferences JSON backend)
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static _WebAppDatabase? _db;

  DatabaseHelper._init();

  Future<AppDatabase> get database async {
    if (_db != null) return _db!;
    try {
      final prefs = await SharedPreferences.getInstance();
      _db = _WebAppDatabase(prefs);
    } catch (_) {
      rethrow;
    }
    return _db!;
  }

  Future<void> close() async {
    _db = null;
  }
}
