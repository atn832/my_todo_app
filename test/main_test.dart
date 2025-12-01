import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_todo_app/main.dart';
import 'package:my_todo_app/todo_list_widget.dart';
import 'package:my_todo_app/todo_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

  const phoneSize = Size(1000, 2000);
  const tabletSize = Size(2000, 2400);
  for (final (device, size, mode) in [
    ('phone', phoneSize, ThemeMode.dark),
    ('phone', phoneSize, ThemeMode.light),
    ('tablet', tabletSize, ThemeMode.dark),
    ('tablet', tabletSize, ThemeMode.light),
  ]) {
    testWidgets('MainApp-$device-${mode.name}', (WidgetTester tester) async {
      tester.view.physicalSize = size;

      // Render the app.
      await tester.pumpWidget(MainApp(p, themeMode: mode));
      await tester.pump();

      await expectLater(
        find.byType(TodoListWidget),
        matchesGoldenFile('goldens/main_app/$device/${mode.name}/empty.png'),
      );
      expect(find.text('Write tests'), findsNothing);

      // Create a todo.
      await tester.enterText(find.byType(TextField), 'Write tests');
      await tester.tap(find.text('Create a todo'));
      // Wait for the label to finish moving.
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TodoListWidget),
        matchesGoldenFile('goldens/main_app/$device/${mode.name}/oneTodo.png'),
      );
      expect(find.text('Write tests'), findsOneWidget);

      // Create a todo.
      await tester.enterText(
        find.byType(TextField),
        'Grocery shopping: eggs, milk, bread, baked beans, tomatoes',
      );
      await tester.tap(find.text('Create a todo'));
      // Wait for the label to finish moving.
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TodoListWidget),
        matchesGoldenFile('goldens/main_app/$device/${mode.name}/twoTodos.png'),
      );
    });
  }
}
