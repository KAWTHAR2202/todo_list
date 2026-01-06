import 'package:get/get.dart';
import '../db/database_helper.dart';
import '../model/task.dart';
import '../model/category.dart';
import '../service/notification_service.dart';
import 'achievement_controller.dart';

class TaskController extends GetxController {
  var tasks = <Task>[].obs;
  var categories = <Category>[].obs;
  var filter = 'all'.obs; // 'all', 'completed', 'pending'
  var selectedCategoryId = Rxn<int>(); // null = toutes les catégories
  final DatabaseHelper db = DatabaseHelper();

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadTasks();
  }

  List<Task> get filteredTasks {
    var filtered = tasks.toList();
    
    // Filtrer par catégorie
    if (selectedCategoryId.value != null) {
      filtered = filtered.where((t) => t.categoryId == selectedCategoryId.value).toList();
    }
    
    // Filtrer par statut
    switch (filter.value) {
      case 'completed':
        return filtered.where((t) => t.isCompleted).toList();
      case 'pending':
        return filtered.where((t) => !t.isCompleted).toList();
      default:
        return filtered;
    }
  }

  void setFilter(String newFilter) {
    filter.value = newFilter;
  }

  void setCategory(int? categoryId) {
    selectedCategoryId.value = categoryId;
  }

  // ============ CATEGORIES ============
  Future<void> loadCategories() async {
    final loadedCategories = await db.getCategories();
    categories.assignAll(loadedCategories);
  }

  Future<void> addCategory(Category category) async {
    await db.insertCategory(category);
    await loadCategories();
    
    // Track achievement
    if (Get.isRegistered<AchievementController>()) {
      AchievementController.to.onCategoryCreated(categories.length);
    }
  }

  Future<void> updateCategory(Category category) async {
    await db.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await db.deleteCategory(id);
    await loadCategories();
    await loadTasks(); // Refresh tasks as some may have lost their category
  }

  Category? getCategoryById(int? id) {
    if (id == null) return null;
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<int> getTaskCountByCategory(int categoryId) async {
    return await db.getTaskCountByCategory(categoryId);
  }

  // ============ TASKS ============
  Future<void> loadTasks() async {
    final loadedTasks = await db.getTasks();
    tasks.assignAll(loadedTasks);
  }

  Future<void> addTask(String title, String date, String time, DateTime dateTime, {int priority = 1, int? categoryId}) async {
    final task = Task(title: title, date: date, time: time, priority: priority, categoryId: categoryId);
    await db.insertTask(task);
    await NotificationService.scheduleNotification(title, dateTime);
    await loadTasks();
    
    // Track achievement
    if (Get.isRegistered<AchievementController>()) {
      AchievementController.to.onTaskCreated();
    }
  }

  Future<void> updateTask(Task task) async {
    await db.updateTask(task);
    await loadTasks();
  }

  Future<void> toggleComplete(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await db.updateTask(updated);
    await loadTasks();
    
    // Track achievement if task was completed
    if (updated.isCompleted && Get.isRegistered<AchievementController>()) {
      AchievementController.to.onTaskCompleted();
    }
  }

  Future<void> deleteTask(int id) async {
    await db.deleteTask(id);
    await loadTasks();
  }
}
