// https://pub.dev/packages/sqflite#sql-helpers
import 'package:my_todo_app/todo.dart';
import 'package:rxdart/subjects.dart';
import 'package:sqflite/sqflite.dart';

class TodoProvider {
  late Database db;
  final todos = BehaviorSubject<List<Todo>>();

  Future open(String path) async {
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
create table $tableTodo ( 
  $columnId integer primary key autoincrement, 
  $columnTitle text not null,
  $columnDone integer not null)
''');
      },
    );
    // Populate todos.
    await updateList();
  }

  // https://pub.dev/packages/sqflite#read-results
  Future updateList() async {
    final todoMaps = await db.query(tableTodo);
    final latestTodos = todoMaps.map(Todo.fromMap).toList();
    todos.add(latestTodos);
  }

  Stream<List<Todo>> list() {
    return todos.stream;
  }

  Future<Todo> insert(Todo todo) async {
    todo.id = await db.insert(tableTodo, todo.toMap());
    await updateList();
    return todo;
  }

  Future<Todo> getTodo(int id) async {
    final maps = await db.query(
      tableTodo,
      columns: [columnId, columnDone, columnTitle],
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Todo.fromMap(maps.first);
    }
    throw StateError('Todo with id $id found');
  }

  Future<int> delete(int id) async {
    final deletedId = await db.delete(
      tableTodo,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    await updateList();
    return deletedId;
  }

  Future<int> update(Todo todo) async {
    final id = await db.update(
      tableTodo,
      todo.toMap(),
      where: '$columnId = ?',
      whereArgs: [todo.id],
    );
    await updateList();
    return id;
  }

  Future close() async => db.close();
}
