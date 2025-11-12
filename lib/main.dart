import 'package:flutter/material.dart';
import 'package:my_todo_app/todo.dart';
import 'package:my_todo_app/todo_list_widget.dart';
import 'package:my_todo_app/todo_provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return MainAppState();
  }
}

class MainAppState extends State<MainApp> {
  late final TodoProvider _todoProvider;
  late final Future<dynamic> _open;

  @override
  void initState() {
    _todoProvider = TodoProvider();
    _open = _todoProvider.open('todos.db');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
          future: _open,
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState != ConnectionState.done) {
              return CircularProgressIndicator();
            }
            return Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final todo = Todo()
                      ..id = null
                      ..title = 'Write tests'
                      ..done = false;
                    final savedTodo = await _todoProvider.insert(todo);
                    print(savedTodo.id);
                    final readTodo = await _todoProvider.getTodo(savedTodo.id!);
                    print(readTodo.title);
                  },
                  child: Text('Create a todo'),
                ),
                Expanded(child: TodoListWidget(_todoProvider)),
              ],
            );
          },
        ),
      ),
    );
  }
}
