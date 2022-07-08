/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
import 'package:flutter/material.dart';
import 'package:money_link/page/lockscreen_page.dart';

import 'objectbox.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ObjectBox.create();
  runApp(const MainApplication());
}

class MainApplication extends StatefulWidget {
  const MainApplication({Key? key}) : super(key: key);

  @override
  State<MainApplication> createState() => _MainApplicationState();
}

class _MainApplicationState extends State<MainApplication> {
  @override
  void dispose() {
    super.dispose();
    ObjectBox.store.close();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LockScreenPage(),
      theme: ThemeData(
        hintColor: Colors.blue[100],
        brightness: Brightness.light,
        primarySwatch: Colors.blueGrey,
        disabledColor: Colors.green[50],
        selectedRowColor: Colors.blue[100],
        textTheme: TextTheme(subtitle2: TextStyle(color: Colors.blueGrey)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        disabledColor: Colors.black54,
        primarySwatch: Colors.blueGrey,
        selectedRowColor: Colors.grey[600],
        iconTheme: IconThemeData(color: Colors.black54),
        appBarTheme: AppBarTheme(foregroundColor: Colors.black),
        textTheme: TextTheme(
          headline6: TextStyle(color: Colors.black),
          subtitle1: TextStyle(color: Colors.black),
          subtitle2: TextStyle(color: Colors.black54),
          bodyText1: TextStyle(color: Colors.black),
          bodyText2: TextStyle(color: Colors.black54),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.system,
    );
  }
}
