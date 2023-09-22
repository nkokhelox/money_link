/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
import 'package:dynamic_color/dynamic_color.dart';
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

    static final _defaultLightColorScheme =
    ColorScheme.fromSwatch(primarySwatch: Colors.blue);

    static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
        primarySwatch: Colors.blue, brightness: Brightness.dark);

    @override
    Widget build(BuildContext context) {
      return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          title: 'Money matters',
          themeMode: ThemeMode.system,
          home: const LockScreenPage(),
            debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: lightColorScheme ?? _defaultLightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
            useMaterial3: true,
          ),
        );
      });
    }

}
