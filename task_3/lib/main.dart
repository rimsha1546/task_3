import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List with SharedPreferences',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({Key? key}) : super(key: key);

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _taskController = TextEditingController();
  List<String> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load tasks from SharedPreferences when the app starts
  }

  // Load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks = prefs.getStringList('tasks') ?? [];
    });
  }

  // Add a new task
  Future<void> _addTask() async {
    if (_taskController.text.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _tasks.add(_taskController.text);
      });
      _taskController.clear();
      await prefs.setStringList('tasks', _tasks); // Save updated list
    }
  }

  // Delete a task
  Future<void> _deleteTask(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks.removeAt(index);
    });
    await prefs.setStringList('tasks', _tasks); // Save updated list
  }

  // Mark a task as complete (simple toggle between crossed out or not)
  void _toggleComplete(int index) {
    setState(() {
      _tasks[index] = _tasks[index].startsWith('✓ ')
          ? _tasks[index].substring(2)
          : '✓ ' + _tasks[index];
    });
    _saveTasks();
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasks', _tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List with SharedPreferences'),
      ),
      body: Column(
        children: [
          // TextField to add new tasks
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Enter Task',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addTask,
            child: const Text('Add Task'),
          ),
          const SizedBox(height: 10),
          // ListView to display tasks
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _tasks[index],
                    style: TextStyle(
                      decoration: _tasks[index].startsWith('✓ ')
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.check_circle),
                    onPressed: () => _toggleComplete(index),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteTask(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
