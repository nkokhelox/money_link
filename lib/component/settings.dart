import 'package:flutter/material.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Drawer(
      child: Scaffold(
        appBar: AppBar(
          title: InkWell(
            onTap: () {
              scrollController.animateTo(0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut);
            },
            child: const Text(
              "SETTINGS",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
          ),
        ),
        body: ListView(
          controller: scrollController,
          children: [
            Card(
              child: ExpansionTile(
                backgroundColor: Colors.grey[200],
                title: const Text("Person name search settings",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 2)),
                subtitle: const Text("setting description",
                    style: TextStyle(color: Colors.blueGrey)),
                children: const [
                  Text("More details"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
