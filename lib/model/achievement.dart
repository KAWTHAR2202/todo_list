import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int targetValue;
  int currentValue;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.targetValue,
    this.currentValue = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'currentValue': currentValue,
      'isUnlocked': isUnlocked ? 1 : 0,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map, Achievement template) {
    return Achievement(
      id: template.id,
      title: template.title,
      description: template.description,
      icon: template.icon,
      color: template.color,
      targetValue: template.targetValue,
      currentValue: map['currentValue'] ?? 0,
      isUnlocked: map['isUnlocked'] == 1,
      unlockedAt: map['unlockedAt'] != null 
          ? DateTime.parse(map['unlockedAt']) 
          : null,
    );
  }

  static List<Achievement> defaultAchievements = [
    Achievement(
      id: 'first_task',
      title: 'Premier pas',
      description: 'Créez votre première tâche',
      icon: Icons.flag,
      color: Colors.green,
      targetValue: 1,
    ),
    Achievement(
      id: 'task_master_10',
      title: 'Productif',
      description: 'Complétez 10 tâches',
      icon: Icons.check_circle,
      color: Colors.blue,
      targetValue: 10,
    ),
    Achievement(
      id: 'task_master_50',
      title: 'Expert en tâches',
      description: 'Complétez 50 tâches',
      icon: Icons.workspace_premium,
      color: Colors.purple,
      targetValue: 50,
    ),
    Achievement(
      id: 'task_master_100',
      title: 'Maître des tâches',
      description: 'Complétez 100 tâches',
      icon: Icons.emoji_events,
      color: Colors.amber,
      targetValue: 100,
    ),
    Achievement(
      id: 'streak_3',
      title: 'En route',
      description: 'Complétez des tâches 3 jours de suite',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      targetValue: 3,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Semaine parfaite',
      description: 'Complétez des tâches 7 jours de suite',
      icon: Icons.whatshot,
      color: Colors.deepOrange,
      targetValue: 7,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Inarrêtable',
      description: 'Complétez des tâches 30 jours de suite',
      icon: Icons.military_tech,
      color: Colors.red,
      targetValue: 30,
    ),
    Achievement(
      id: 'pomodoro_5',
      title: 'Focalisé',
      description: 'Complétez 5 sessions Pomodoro',
      icon: Icons.timer,
      color: Colors.teal,
      targetValue: 5,
    ),
    Achievement(
      id: 'pomodoro_25',
      title: 'Maître du temps',
      description: 'Complétez 25 sessions Pomodoro',
      icon: Icons.hourglass_full,
      color: Colors.indigo,
      targetValue: 25,
    ),
    Achievement(
      id: 'category_creator',
      title: 'Organisateur',
      description: 'Créez 5 catégories',
      icon: Icons.category,
      color: Colors.pink,
      targetValue: 5,
    ),
    Achievement(
      id: 'early_bird',
      title: 'Lève-tôt',
      description: 'Complétez une tâche avant 8h',
      icon: Icons.wb_sunny,
      color: Colors.yellow.shade700,
      targetValue: 1,
    ),
    Achievement(
      id: 'night_owl',
      title: 'Oiseau de nuit',
      description: 'Complétez une tâche après 22h',
      icon: Icons.nightlight_round,
      color: Colors.deepPurple,
      targetValue: 1,
    ),
  ];
}
