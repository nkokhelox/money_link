/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        primaryColor: Colors.blueGrey,
        splashFactory: NoSplash.splashFactory,
        hintColor: Colors.blueGrey[100],
        brightness: Brightness.light,
        primarySwatch: Colors.blueGrey,
        disabledColor: Colors.blueGrey[50],
        selectedRowColor: Colors.blueGrey[100],
        unselectedWidgetColor: Colors.blueGrey,
        textTheme: TextTheme(subtitle2: TextStyle(color: Colors.blueGrey)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: Colors.black54,
        splashFactory: NoSplash.splashFactory,
        hintColor: Colors.grey[900],
        brightness: Brightness.dark,
        disabledColor: Colors.white10,
        primarySwatch: Colors.blueGrey,
        selectedRowColor: Colors.white24,
        unselectedWidgetColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.black45),
        listTileTheme: ListTileThemeData(
          tileColor: Colors.black12,
          iconColor: Colors.black,
        ),
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          foregroundColor: Colors.black,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.black38,
          foregroundColor: Colors.black,
        ),
        textTheme: TextTheme(
          headline6: TextStyle(color: Colors.black),
          subtitle1: TextStyle(color: Colors.black),
          subtitle2: TextStyle(color: Colors.black),
          bodyText1: TextStyle(color: Colors.black),
          bodyText2: TextStyle(color: Colors.black),
          caption: TextStyle(color: Colors.black),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.system,
    );
  }
}
