import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_todo_app/todo.dart';
import 'package:my_todo_app/todo_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/src/factory.dart';

import 'todo_provider_with_fake_test.dart';
@GenerateNiceMocks([MockSpec<SqfliteDatabaseFactory>(), MockSpec<Database>()])
import 'todo_provider_with_mock_test.mocks.dart';

main() {
  late TodoProvider p;
  late MockDatabase mockDatabase;

  setUp(() async {
    // Make databaseFactory.openDatabase return our MockDatabase. It needs to
    // be specifically a SqfliteDatabaseFactory, and not simply a
    // DatabaseFactory because of the check at
    // https://github.com/tekartik/sqflite/blob/d71ad498ec06dcffcc3f779999338a2ca6fe1217/sqflite_common/lib/src/sqflite_database_factory.dart#L14-L20
    final mockDatabaseFactory = MockSqfliteDatabaseFactory();
    databaseFactory = mockDatabaseFactory;

    mockDatabase = MockDatabase();
    when(
      mockDatabaseFactory.openDatabase(any, options: anyNamed('options')),
    ).thenAnswer((_) => Future.value(mockDatabase));

    // Initialize a TodoProvider for each test. We must call p.open so that it
    // initializes p.db.
    p = TodoProvider();
    await p.open('irrelevant.db');
  });

  test('insert', () async {
    // Set up response to calls to database.insert. It will only react if
    // insert is called with the expected parameters, in this case, table must
    // be 'todo', and the map data can be anything.
    // And we set up the return value to be a Future that resolves to 1.
    when(mockDatabase.insert('todo', any)).thenAnswer((_) => Future.value(1));

    // Save a new todo with a null id.
    final savedTodo = await p.insert(makeTodo());

    // Check that database.insert was called with the right parameters
    final verificationResult = verify(mockDatabase.insert('todo', captureAny));
    final todoMap = verificationResult.captured.first;
    expect(todoMap, equals({'title': 'Do something', 'done': 0}));

    // Check that the saved todo was assigned the id.
    expect(savedTodo.id, 1);
    expect(savedTodo.title, 'Do something');
  });

  test('getTodo', () async {
    // Prepare the response.
    when(
      mockDatabase.query(
        tableTodo,
        columns: [columnId, columnDone, columnTitle],
        where: '$columnId = ?',
        whereArgs: [
          1,
          /** expected id */
        ],
      ),
    ).thenAnswer(
      (_) => Future.value([
        {'_id': 1, 'title': 'Do something', 'done': 0},
      ]),
    );

    // Read a todo.
    final readTodo = await p.getTodo(1);

    // Check its content.
    expect(readTodo.id, 1);
    expect(readTodo.title, 'Do something');
    expect(readTodo.done, isFalse);
  });

  test('updateTodo', () async {
    // Prepare the response.
    when(
      mockDatabase.update(
        tableTodo,
        /* map data */ any,
        where: '$columnId = ?',
        whereArgs: [1],
      ),
    ).thenAnswer((_) => Future.value(1));

    // Change values.
    final savedTodo = Todo()
      ..id = 1
      ..title = 'Write tests'
      ..done = true;
    final updatedTodoId = await p.update(savedTodo);

    // Check return value.
    expect(updatedTodoId, 1);

    // Verify the data passed to database.update.
    final verificationResult = verify(
      mockDatabase.update(
        any,
        /* map data */ captureAny,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      ),
    );
    final capturedMapData = verificationResult.captured.first;
    expect(capturedMapData, {'_id': 1, 'title': 'Write tests', 'done': 1});
  });

  // TODO: test delete

  test('list', () async {
    // Since we don't know the ids in advance, simply check Todos' titles.
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

    // Prepare the response to db.query that contains 1 todo's to simulate the
    // database's response to db.insert.
    when(
      mockDatabase.query(tableTodo),
    ).thenAnswer((_) => Future.value([makeTodo(id: 1).toMap()]));
    // In the beginning, titles is [].
    final firstTodo = await p.insert(makeTodo());
    // At this point, titles has emitted ['Do something'];

    // Prepare a response to db.query that contains 2 todo's to simulate the
    // database's response to db.insert.
    when(mockDatabase.query(tableTodo)).thenAnswer(
      (_) => Future.value([makeTodo(id: 1).toMap(), makeTodo(id: 2).toMap()]),
    );
    final secondTodo = await p.insert(makeTodo());
    // At this point, titles has emitted ['Do something', 'Do something'];

    // Modify the second todo.
    secondTodo.title = 'Do something else';
    // Prepare a response to db.query that contains the modified 2nd todo.
    when(mockDatabase.query(tableTodo)).thenAnswer(
      (_) => Future.value([makeTodo(id: 1).toMap(), secondTodo.toMap()]),
    );
    await p.update(secondTodo);
    // At this point, titles has emitted ['Do something', 'Do something else'];

    // Prepare a response to db.query that contains only the modified 2nd todo,
    // as if the first todo had been deleted.
    when(
      mockDatabase.query(tableTodo),
    ).thenAnswer((_) => Future.value([secondTodo.toMap()]));
    // Delete the first todo.
    await p.delete(firstTodo.id!);
    // At this point, titles has emitted ['Do something else'];
  });
}
