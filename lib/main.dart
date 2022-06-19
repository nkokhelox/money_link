/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
import 'package:dual_screen/dual_screen.dart';
import 'package:flutter/material.dart';
import 'package:money_link/mode_landscape/detail_amounts_page.dart';
import 'package:money_link/mode_landscape/master_people_page.dart';
import 'package:money_link/mode_portrait/portrait_people_page.dart';
import 'package:money_link/model/person.dart';

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
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape || MediaQuery.of(context).size.width > 540) {
          return TwoPane(
            paneProportion: 0.45,
            panePriority: TwoPanePriority.both,
            startPane: MasterPeoplePage(
              onTappedPerson: (Person? person) => onPersonTap(person),
              onPersonDeleted: (Person person) => personDeleted(person),
              selectedPerson: selectedPerson,
            ),
            endPane: DetailAmountPage(person: selectedPerson),
          );
        } else {
          return PortraitPeoplePage(
            onTappedPerson: (Person? person) => onPersonTap(person),
            onPersonDeleted: (Person person) => personDeleted(person),
            selectedPerson: selectedPerson,
          );
        }
      },
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
}
