import 'package:flutter/material.dart';
import 'package:my_todo_app/todo.dart';
import 'package:my_todo_app/todo_list_tile.dart';
import 'package:my_todo_app/todo_provider.dart';

class TodoListWidget extends StatelessWidget {
  const TodoListWidget(this.todoProvider, {super.key});

  final TodoProvider todoProvider;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Todo>>(
      stream: todoProvider.list(),
      builder: (context, snapshot) {
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
            return TodoListTile(todo: todo, todoProvider: todoProvider);
          },
        );
      },
    );
  }
}
