import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'To Do List App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, String>> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/tasks.txt');
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> decodedData = jsonDecode(jsonString);

        // Convert decoded data to List<Map<String, String>>
        final List<Map<String, String>> convertedData =
            decodedData.map((dynamic task) {
          return Map<String, String>.from(task);
        }).toList();

        setState(() {
          tasks = convertedData;
        });
      }
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }

  Future<void> saveTasks() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/tasks.txt');
      final jsonData = jsonEncode(tasks);
      await file.writeAsString(jsonData);
    } catch (e) {
      print('Error saving tasks: $e');
    }
  }

  void addTask(String title, String description) {
    setState(() {
      tasks.add({
        'Title': title,
        'Description': description,
      });
    });
    saveTasks();
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(tasks[index]['Title']!),
            onDismissed: (direction) {
              deleteTask(index);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              title: Text(tasks[index]['Title']!),
              subtitle: Text(tasks[index]['Description']!),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  deleteTask(index);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return AddTaskWidget(onAddTask: addTask);
            },
          );
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddTaskWidget extends StatefulWidget {
  final Function(String, String) onAddTask;

  const AddTaskWidget({Key? key, required this.onAddTask}) : super(key: key);

  @override
  _AddTaskWidgetState createState() => _AddTaskWidgetState();
}

class _AddTaskWidgetState extends State<AddTaskWidget> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Add Task',
            style: Theme.of(context).textTheme.headline6,
          ),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'Title',
            ),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();
              if (title.isNotEmpty && description.isNotEmpty) {
                widget.onAddTask(title, description);
                Navigator.pop(context);
              }
            },
            child: Text('Submit'),
          ),
          SizedBox(
            height: 10.0,
          )
        ],
      ),
    );
  }
}
