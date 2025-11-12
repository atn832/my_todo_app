import 'package:flutter/material.dart';
import 'package:my_todo_app/todo.dart';
import 'package:my_todo_app/todo_provider.dart';

class NewTodoWidget extends StatefulWidget {
  const NewTodoWidget(this.todoProvider, {super.key});

  final TodoProvider todoProvider;

  @override
  State<StatefulWidget> createState() {
    return NewTodoWidgetState();
  }
}

class NewTodoWidgetState extends State<NewTodoWidget> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: TextField(controller: controller)),
        ElevatedButton(
          onPressed: () async {
            final todo = Todo()
              ..id = null
              ..title = controller.text
              ..done = false;
            await widget.todoProvider.insert(todo);

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
