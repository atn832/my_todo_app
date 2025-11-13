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
    return ListTile(
      title: Text(widget.todo.title),
      leading: Icon(
        // TODO: set icon depending on todo.done.
        Icons.check_box_outline_blank,
      ),
      trailing: IconButton(
        onPressed: () {
          widget.todoProvider.delete(widget.todo.id!);
        },
        icon: Icon(Icons.delete),
      ),
    );
  }
}
