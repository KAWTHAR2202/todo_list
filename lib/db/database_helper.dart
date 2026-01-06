import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/task.dart';

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
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            date TEXT,
            time TEXT,
            isCompleted INTEGER DEFAULT 0,
            priority INTEGER DEFAULT 1
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE tasks ADD COLUMN isCompleted INTEGER DEFAULT 0');
          await db.execute('ALTER TABLE tasks ADD COLUMN priority INTEGER DEFAULT 1');
        }
      },
    );
  }

  Future<List<Task>> getTasks() async {
    final dbClient = await db;
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
}
