import 'package:flutter_test/flutter_test.dart';
import 'package:my_todo_app/todo.dart';
import 'package:my_todo_app/todo_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

main() {
  // Init ffi loader to use the in-memory database.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late TodoProvider p;

  setUp(() async {
    // Open an in-memory database.
    p = TodoProvider();
    await p.open(inMemoryDatabasePath);
  });

  tearDown(() async {
    // Close the database so that the next test can start from an empty one.
    await p.close();
  });

  test('insert', () async {
    // Save a new todo with a null id.
    final savedTodo = await p.insert(makeTodo());

    // Check that the saved todo was assigned an id.
    expect(savedTodo.id, isNotNull);
    expect(savedTodo.title, 'Do something');
  });

  test('getTodo', () async {
    // Prepare the database.
    final savedTodo = await p.insert(makeTodo());
    final id = savedTodo.id!;

    // Read a todo.
    final readTodo = await p.getTodo(id);

    // Check its content.
    expect(readTodo.id, id);
    expect(readTodo.title, 'Do something');
    expect(readTodo.done, isFalse);
  });

  test('updateTodo', () async {
    // Prepare the database.
    final savedTodo = await p.insert(makeTodo());

    // Change values.
    savedTodo.title = 'Write tests';
    savedTodo.done = true;
    final updatedTodoId = await p.update(savedTodo);

    // Read back.
    final updatedTodo = await p.getTodo(updatedTodoId);

    // Check its content.
    expect(updatedTodo.id, updatedTodoId);
    expect(updatedTodo.title, 'Write tests');
    expect(updatedTodo.done, isTrue);
  });

  // TODO: test delete

  test('list', () async {
    // Since we don't know the ids in advance,  simply check Todos' titles.
    final titlesStream = p.list().map(
      (todos) => todos.map((todo) => todo.title).toList(),
    );
    expect(
      titlesStream,
      emitsInOrder([
        [],
        ['Do something'],
        ['Do something', 'Do something'],
        ['Do something', 'Do something else'],
        ['Do something else'],
      ]),
    );

    // In the beginning, titles is [].
    final firstTodo = await p.insert(makeTodo());
    // At this point, titles has emitted ['Do something'];
    final secondTodo = await p.insert(makeTodo());
    // At this point, titles has emitted ['Do something', 'Do something'];

    // Modify the second todo.
    secondTodo.title = 'Do something else';
    await p.update(secondTodo);
    // At this point, titles has emitted ['Do something', 'Do something else'];

    // Delete the first todo.
    await p.delete(firstTodo.id!);
    // At this point, titles has emitted ['Do something else'];
  });
}

Todo makeTodo() {
  return Todo()
    ..id = null
    ..title = 'Do something'
    ..done = false;
}
