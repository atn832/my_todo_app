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

    // Save a new todo with a null id.
    final savedTodo = await p.insert(makeTodo());

    // Check that the saved todo was assigned an id.
    expect(savedTodo.id, isNotNull);
    expect(savedTodo.title, 'Do something');
  });

  test('getTodo', () async {
    // Prepare the database.
    final p = TodoProvider();
    await p.open(inMemoryDatabasePath);
    final savedTodo = await p.insert(makeTodo());
    final id = savedTodo.id!;

    // Read a todo.
    final readTodo = await p.getTodo(id);

    // Check its content.
    expect(readTodo.id, id);
    expect(readTodo.title, 'Do something');
    expect(readTodo.done, isFalse);
  });
}

Todo makeTodo() {
  return Todo()
    ..id = null
    ..title = 'Do something'
    ..done = false;
}
