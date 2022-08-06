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
        hintColor: Colors.blueGrey[100],
        brightness: Brightness.light,
        primarySwatch: Colors.blueGrey,
        disabledColor: Colors.blueGrey[50],
        selectedRowColor: Colors.blueGrey[100],
        textTheme: TextTheme(subtitle2: TextStyle(color: Colors.blueGrey)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        disabledColor: Colors.white10,
        primarySwatch: Colors.blueGrey,
        selectedRowColor: Colors.black12,
        iconTheme: IconThemeData(color: Colors.blueGrey[400]),
        appBarTheme: AppBarTheme(foregroundColor: Colors.blueGrey[400]),
        textTheme: TextTheme(
          headline6: TextStyle(color: Colors.blueGrey[400]),
          subtitle1: TextStyle(color: Colors.blueGrey[400]),
          subtitle2: TextStyle(color: Colors.blueGrey[400]),
          bodyText1: TextStyle(color: Colors.blueGrey[400]),
          bodyText2: TextStyle(color: Colors.blueGrey[400]),
          caption: TextStyle(color: Colors.blueGrey),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.system,
    );
  }
}
