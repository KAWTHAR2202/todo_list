import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/task.dart';
import '../model/category.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            colorValue INTEGER,
            icon TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            date TEXT,
            time TEXT,
            isCompleted INTEGER DEFAULT 0,
            priority INTEGER DEFAULT 1,
            categoryId INTEGER,
            FOREIGN KEY (categoryId) REFERENCES categories(id) ON DELETE SET NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE tasks ADD COLUMN isCompleted INTEGER DEFAULT 0');
          await db.execute('ALTER TABLE tasks ADD COLUMN priority INTEGER DEFAULT 1');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS categories(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              colorValue INTEGER,
              icon TEXT
            )
          ''');
          await db.execute('ALTER TABLE tasks ADD COLUMN categoryId INTEGER');
        }
      },
    );
  }

  // ============ CATEGORIES ============
  Future<List<Category>> getCategories() async {
    final dbClient = await db;
    final maps = await dbClient.query('categories', orderBy: 'name ASC');
    return maps.map((e) => Category.fromMap(e)).toList();
  }

  Future<int> insertCategory(Category category) async {
    final dbClient = await db;
    return await dbClient.insert('categories', category.toMap());
  }

  Future<int> updateCategory(Category category) async {
    final dbClient = await db;
    return await dbClient.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final dbClient = await db;
    // Les tâches associées auront categoryId = NULL
    return await dbClient.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ============ TASKS ============
  Future<List<Task>> getTasks({int? categoryId}) async {
    final dbClient = await db;
    if (categoryId != null) {
      final maps = await dbClient.query(
        'tasks',
        where: 'categoryId = ?',
        whereArgs: [categoryId],
        orderBy: 'isCompleted ASC, priority DESC, id DESC',
      );
      return maps.map((e) => Task.fromMap(e)).toList();
    }
    final maps = await dbClient.query('tasks', orderBy: 'isCompleted ASC, priority DESC, id DESC');
    return maps.map((e) => Task.fromMap(e)).toList();
  }

  Future<int> insertTask(Task task) async {
    final dbClient = await db;
    return await dbClient.insert('tasks', task.toMap());
  }

  Future<int> updateTask(Task task) async {
    final dbClient = await db;
    return await dbClient.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final dbClient = await db;
    return await dbClient.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getTaskCountByCategory(int categoryId) async {
    final dbClient = await db;
    final result = await dbClient.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE categoryId = ?',
      [categoryId],
    );
    return result.first['count'] as int;
  }
}
