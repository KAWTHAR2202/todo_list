import 'package:get/get.dart';
import '../db/database_helper.dart';
import '../model/task.dart';
import '../service/notification_service.dart';

class TaskController extends GetxController {
  var tasks = <Task>[].obs;
  var filter = 'all'.obs; // 'all', 'completed', 'pending'
  final DatabaseHelper db = DatabaseHelper();

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  List<Task> get filteredTasks {
    switch (filter.value) {
      case 'completed':
        return tasks.where((t) => t.isCompleted).toList();
      case 'pending':
        return tasks.where((t) => !t.isCompleted).toList();
      default:
        return tasks.toList();
    }
  }

  void setFilter(String newFilter) {
    filter.value = newFilter;
  }

  Future<void> loadTasks() async {
    final loadedTasks = await db.getTasks();
    tasks.assignAll(loadedTasks);
  }

  Future<void> addTask(String title, String date, String time, DateTime dateTime, {int priority = 1}) async {
    final task = Task(title: title, date: date, time: time, priority: priority);
    await db.insertTask(task);
    await NotificationService.scheduleNotification(title, dateTime);
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await db.updateTask(task);
    await loadTasks();
  }

  Future<void> toggleComplete(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await db.updateTask(updated);
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await db.deleteTask(id);
    await loadTasks();
  }
}
