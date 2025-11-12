import 'package:flutter/material.dart';
import 'package:my_todo_app/todo.dart';
import 'package:my_todo_app/todo_list_widget.dart';
import 'package:my_todo_app/todo_provider.dart';

void main() async {
  // This line is necessary to properly initialize the sqflite database.
  WidgetsFlutterBinding.ensureInitialized();

  final todoProvider = TodoProvider();
  await todoProvider.open('todos.db');

  runApp(MainApp(todoProvider));
}

class MainApp extends StatelessWidget {
  const MainApp(this.todoProvider, {super.key});

  final TodoProvider todoProvider;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final todo = Todo()
                  ..id = null
                  ..title = 'Write tests'
                  ..done = false;
                await todoProvider.insert(todo);
              },
              child: Text('Create a todo'),
            ),
            Expanded(child: TodoListWidget(todoProvider)),
          ],
        ),
      ),
    );
  }
}
