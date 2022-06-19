/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
import 'package:dual_screen/dual_screen.dart';
import 'package:flutter/material.dart';
import 'package:money_link/mode_landscape/detail_amounts_page.dart';
import 'package:money_link/mode_landscape/master_people_page.dart';
import 'package:money_link/mode_portrait/portrait_people_page.dart';
import 'package:money_link/model/person.dart';

import 'component/settings.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  Person? selectedPerson;

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Scaffold(
      drawer: const SettingsDrawer(),
      appBar: AppBar(
        title: InkWell(
          onLongPress: () => jumpToTop(scrollController),
          child: const Text("PEOPLE", style: TextStyle(letterSpacing: 4)),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (_) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape || MediaQuery.of(context).size.width > 540) {
              return TwoPane(
                paneProportion: 0.45,
                panePriority: TwoPanePriority.both,
                startPane: MasterPeoplePage(
                  onPersonDeleted: (Person person) => personDeleted(person),
                  onTappedPerson: (Person? person) => onPersonTap(person),
                  scrollController: scrollController,
                  selectedPerson: selectedPerson,
                ),
                endPane: DetailAmountPage(person: selectedPerson),
              );
            } else {
              return PortraitPeoplePage(
                onPersonDeleted: (Person person) => personDeleted(person),
                onTappedPerson: (Person? person) => onPersonTap(person),
                scrollController: scrollController,
                selectedPerson: selectedPerson,
              );
            }
          },
        ),
      ),
    );
  }

  void onPersonTap(Person? person) {
    setState(() {
      selectedPerson = person;
    });
  }

  void personDeleted(Person person) {
    if (person.id == selectedPerson?.id) {
      setState(() {
        selectedPerson = null;
      });
    }
  }

  void jumpToTop(ScrollController scrollController) {
    scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    onPersonTap(null);
  }
}
