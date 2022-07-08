import 'package:flutter/material.dart';
import 'package:money_link/page/home_page.dart';

class LockScreenPage extends StatefulWidget {
  const LockScreenPage({super.key});

  @override
  State<LockScreenPage> createState() => _LockScreenPageState();
}

class _LockScreenPageState extends State<LockScreenPage> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: unlockApp,
      label: Text("UNLOCK APP"),
      icon: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Icon(Icons.shield, size: 100),
          Icon(Icons.lock_outline, size: 60, color: Theme.of(context).primaryColor),
        ],
      ),
    );
  }

  void unlockApp() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
  }
}
