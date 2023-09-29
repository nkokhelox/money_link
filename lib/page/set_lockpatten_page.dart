import 'package:flutter/material.dart';
import 'package:money_link/page/home_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetLockPattenPage extends StatefulWidget {
  const SetLockPattenPage({super.key});

  @override
  State<SetLockPattenPage> createState() => _SetLockPattenPage();
}

class _SetLockPattenPage extends State<SetLockPattenPage> {
  var PATTEN = "unlock_patten";
  static String _hardCodedPattern = "231"; // pattern for shared prefs
  final List<int> currentSequence = <int>[];
  final List<int> newSequence = <int>[];
  bool enteringNewPatten = false;
  bool verifyNewPatten = false;
  final List<int> verificationSequence = <int>[];
  SharedPreferences? prefs = null;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, AsyncSnapshot<SharedPreferences> preferences) {
        var color = Colors.green;
        if (verifyNewPatten) {
          color = Colors.red;
        } else if (enteringNewPatten) {
          color = Colors.amber;
        }
        if (preferences.hasData) {
             prefs = preferences.data;
          _hardCodedPattern = prefs?.getString(PATTEN) ?? "231";

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
                    Text(
                      "Current patten ${_hardCodedPattern}",
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: dotsList(currentSequence, color),
                    ),
                    Divider(),
                    Text(
                      "New patten",
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: dotsList(newSequence, color),
                    ),
                    Divider(),
                    Text(
                      "Confirm new patten",
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: dotsList(verificationSequence, color),
                    ),
                    Divider(),
                    Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Icon(
                          Icons.shield,
                          size: 300,
                          color: color,
                        ),
                        Icon(
                          Icons.lock_outline,
                          size: 180,
                          color: Theme
                              .of(context)
                              .canvasColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Text("error");
        }
      }
    );
  }

  void singlePress() {
    putPatten(1);
  }

  void doublePress() {
    putPatten(2);
  }

  void longPress() {
    putPatten(3);
  }

  void putPatten(int value) {
    setState(() {
      if (verifyNewPatten) {
        verificationSequence.add(value);
      } else if (enteringNewPatten) {
        newSequence.add(value);
      } else {
        currentSequence.add(value);
      }
    });
    verify();
  }

  Future<void> verify() async {
    if (verifyNewPatten) {
      if (verificationSequence.length < _hardCodedPattern.length) {
        return;
      }
      if (verificationSequence.length >= _hardCodedPattern.length &&
          verificationSequence.join() == newSequence.join()) {
        // encrypt save to shared prefes & lock
prefs?.setString(PATTEN, verificationSequence.join());

        unlockApp();
        return;
      } else {
        setState(() {
          verifyNewPatten = false;
        });
        verificationSequence.clear();
        newSequence.clear();
      }
    } else if (enteringNewPatten) {
      if (newSequence.length < _hardCodedPattern.length) {
        return;
      }
      if (newSequence.length >= _hardCodedPattern.length) {
        setState(() {
          verifyNewPatten = true;
        });
        return;
      }
    } else {
      if (currentSequence.length < _hardCodedPattern.length) {
        return;
      }
      if (currentSequence.length == _hardCodedPattern.length) {
        if (currentSequence.join() == _hardCodedPattern) {
          setState(() {
            enteringNewPatten = true;
          });
          return;
        } else {
          await Future.delayed(const Duration(milliseconds: 500), () {
            setState(() {
              currentSequence.clear();
            });
          });
        }
      }
    }
  }

  List<Widget> dotsList(List<int> ts, Color color) {
    List<Widget> list = [];

    for (var i = 0; i < _hardCodedPattern.length; i++) {
      list.add(
        Icon(
          ts.length > i ? Icons.circle : Icons.circle_outlined,
          color: color,
          size: 30,
        ),
      );
    }
    return list;
  }

  void unlockApp() {
    Navigator.pop(context);
  }
}
