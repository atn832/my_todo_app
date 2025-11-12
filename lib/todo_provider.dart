// https://pub.dev/packages/sqflite#sql-helpers
import 'package:my_todo_app/todo.dart';
import 'package:sqflite/sqflite.dart';

class TodoProvider {
  late Database db;

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
  }

  // https://pub.dev/packages/sqflite#read-results
  Future<List<Todo>> list() async {
    final todoMaps = await db.query(tableTodo);
    return todoMaps.map(Todo.fromMap).toList();
  }

  Future<Todo> insert(Todo todo) async {
    todo.id = await db.insert(tableTodo, todo.toMap());
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
    return await db.delete(tableTodo, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Todo todo) async {
    return await db.update(
      tableTodo,
      todo.toMap(),
      where: '$columnId = ?',
      whereArgs: [todo.id],
    );
  }

  Future close() async => db.close();
}
