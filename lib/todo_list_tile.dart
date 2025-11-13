import 'package:flutter/material.dart';
import 'package:my_todo_app/todo.dart';
import 'package:my_todo_app/todo_provider.dart';
import 'package:provider/provider.dart';

class TodoListTile extends StatefulWidget {
  final Todo todo;

  const TodoListTile({super.key, required this.todo});

  @override
  State<StatefulWidget> createState() {
    return TodoListTileState();
  }
}

class TodoListTileState extends State<TodoListTile> {
  @override
  Widget build(BuildContext context) {
    final todoProvider = context.read<TodoProvider>();
    final todo = widget.todo;
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
