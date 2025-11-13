import 'package:flutter/material.dart';
import 'package:my_todo_app/new_todo_widget.dart';
import 'package:my_todo_app/todo_list_widget.dart';
import 'package:my_todo_app/todo_provider.dart';
import 'package:provider/provider.dart';

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
        appBar: AppBar(title: Text('Todo App')),
        body: Provider(
          create: (_) => todoProvider,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: NewTodoWidget(),
              ),
              Expanded(child: TodoListWidget()),
            ],
          ),
        ),
      ),
    );
  }
}
