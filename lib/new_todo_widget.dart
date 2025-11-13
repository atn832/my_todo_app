import 'package:flutter/material.dart';
import 'package:my_todo_app/todo.dart';
import 'package:my_todo_app/todo_provider.dart';
import 'package:provider/provider.dart';

class NewTodoWidget extends StatefulWidget {
  const NewTodoWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return NewTodoWidgetState();
  }
}

class NewTodoWidgetState extends State<NewTodoWidget> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final todoProvider = context.read<TodoProvider>();
    return Row(
      spacing: 16,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(label: Text('Task')),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final todo = Todo()
              ..id = null
              ..title = controller.text
              ..done = false;
            await todoProvider.insert(todo);
            setState(() {
              controller.text = '';
            });
          },
          child: Text('Create a todo'),
        ),
      ],
    );
  }
}
