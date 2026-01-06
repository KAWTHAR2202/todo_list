import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/task_controller.dart';
import '../controller/theme_controller.dart';
import '../controller/achievement_controller.dart';
import '../model/task.dart';
import '../service/quotes_service.dart';
import 'categories_page.dart';
import 'pomodoro_page.dart';
import 'calculator_page.dart';
import 'achievements_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final TaskController controller = Get.put(TaskController());
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final RxBool _isSearching = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _sortBy = 'date'.obs; // 'date', 'priority', 'name'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      final filters = ['all', 'pending', 'completed'];
      controller.setFilter(filters[_tabController.index]);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Task> get sortedAndFilteredTasks {
    var tasks = controller.filteredTasks.where((task) {
      if (_searchQuery.value.isEmpty) return true;
      return task.title.toLowerCase().contains(_searchQuery.value.toLowerCase());
    }).toList();

    switch (_sortBy.value) {
      case 'priority':
        tasks.sort((a, b) => b.priority.compareTo(a.priority));
        break;
      case 'name':
        tasks.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'date':
      default:
        tasks.sort((a, b) => a.date.compareTo(b.date));
    }
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Obx(() {
          if (_isSearching.value) {
            return TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                border: InputBorder.none,
              ),
              onChanged: (value) => _searchQuery.value = value,
            );
          }
          final category = controller.selectedCategoryId.value != null
              ? controller.getCategoryById(controller.selectedCategoryId.value)
              : null;
          return Text(
            category != null ? '📁 ${category.name}' : '✨ My Tasks',
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }),
        actions: [
          // Search button
          Obx(() => IconButton(
            icon: Icon(_isSearching.value ? Icons.close : Icons.search),
            tooltip: 'Search',
            onPressed: () {
              _isSearching.value = !_isSearching.value;
              if (!_isSearching.value) {
                _searchController.clear();
                _searchQuery.value = '';
              }
            },
          )),
          // Sort button
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Trier',
            onSelected: (value) => _sortBy.value = value,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: _sortBy.value == 'date' ? colorScheme.primary : null),
                    const SizedBox(width: 8),
                    const Text('Par date'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'priority',
                child: Row(
                  children: [
                    Icon(Icons.flag, color: _sortBy.value == 'priority' ? colorScheme.primary : null),
                    const SizedBox(width: 8),
                    const Text('Par priorité'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, color: _sortBy.value == 'name' ? colorScheme.primary : null),
                    const SizedBox(width: 8),
                    const Text('Par nom'),
                  ],
                ),
              ),
            ],
          ),
          // Theme toggle
          Obx(() => IconButton(
            icon: Icon(themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: themeController.isDarkMode ? 'Mode clair' : 'Mode sombre',
            onPressed: () => themeController.toggleTheme(),
          )),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Motivational Quote
          _buildQuoteCard(colorScheme),
          
          // Category filter chips
          Obx(() => _buildCategoryChips()),
          
          // Stats Card
          Obx(() => _buildStatsCard(colorScheme)),

          // Liste des tâches
          Expanded(
            child: Obx(() {
              final tasks = sortedAndFilteredTasks;
              if (tasks.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _buildTaskCard(task, colorScheme);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskBottomSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
  
  Widget _buildQuoteCard(ColorScheme colorScheme) {
    final quote = QuotesService.getDailyQuote();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.secondary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.format_quote, color: colorScheme.secondary, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quote['quote']!,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '— ${quote['author']}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final achievementController = Get.find<AchievementController>();
    
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, size: 48),
                      const Spacer(),
                      // Streak badge
                      Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${achievementController.currentStreak.value}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Todo App',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Stay productive!',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('All Tasks'),
              onTap: () {
                controller.setCategory(null);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('Badges & Récompenses'),
              trailing: Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${achievementController.unlockedCount}/${achievementController.totalCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              )),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const AchievementsPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Pomodoro Timer'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const PomodoroPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('Calculator'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const CalculatorPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const SettingsPage());
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('CATEGORIES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                      Get.to(() => const CategoriesPage());
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  final isSelected = controller.selectedCategoryId.value == category.id;
                  return ListTile(
                    leading: Icon(category.iconData, color: category.color),
                    title: Text(category.name),
                    selected: isSelected,
                    selectedTileColor: category.color.withOpacity(0.1),
                    onTap: () {
                      controller.setCategory(category.id);
                      Navigator.pop(context);
                    },
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    if (controller.categories.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // All chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: controller.selectedCategoryId.value == null,
              onSelected: (_) => controller.setCategory(null),
            ),
          ),
          ...controller.categories.map((category) {
            final isSelected = controller.selectedCategoryId.value == category.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Icon(category.iconData, size: 16, color: isSelected ? Colors.white : category.color),
                label: Text(category.name),
                selected: isSelected,
                selectedColor: category.color,
                onSelected: (_) => controller.setCategory(isSelected ? null : category.id),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsCard(ColorScheme colorScheme) {
    final total = controller.tasks.length;
    final completed = controller.tasks.where((t) => t.isCompleted).length;
    final pending = total - completed;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', total, Icons.list_alt, Colors.white),
          _buildStatItem(
            'Pending',
            pending,
            Icons.pending_actions,
            Colors.orange.shade100,
          ),
          _buildStatItem(
            'Done',
            completed,
            Icons.check_circle,
            Colors.green.shade100,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    int count,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No tasks yet!',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a new task',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task, ColorScheme colorScheme) {
    final priorityColors = [Colors.green, Colors.orange, Colors.red];
    final priorityLabels = ['Low', 'Medium', 'High'];

    return Dismissible(
      key: Key(task.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => controller.deleteTask(task.id!),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Card(
          color: task.isCompleted ? Colors.grey.shade100 : null,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showEditTaskBottomSheet(context, task),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: () => controller.toggleComplete(task),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isCompleted
                            ? colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: task.isCompleted
                              ? colorScheme.primary
                              : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: task.isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted ? Colors.grey : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${task.date} • ${task.time}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            // Category badge
                            if (task.categoryId != null) ...[
                              const SizedBox(width: 8),
                              Builder(builder: (context) {
                                final category = controller.getCategoryById(task.categoryId);
                                if (category == null) return const SizedBox.shrink();
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: category.color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(category.iconData, size: 10, color: category.color),
                                      const SizedBox(width: 4),
                                      Text(
                                        category.name,
                                        style: TextStyle(fontSize: 10, color: category.color),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Priority Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColors[task.priority].withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      priorityLabels[task.priority],
                      style: TextStyle(
                        color: priorityColors[task.priority],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    DateTime? selectedDateTime;
    String date = '';
    String time = '';
    int priority = 1;
    int? selectedCategoryId = controller.selectedCategoryId.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '✏️ New Task',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Title Field
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      hintText: 'What do you need to do?',
                      prefixIcon: const Icon(Icons.task_alt),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),

                  // Category Selector
                  if (controller.categories.isNotEmpty) ...[
                    const Text(
                      'Category',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: const Text('None'),
                              selected: selectedCategoryId == null,
                              onSelected: (_) => setModalState(() => selectedCategoryId = null),
                            ),
                          ),
                          ...controller.categories.map((category) {
                            final isSelected = selectedCategoryId == category.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                avatar: Icon(category.iconData, size: 16, color: isSelected ? Colors.white : category.color),
                                label: Text(category.name),
                                selected: isSelected,
                                selectedColor: category.color,
                                onSelected: (_) => setModalState(() => selectedCategoryId = category.id),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Date & Time Picker
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        initialDate: DateTime.now(),
                      );
                      if (pickedDate == null) return;

                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime == null) return;

                      selectedDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      date = DateFormat('yyyy-MM-dd').format(selectedDateTime!);
                      time = DateFormat('HH:mm').format(selectedDateTime!);
                      setModalState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            date.isEmpty ? 'Pick Date & Time' : '$date • $time',
                            style: TextStyle(
                              color: date.isEmpty ? Colors.grey : null,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Priority Selector
                  const Text(
                    'Priority',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPriorityButton('Low', 0, Colors.green, priority, (
                        p,
                      ) {
                        setModalState(() => priority = p);
                      }),
                      const SizedBox(width: 8),
                      _buildPriorityButton(
                        'Medium',
                        1,
                        Colors.orange,
                        priority,
                        (p) {
                          setModalState(() => priority = p);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildPriorityButton('High', 2, Colors.red, priority, (
                        p,
                      ) {
                        setModalState(() => priority = p);
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Add Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (titleController.text.isNotEmpty &&
                            selectedDateTime != null) {
                          await controller.addTask(
                            titleController.text,
                            date,
                            time,
                            selectedDateTime!,
                            priority: priority,
                            categoryId: selectedCategoryId,
                          );
                          Navigator.pop(context);
                          Get.snackbar(
                            '✅ Success',
                            'Task added successfully!',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green.shade100,
                          );
                        } else {
                          Get.snackbar(
                            '⚠️ Error',
                            'Please fill all fields',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.shade100,
                          );
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Task'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditTaskBottomSheet(BuildContext context, Task task) {
    final titleController = TextEditingController(text: task.title);
    int priority = task.priority;
    int? selectedCategoryId = task.categoryId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '✏️ Edit Task',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      prefixIcon: const Icon(Icons.task_alt),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Selector
                  if (controller.categories.isNotEmpty) ...[
                    const Text(
                      'Category',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: const Text('None'),
                              selected: selectedCategoryId == null,
                              onSelected: (_) => setModalState(() => selectedCategoryId = null),
                            ),
                          ),
                          ...controller.categories.map((category) {
                            final isSelected = selectedCategoryId == category.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                avatar: Icon(category.iconData, size: 16, color: isSelected ? Colors.white : category.color),
                                label: Text(category.name),
                                selected: isSelected,
                                selectedColor: category.color,
                                onSelected: (_) => setModalState(() => selectedCategoryId = category.id),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const Text(
                    'Priority',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPriorityButton('Low', 0, Colors.green, priority, (
                        p,
                      ) {
                        setModalState(() => priority = p);
                      }),
                      const SizedBox(width: 8),
                      _buildPriorityButton(
                        'Medium',
                        1,
                        Colors.orange,
                        priority,
                        (p) {
                          setModalState(() => priority = p);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildPriorityButton('High', 2, Colors.red, priority, (
                        p,
                      ) {
                        setModalState(() => priority = p);
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            controller.deleteTask(task.id!);
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            final updated = task.copyWith(
                              title: titleController.text,
                              priority: priority,
                              categoryId: selectedCategoryId,
                            );
                            await controller.updateTask(updated);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriorityButton(
    String label,
    int value,
    Color color,
    int current,
    Function(int) onSelect,
  ) {
    final isSelected = current == value;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
