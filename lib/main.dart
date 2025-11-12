import 'package:flutter/material.dart';
import 'package:my_todo_app/todo.dart';
import 'package:my_todo_app/todo_provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final todo = Todo()
                ..id = null
                ..title = 'Write tests'
                ..done = false;
              final todoProvider = TodoProvider();
              await todoProvider.open('todos.db');
              final savedTodo = await todoProvider.insert(todo);
              print(savedTodo.id);
              final readTodo = await todoProvider.getTodo(savedTodo.id!);
              print(readTodo.title);
            },
            child: Text('Create a todo'),
          ),
        ),
      ),
    );
  }
}
