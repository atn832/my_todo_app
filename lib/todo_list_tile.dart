import 'package:flutter/material.dart';
import 'package:my_todo_app/todo.dart';
import 'package:my_todo_app/todo_provider.dart';

class TodoListTile extends StatefulWidget {
  final Todo todo;
  final TodoProvider todoProvider;

  const TodoListTile({
    super.key,
    required this.todo,
    required this.todoProvider,
  });

  @override
  State<StatefulWidget> createState() {
    return TodoListTileState();
  }
}

class TodoListTileState extends State<TodoListTile> {
  @override
  Widget build(BuildContext context) {
    final todo = widget.todo;
    final todoProvider = widget.todoProvider;
    return ListTile(
      title: Text(todo.title),
      leading: Checkbox(
        value: todo.done,
        onChanged: (value) {
          setState(() {
            todo.done = value!;
          });
          todoProvider.update(todo);
        },
      ),
      trailing: IconButton(
        onPressed: () {
          todoProvider.delete(todo.id!);
        },
        icon: Icon(Icons.delete),
      ),
    );
  }
}
