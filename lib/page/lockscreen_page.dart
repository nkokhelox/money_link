import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      body: SafeArea(
        child: InkWell(
          onTap: singlePress,
          onLongPress: longPress,
          onDoubleTap: doublePress,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: dotsList(),
              ),
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Icon(
                    Icons.shield,
                    size: 300,
                  ),
                  Icon(
                    Icons.lock_outline,
                    size: 180,
                    color: Theme.of(context).canvasColor,
                  ),
                ],
              ),
              Text("Locked"),
            ],
          ),
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
    if (pressSequence.length < _hardCodedPattern.length) {
      return;
    }
    if (pressSequence.length == _hardCodedPattern.length &&
        pressSequence.join() == _hardCodedPattern) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          pressSequence.clear();
        });
        unlockApp();
      });
      return;
    }
    await Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        pressSequence.clear();
      });
    });
  }

  List<Widget> dotsList() {
    List<Widget> list = [];
    for (var i = 0; i < _hardCodedPattern.length; i++) {
      list.add(
        Icon(
          pressSequence.length > i ? Icons.circle : Icons.circle_outlined,
          size: 30,
        ),
      );
    }
    return list;
  }

  void unlockApp() {
    Navigator.pushReplacement(
      context,
      PageTransition(
        curve: Curves.linear,
        type: PageTransitionType.bottomToTop,
        child: HomePage(),
      ),
    );
  }
}
