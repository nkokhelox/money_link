import 'package:flutter/material.dart';
import 'package:money_link/page/home_page.dart';
import 'package:page_transition/page_transition.dart';

class LockScreenPage extends StatefulWidget {
  const LockScreenPage({super.key});

  @override
  State<LockScreenPage> createState() => _LockScreenPageState();
}

class _LockScreenPageState extends State<LockScreenPage> {
  static String _hardCodedPattern = "231";
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
                Icon(Icons.shield, size: 300, color: Theme.of(context).primaryColor),
                Icon(Icons.lock_outline, size: 180, color: Theme.of(context).canvasColor),
              ],
            ),
            Text(
              "UNLOCK APP",
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? (pressSequence.length == 0 ? Colors.blueGrey : Colors.blueGrey[700])
                    : (pressSequence.length == 0 ? Colors.black : Colors.black45),
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

  Future<void> verify() async {
    if (pressSequence.length == _hardCodedPattern.length && pressSequence.join() == _hardCodedPattern) {
      pressSequence.clear();
      unlockApp();
    }

    if (pressSequence.length < _hardCodedPattern.length) {
      return;
    }

    setState(() {
      pressSequence.clear();
    });
  }

  void unlockApp() {
    Navigator.pushReplacement(context, PageTransition(curve: Curves.linear, type: PageTransitionType.bottomToTop, child: HomePage()));
  }
}
