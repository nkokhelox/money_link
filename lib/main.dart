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
      theme: ThemeData.light(
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(
          useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    );
  }
}
