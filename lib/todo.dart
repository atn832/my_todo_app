final String tableTodo = 'todo';
final String columnId = '_id';
final String columnTitle = 'title';
final String columnDone = 'done';

class Todo {
  late int? id;
  late String title;
  late bool done;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnTitle: title,
      columnDone: done == true ? 1 : 0,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Todo();

  Todo.fromMap(Map<String, Object?> map) {
    id = map[columnId] as int;
    title = map[columnTitle] as String;
    done = map[columnDone] == 1;
  }
}
