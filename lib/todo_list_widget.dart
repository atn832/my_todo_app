import 'package:flutter/material.dart';
import 'package:my_todo_app/todo.dart';
import 'package:my_todo_app/todo_provider.dart';

class TodoListWidget extends StatefulWidget {
  const TodoListWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return TodoListWidgetState();
  }
}

class TodoListWidgetState extends State<TodoListWidget> {
  late final TodoProvider _provider;

  @override
  void initState() {
    _provider = TodoProvider();
    _provider.open('todos.db');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Todo>>(
      stream: _provider.list(),
      builder: (context, snapshot) {
        print(snapshot.data);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        final todos = snapshot.data;
        if (todos == null) {
          return Text('todos is null');
        }
        return ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            return ListTile(
              title: Text(todo.title),
              leading: Icon(
                // TODO: set icon depending on todo.done.
                Icons.check_box_outline_blank,
              ),
            );
          },
        );
      },
    );
  }
}
