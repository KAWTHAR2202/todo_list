class Task {
  int? id;
  String title;
  String date;
  String time;
  bool isCompleted;
  int priority; // 0: basse, 1: moyenne, 2: haute
  int? categoryId;

  Task({
    this.id,
    required this.title,
    required this.date,
    required this.time,
    this.isCompleted = false,
    this.priority = 1,
    this.categoryId,
  });

  // Convertir Task en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'time': time,
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority,
      'categoryId': categoryId,
    };
  }

  // Créer une Task depuis un Map (SQLite)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      date: map['date'] as String,
      time: map['time'] as String,
      isCompleted: (map['isCompleted'] as int?) == 1,
      priority: map['priority'] as int? ?? 1,
      categoryId: map['categoryId'] as int?,
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? date,
    String? time,
    bool? isCompleted,
    int? priority,
    Object? categoryId = const _Unset(),
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      categoryId: categoryId is _Unset ? this.categoryId : categoryId as int?,
    );
  }
}

// Sentinel class for copyWith nullable values
class _Unset {
  const _Unset();
}
