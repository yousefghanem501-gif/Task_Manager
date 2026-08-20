import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  TextEditingController taskTitle = TextEditingController();
  TextEditingController taskDescription = TextEditingController();
  Box box = Hive.box("my_task");
  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text("Add Task"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formkey,
          child: Column(
            children: [
              SizedBox(height: 20),
              TextFormField(
                controller: taskTitle,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter a title";
                  }
                  return null;
                },
                decoration: InputDecoration(hintText: "Enter task title",
                  labelText: "Task Title",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: taskDescription,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter a description";
                  }
                  return null;
                },
                decoration: InputDecoration(hintText: "Enter task description",
                  labelText: "Task Description",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: () {
                if(formkey.currentState!.validate()) {
                  var data = {
                    "title": taskTitle.text,
                    "description": taskDescription.text,
                  };
                  box.add(data);
                  taskTitle.clear();
                  taskDescription.clear();
                  Navigator.pop(context);
                }
              },
                child: Text("Add Task"), style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                fixedSize: Size(MediaQuery.of(context).size.width , 50)
              ),)
            ],
          ),
        ),
      ),
    );
  }
}
