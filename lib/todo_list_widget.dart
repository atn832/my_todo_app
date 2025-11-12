import 'package:flutter/material.dart';
import 'package:my_todo_app/todo.dart';
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
            return ListTile(
              title: Text(todo.title),
              leading: Icon(
                // TODO: set icon depending on todo.done.
                Icons.check_box_outline_blank,
              ),
              trailing: IconButton(
                onPressed: () {
                  todoProvider.delete(todo.id!);
                },
                icon: Icon(Icons.delete),
              ),
            );
          },
        );
      },
    );
  }
}
