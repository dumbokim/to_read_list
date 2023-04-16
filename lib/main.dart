import 'package:flutter/material.dart';

import 'pages/main/main_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Read List',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: MainView(),
      // const HomeView(title: 'To Read List'),
    );
  }
}
