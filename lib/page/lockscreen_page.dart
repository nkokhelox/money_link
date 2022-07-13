import 'package:flutter/material.dart';
import 'package:money_link/page/home_page.dart';
import 'package:page_transition/page_transition.dart';

class LockScreenPage extends StatefulWidget {
  const LockScreenPage({super.key});

  @override
  State<LockScreenPage> createState() => _LockScreenPageState();
}

class _LockScreenPageState extends State<LockScreenPage> {
  static String _hardCodedPattern = "123321";
  final List<int> pressSequence = <int>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: singlePress,
        onLongPress: longPress,
        onDoubleTap: doublePress,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [],
            ),
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Icon(Icons.shield, size: 100),
                Icon(Icons.lock_outline,
                    size: 60, color: Theme.of(context).primaryColor),
              ],
            ),
            Text(
              "UNLOCK APP",
              style: TextStyle(
                color:
                    pressSequence.length == 0 ? Colors.green : Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void singlePress() {
    setState(() {
      pressSequence.add(1);
    });
    verify();
  }

  void doublePress() {
    setState(() {
      pressSequence.add(2);
    });
    verify();
  }

  void longPress() {
    setState(() {
      pressSequence.add(3);
    });
    verify();
  }

  void verify() {
    if (pressSequence.length == 6 &&
        pressSequence.join() == _hardCodedPattern) {
      pressSequence.clear();
      unlockApp();
    }

    if (pressSequence.length < 6) {
      return;
    }

    setState(() {
      // shake the UI with a vibration.
      pressSequence.clear();
    });
  }

  void unlockApp() {
    Navigator.pushReplacement(
        context,
        PageTransition(
            curve: Curves.linear,
            type: PageTransitionType.bottomToTop,
            child: HomePage()));
  }
}
