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
        hintColor: Colors.white70,
        brightness: Brightness.light,
        primarySwatch: Colors.blueGrey,
        expansionTileTheme: ExpansionTileThemeData(
          iconColor: Colors.blueGrey,
          textColor: Colors.blueGrey,
          collapsedIconColor: Colors.blueGrey,
        ),
        listTileTheme: ListTileThemeData(
          selectedTileColor: Colors.black12,
          selectedColor: Colors.blueGrey,
          iconColor: Colors.blueGrey,
        ),
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.blueGrey),
          suffixIconColor: Colors.blueGrey,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(color: Colors.blueGrey),
          displayMedium: TextStyle(color: Colors.blueGrey),
          displaySmall: TextStyle(color: Colors.blueGrey),
          headlineMedium: TextStyle(color: Colors.blueGrey),
          headlineSmall: TextStyle(color: Colors.blueGrey),
          titleLarge: TextStyle(color: Colors.blueGrey),
          titleMedium: TextStyle(color: Colors.blueGrey),
          titleSmall: TextStyle(color: Colors.blueGrey),
          bodyLarge: TextStyle(color: Colors.blueGrey),
          bodyMedium: TextStyle(color: Colors.blueGrey),
          bodySmall: TextStyle(color: Colors.blueGrey),
          labelLarge: TextStyle(color: Colors.blueGrey),
          labelSmall: TextStyle(color: Colors.blueGrey),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        primaryColor: Colors.black54,
        splashFactory: NoSplash.splashFactory,
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        expansionTileTheme: ExpansionTileThemeData(
          iconColor: Colors.black,
          textColor: Colors.black,
          collapsedIconColor: Colors.black,
        ),
        listTileTheme: ListTileThemeData(
          selectedTileColor: Colors.black12,
          selectedColor: Colors.black,
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
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.black),
          suffixIconColor: Colors.black,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(color: Colors.black),
          displayMedium: TextStyle(color: Colors.black),
          displaySmall: TextStyle(color: Colors.black),
          headlineMedium: TextStyle(color: Colors.black),
          headlineSmall: TextStyle(color: Colors.black),
          titleLarge: TextStyle(color: Colors.black),
          titleMedium: TextStyle(color: Colors.black),
          titleSmall: TextStyle(color: Colors.black),
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
          labelLarge: TextStyle(color: Colors.black),
          labelSmall: TextStyle(color: Colors.black),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.system,
    );
  }
}
