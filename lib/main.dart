import 'package:flutter/material.dart';
import 'package:pytorch_poc/home.dart';
import 'package:talker_flutter/talker_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Talker talker = TalkerFlutter.init();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Pytorch Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(talker: talker),
    );
  }
}
