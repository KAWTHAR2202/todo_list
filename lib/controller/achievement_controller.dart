import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/achievement.dart';

class AchievementController extends GetxController {
  static AchievementController get to => Get.find();
  
  final achievements = <Achievement>[].obs;
  final totalPoints = 0.obs;
  final currentStreak = 0.obs;
  final lastCompletionDate = Rxn<DateTime>();
  final totalTasksCompleted = 0.obs;
  final totalPomodoroSessions = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load stats
    totalTasksCompleted.value = prefs.getInt('totalTasksCompleted') ?? 0;
    totalPomodoroSessions.value = prefs.getInt('totalPomodoroSessions') ?? 0;
    currentStreak.value = prefs.getInt('currentStreak') ?? 0;
    
    final lastDateStr = prefs.getString('lastCompletionDate');
    if (lastDateStr != null) {
      lastCompletionDate.value = DateTime.parse(lastDateStr);
    }
    
    // Load achievements progress
    final savedAchievements = prefs.getString('achievements');
    Map<String, dynamic> savedData = {};
    if (savedAchievements != null) {
      savedData = json.decode(savedAchievements);
    }
    
    achievements.value = Achievement.defaultAchievements.map((template) {
      if (savedData.containsKey(template.id)) {
        return Achievement.fromMap(savedData[template.id], template);
      }
      return Achievement(
        id: template.id,
        title: template.title,
        description: template.description,
        icon: template.icon,
        color: template.color,
        targetValue: template.targetValue,
      );
    }).toList();
    
    _calculatePoints();
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    
    final data = <String, dynamic>{};
    for (var achievement in achievements) {
      data[achievement.id] = achievement.toMap();
    }
    
    await prefs.setString('achievements', json.encode(data));
    await prefs.setInt('totalTasksCompleted', totalTasksCompleted.value);
    await prefs.setInt('totalPomodoroSessions', totalPomodoroSessions.value);
    await prefs.setInt('currentStreak', currentStreak.value);
    if (lastCompletionDate.value != null) {
      await prefs.setString('lastCompletionDate', lastCompletionDate.value!.toIso8601String());
    }
  }

  void _calculatePoints() {
    totalPoints.value = achievements
        .where((a) => a.isUnlocked)
        .length * 100;
  }

  void _checkAndUnlock(String achievementId, int newValue) {
    final index = achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1) return;
    
    final achievement = achievements[index];
    achievement.currentValue = newValue;
    
    if (!achievement.isUnlocked && achievement.currentValue >= achievement.targetValue) {
      achievement.isUnlocked = true;
      achievement.unlockedAt = DateTime.now();
      achievements[index] = achievement;
      _showUnlockNotification(achievement);
      _calculatePoints();
    } else {
      achievements[index] = achievement;
    }
    
    achievements.refresh();
    _saveAchievements();
  }

  void _showUnlockNotification(Achievement achievement) {
    Get.snackbar(
      '🎉 Badge débloqué !',
      achievement.title,
      backgroundColor: achievement.color.withOpacity(0.9),
      colorText: Colors.white,
      icon: Icon(achievement.icon, color: Colors.white),
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void onTaskCreated() {
    _checkAndUnlock('first_task', 1);
  }

  void onTaskCompleted() {
    totalTasksCompleted.value++;
    
    // Check time-based achievements
    final now = DateTime.now();
    if (now.hour < 8) {
      _checkAndUnlock('early_bird', 1);
    }
    if (now.hour >= 22) {
      _checkAndUnlock('night_owl', 1);
    }
    
    // Update streak
    _updateStreak();
    
    // Check task completion achievements
    _checkAndUnlock('task_master_10', totalTasksCompleted.value);
    _checkAndUnlock('task_master_50', totalTasksCompleted.value);
    _checkAndUnlock('task_master_100', totalTasksCompleted.value);
    
    // Check streak achievements
    _checkAndUnlock('streak_3', currentStreak.value);
    _checkAndUnlock('streak_7', currentStreak.value);
    _checkAndUnlock('streak_30', currentStreak.value);
  }

  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (lastCompletionDate.value == null) {
      currentStreak.value = 1;
    } else {
      final lastDate = DateTime(
        lastCompletionDate.value!.year,
        lastCompletionDate.value!.month,
        lastCompletionDate.value!.day,
      );
      
      final difference = today.difference(lastDate).inDays;
      
      if (difference == 0) {
        // Same day, streak unchanged
      } else if (difference == 1) {
        // Consecutive day
        currentStreak.value++;
      } else {
        // Streak broken
        currentStreak.value = 1;
      }
    }
    
    lastCompletionDate.value = now;
    _saveAchievements();
  }

  void onPomodoroCompleted() {
    totalPomodoroSessions.value++;
    _checkAndUnlock('pomodoro_5', totalPomodoroSessions.value);
    _checkAndUnlock('pomodoro_25', totalPomodoroSessions.value);
  }

  void onCategoryCreated(int categoryCount) {
    _checkAndUnlock('category_creator', categoryCount);
  }

  int get unlockedCount => achievements.where((a) => a.isUnlocked).length;
  int get totalCount => achievements.length;
}
