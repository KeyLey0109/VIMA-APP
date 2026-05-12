import 'package:flutter/material.dart';

/// Category model for expense categorization
class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Predefined expense categories
class AppCategories {
  AppCategories._();

  static const List<CategoryItem> categories = [
    CategoryItem(
      name: 'Ăn uống',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFFF6B6B),
    ),
    CategoryItem(
      name: 'Di chuyển',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF4ECDC4),
    ),
    CategoryItem(
      name: 'Mua sắm',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFFFE66D),
    ),
    CategoryItem(
      name: 'Giải trí',
      icon: Icons.movie_rounded,
      color: Color(0xFFA78BFA),
    ),
    CategoryItem(
      name: 'Sức khỏe',
      icon: Icons.favorite_rounded,
      color: Color(0xFF22D3EE),
    ),
    CategoryItem(
      name: 'Hóa đơn',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFFFB923C),
    ),
    CategoryItem(
      name: 'Giáo dục',
      icon: Icons.school_rounded,
      color: Color(0xFF34D399),
    ),
    CategoryItem(
      name: 'Thu nhập',
      icon: Icons.attach_money_rounded,
      color: Color(0xFF00D9A6),
    ),
    CategoryItem(
      name: 'Khác',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF94A3B8),
    ),
  ];

  /// Get CategoryItem by name
  static CategoryItem getCategoryByName(String name) {
    return categories.firstWhere(
      (cat) => cat.name.trim() == name.trim(),
      orElse: () => categories.last,
    );
  }
}
