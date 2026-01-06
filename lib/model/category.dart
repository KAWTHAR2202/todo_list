import 'package:flutter/material.dart';

class Category {
  int? id;
  String name;
  int colorValue;
  String icon;

  Category({
    this.id,
    required this.name,
    required this.colorValue,
    this.icon = 'folder',
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'colorValue': colorValue, 'icon': icon};
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      colorValue: map['colorValue'] as int,
      icon: map['icon'] as String? ?? 'folder',
    );
  }

  Category copyWith({int? id, String? name, int? colorValue, String? icon}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      icon: icon ?? this.icon,
    );
  }

  // Catégories par défaut
  static List<Category> defaultCategories = [
    Category(name: 'Personal', colorValue: Colors.blue.value, icon: 'person'),
    Category(name: 'Work', colorValue: Colors.orange.value, icon: 'work'),
    Category(
      name: 'Shopping',
      colorValue: Colors.green.value,
      icon: 'shopping_cart',
    ),
    Category(name: 'Health', colorValue: Colors.red.value, icon: 'favorite'),
  ];

  // Map des icônes disponibles
  static Map<String, IconData> iconMap = {
    'folder': Icons.folder,
    'person': Icons.person,
    'work': Icons.work,
    'shopping_cart': Icons.shopping_cart,
    'favorite': Icons.favorite,
    'school': Icons.school,
    'home': Icons.home,
    'fitness_center': Icons.fitness_center,
    'restaurant': Icons.restaurant,
    'flight': Icons.flight,
    'code': Icons.code,
    'music_note': Icons.music_note,
    'sports': Icons.sports_soccer,
    'book': Icons.book,
  };

  IconData get iconData => iconMap[icon] ?? Icons.folder;
}
