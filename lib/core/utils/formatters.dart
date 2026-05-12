import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Utility functions for currency and date formatting
class AppFormatters {
  AppFormatters._();

  /// Format amount in Vietnamese currency
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format amount with separators but no symbol (for input)
  static String formatNumber(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(amount);
  }

  /// Format date to readable string
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format date with day of week
  static String formatDateFull(DateTime date) {
    return DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(date);
  }

  /// Format time
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Format date and time
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Format month/year
  static String formatMonthYear(int month, int year) {
    final date = DateTime(year, month);
    return DateFormat('MMMM yyyy', 'vi_VN').format(date);
  }

  /// Format relative date (Today, Yesterday, etc.)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) return 'Hôm nay';
    if (difference == 1) return 'Hôm qua';
    if (difference < 7) return '$difference ngày trước';
    return formatDate(date);
  }

  /// Parse currency string to double
  static double? parseCurrency(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }
}

/// Custom input formatter for currency display
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // Remove all non-digits to handle existing separators or manual user input
    final cleaned = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.isEmpty) return const TextEditingValue();

    final number = int.tryParse(cleaned);
    if (number == null) return oldValue;

    final formatted = AppFormatters.formatNumber(number.toDouble());

    // Calculate selection index based on the number of digits before the cursor
    final oldSelectionIndex = newValue.selection.end;
    int digitsBeforeCursor = 0;
    for (int i = 0; i < oldSelectionIndex; i++) {
      if (i < newValue.text.length && RegExp(r'\d').hasMatch(newValue.text[i])) {
        digitsBeforeCursor++;
      }
    }

    int newSelectionIndex = 0;
    int foundDigits = 0;
    while (foundDigits < digitsBeforeCursor &&
        newSelectionIndex < formatted.length) {
      if (RegExp(r'\d').hasMatch(formatted[newSelectionIndex])) {
        foundDigits++;
      }
      newSelectionIndex++;
    }

    // Crucial for Web: Ensure selection is within bounds and clear composing range
    final finalOffset = newSelectionIndex.clamp(0, formatted.length);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: finalOffset),
      composing: TextRange.empty,
    );
  }
}
