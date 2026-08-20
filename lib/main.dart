import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_4/screens/home_screen.dart';
import 'package:project_4/screens/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {

  await Hive.initFlutter();

  await Hive.openBox('my_task');
  await Hive.openBox('done_task');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Welcome());
  }
}
