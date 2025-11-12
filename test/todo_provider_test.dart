import 'package:flutter_test/flutter_test.dart';
import 'package:my_todo_app/todo.dart';
import 'package:my_todo_app/todo_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

main() {
  // Init ffi loader to use the in-memory database.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('insert', () async {
    final p = TodoProvider();
    await p.open(inMemoryDatabasePath);
    final todo = Todo()
      ..id = null
      ..title = 'Do something'
      ..done = false;

    // Save a new todo with a null id.
    final savedTodo = await p.insert(todo);

    // Check that the saved todo was assigned an id.
    expect(savedTodo.id, isNotNull);
    expect(savedTodo.title, 'Do something');
  });
}
