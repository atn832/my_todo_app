import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_todo_app/todo_list_widget.dart';
import 'package:my_todo_app/todo_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'todo_provider_test.dart';

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

  testWidgets('displays todos', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Provider<TodoProvider>(
            create: (_) => p,
            child: TodoListWidget(),
          ),
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byType(TodoListWidget),
      matchesGoldenFile('goldens/todo_list_widget_with_fake/empty.png'),
    );
    expect(find.text('Do something'), findsNothing);

    // Add a todo.
    await p.insert(makeTodo());
    await tester.pump();

    await expectLater(
      find.byType(TodoListWidget),
      matchesGoldenFile('goldens/todo_list_widget_with_fake/oneTodo.png'),
    );
    expect(find.text('Do something'), findsOneWidget);
  });

  testWidgets('delete todo', (WidgetTester tester) async {
    await p.insert(makeTodo());

    // Render the list with one todo.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Provider<TodoProvider>(
            create: (_) => p,
            child: TodoListWidget(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Do something'), findsOneWidget);
    await expectLater(
      find.byType(TodoListWidget),
      matchesGoldenFile('goldens/todo_list_widget_with_fake/deleteBefore.png'),
    );

    // Tap 'delete'.
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    expect(find.text('Do something'), findsNothing);
    await expectLater(
      find.byType(TodoListWidget),
      matchesGoldenFile('goldens/todo_list_widget_with_fake/deleteAfter.png'),
    );
  });

  testWidgets('update todo', (WidgetTester tester) async {
    await p.insert(makeTodo());

    // Render the list with one todo.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Provider<TodoProvider>(
            create: (_) => p,
            child: TodoListWidget(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Do something'), findsOneWidget);
    await expectLater(
      find.byType(TodoListWidget),
      matchesGoldenFile('goldens/todo_list_widget_with_fake/update1.png'),
    );

    // Check the box.
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TodoListWidget),
      matchesGoldenFile(
        'goldens/todo_list_widget_with_fake/update2_checkBox.png',
      ),
    );

    // Check the database.
    expect(
      p.list().map((todos) => todos.map((todo) => todo.done)),
      emits([true]),
    );
  });
}
