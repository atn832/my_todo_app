import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_todo_app/todo_list_widget.dart';
import 'package:my_todo_app/todo_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'todo_provider_test.dart';

main() {
  // Init ffi loader to use the in-memory database.
  sqfliteFfiInit();
  // When using testWidgts, we have to use `databaseFactoryFfiNoIsolate`
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

  testWidgets('displays messages', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: TodoListWidget(p))),
    );
    await tester.pump();

    await expectLater(
      find.byType(TodoListWidget),
      matchesGoldenFile('goldens/todo_list_widget/empty.png'),
    );
    expect(find.text('Do something'), findsNothing);

    // Add a todo.
    await p.insert(makeTodo());
    await tester.pump();

    await expectLater(
      find.byType(TodoListWidget),
      matchesGoldenFile('goldens/todo_list_widget/oneTodo.png'),
    );
    expect(find.text('Do something'), findsOneWidget);
  });
}
