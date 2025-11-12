import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_todo_app/new_todo_widget.dart';
import 'package:my_todo_app/todo_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

main() {
  // Init ffi loader to use the in-memory database.
  sqfliteFfiInit();
  // When using testWidgets, we have to use `databaseFactoryFfiNoIsolate`
  // instead of `databaseFactoryFfi`.
  // https://github.com/tekartik/sqflite/issues/841#issuecomment-1200859788
  databaseFactory = databaseFactoryFfiNoIsolate;

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

  testWidgets('NewTodoWidget', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: NewTodoWidget(p))),
    );
    await tester.pump();

    await expectLater(
      find.byType(NewTodoWidget),
      matchesGoldenFile('goldens/new_todo_widget/initialRender.png'),
    );
    expect(find.text('Create a todo'), findsOneWidget);

    // Create a todo.
    await tester.tap(find.text('Create a todo'));
    await tester.pump();

    // Expect the todo to have been created.
    expect(p.list().map((todos) => todos.length), emits(1));
  });
}
