import 'package:flutter/material.dart';
import 'package:my_todo_app/todo.dart';
import 'package:my_todo_app/todo_provider.dart';

class NewTodoWidget extends StatelessWidget {
  const NewTodoWidget(this.todoProvider, {super.key});

  final TodoProvider todoProvider;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final todo = Todo()
          ..id = null
          ..title = 'Write tests'
          ..done = false;
        await todoProvider.insert(todo);
      },
      child: Text('Create a todo'),
    );
  }
}
