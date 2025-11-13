import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_todo_app/todo.dart';
import 'package:my_todo_app/todo_list_widget.dart';
import 'package:my_todo_app/todo_provider.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'todo_provider_test.dart';

@GenerateNiceMocks([MockSpec<TodoProvider>()])
import 'todo_list_widget_with_mock_test.mocks.dart';

main() {
  late MockTodoProvider p;
  late BehaviorSubject<List<Todo>> todos;

  setUp(() async {
    // Set up a mock TodoProvider, whose list() we can control with `todos`.
    p = MockTodoProvider();
    // Start with an empty list of Todos.
    todos = BehaviorSubject.seeded([]);
    when(p.list()).thenAnswer((_) => todos.stream);
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
      matchesGoldenFile('goldens/todo_list_widget_with_mock/empty.png'),
    );
    expect(find.text('Do something'), findsNothing);

    // Add a todo.
    todos.add([makeTodo(id: 1)]);
    await tester.pump();

    await expectLater(
      find.byType(TodoListWidget),
      matchesGoldenFile('goldens/todo_list_widget_with_mock/oneTodo.png'),
    );
    expect(find.text('Do something'), findsOneWidget);
  });

  testWidgets('delete todo', (WidgetTester tester) async {
    todos.add([makeTodo(id: 1)]);

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
      matchesGoldenFile('goldens/todo_list_widget_with_mock/deleteBefore.png'),
    );

    // Tap 'delete'.
    await tester.tap(find.byIcon(Icons.delete));
    // Verify that delete() has been called.
    verify(p.delete(1));
    // Simulate the deletion.
    todos.add([]);
    await tester.pump();

    expect(find.text('Do something'), findsNothing);
    await expectLater(
      find.byType(TodoListWidget),
      matchesGoldenFile('goldens/todo_list_widget_with_mock/deleteAfter.png'),
    );
  });

  testWidgets('update todo', (WidgetTester tester) async {
    todos.add([makeTodo(id: 1)]);

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
      matchesGoldenFile('goldens/todo_list_widget_with_mock/update1.png'),
    );

    // Check the box.
    await tester.tap(find.byType(Checkbox));
    // Verify that update() has been called.
    final verificationResult = verify(p.update(captureAny));
    // Check that the passed Todo has been marked as done.
    final capturedTodo = verificationResult.captured.first;
    expect(capturedTodo.done, isTrue);
    // Simulate the update.
    final updatedTodo = makeTodo(id: 1);
    updatedTodo.done = true;
    todos.add([updatedTodo]);
    // Wait for rendering to complete.
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TodoListWidget),
      matchesGoldenFile(
        'goldens/todo_list_widget_with_mock/update2_checkBox.png',
      ),
    );
  });
}
