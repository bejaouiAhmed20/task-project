import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tasks/models/task.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'todo2.db');

    return await openDatabase(
      path,
      version: 6, // Increment the version if you've changed the schema
      onCreate: (db, version) {
        print("Creating tables...");
        db.execute(
          '''CREATE TABLE tasks (id INTEGER PRIMARY KEY, content TEXT NOT NULL, status INTEGER NOT NULL)''',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        // Handle schema changes here if needed
        if (oldVersion < 6) {
          print("Upgrading database from version $oldVersion to $newVersion");
          // You can add migration logic here if you want to upgrade schema
        }
      },
    );
  }

  Future<void> addTask(String content) async {
    final db = await database;
    await db.insert(
      'tasks',
      {'content': content, 'status': 0},
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Handle conflicts gracefully
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final data = await db.query('tasks');
    // return data.map((task) => Task.fromMap(task)).toList();
    List<Task> tasks = data
        .map((e) => Task(
            id: e["id"] as int,
            status: e["status"] as int,
            content: e["content"] as String))
        .toList();
    return tasks;
  }

  void update(int id, int status) async {
    final db = await database;
    await db.update(
        'tasks',
        {
          'status': status,
        },
        where: 'id = ?',
        whereArgs: [
          id,
        ]);
  }

  void deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [
      id,
    ]);
  }

  void deleteAll() async {
    final db = await database;
    await db.delete('tasks');
  }
}
