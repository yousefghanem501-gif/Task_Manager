import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Box box = Hive.box("my_task");
  var doneBox = Hive.box("done_task");
  var check = false;
  var doneTaskCheck = true;
  String name = "";

  username() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    name = prefs.getString('username').toString();
    setState(() {

    });
    return name;
  }
  void initState(){
    super.initState();
    username();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("welcome $name"),

        backgroundColor: Colors.blue,foregroundColor: Colors.white,),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddTask())
          ).then((value) {
            setState(() {});
          }
          );
        },
      ),
      body: (box.isEmpty && doneBox.isEmpty)?Center(
        child: Lottie.asset("assets/empty.json",width: 300,height: 300),
      ):
      Column(
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              height: 500,
              child: ListView.builder(
                itemCount: box.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: check?
                    Text(box.getAt(index)["title"],style: TextStyle(decoration: TextDecoration.lineThrough),):
                    Text(box.getAt(index)["title"]),
                    subtitle: Text(box.getAt(index)["description"]),
                    leading: Checkbox(value: check, onChanged: (value) {
                      setState(() {
                        check = !value!;

                        doneBox.add(box.getAt(index));
                        box.deleteAt(index);
                      });
                    }),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        box.deleteAt(index);
                        setState(() {});
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              height: 500,
              child: ListView.builder(
                itemCount: doneBox.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: doneTaskCheck?
                    Text(doneBox.getAt(index)["title"],style: TextStyle(decoration: TextDecoration.lineThrough),):
                    Text(doneBox.getAt(index)["title"]),
                    subtitle: Text(doneBox.getAt(index)["description"]),
                    leading: Checkbox(value: doneTaskCheck, onChanged: (value) {
                      setState(() {
                        doneTaskCheck = !value!;

                        box.add(doneBox.getAt(index));
                        doneBox.deleteAt(index);
                      });
                    }),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        doneBox.deleteAt(index);
                        setState(() {});
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      )
    );
     
  }
}
