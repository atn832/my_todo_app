import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_todo_app/todo_list_widget.dart';
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

  testWidgets('displays messages', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: TodoListWidget(p))),
    );
    await tester.pump();
    expect(find.text('Do something'), findsNothing);

    await expectLater(
      find.byType(TodoListWidget),
      matchesGoldenFile('goldens/todo_list_widget/empty.png'),
    );
  });
}
