/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
import 'package:dual_screen/dual_screen.dart';
import 'package:flutter/material.dart';
import 'package:money_link/model/person.dart';

import 'component/portrait_only_route.dart';
import 'objectbox.dart';
import 'page/amounts_page.dart';
import 'page/people_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ObjectBox.create();
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
  Person? _selectedPerson;
  final GlobalKey<PeoplePageState> _peoplePageKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    ObjectBox.store.close();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final isDualPane = constraints.maxWidth > 550;
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: InkWell(
                onLongPress: jumpToTop,
                child: Text(isDualPane ? "PEOPLE - AMOUNTS" : "PEOPLE", style: const TextStyle(letterSpacing: 4)),
              ),
            ),
            body: TwoPane(
              paneProportion: 0.45,
              panePriority: isDualPane ? TwoPanePriority.both : TwoPanePriority.start,
              startPane: PeoplePage(
                key: _peoplePageKey,
                onPersonDeleted: (Person person) => personDeleted(person),
                onTappedPerson: (Person? person) => onPersonTap(person, isDualPane),
                scrollController: _scrollController,
                selectedPerson: _selectedPerson,
              ),
              endPane: AmountsPage(selectedPerson: _selectedPerson, appBarHidden: true, refreshPeople: refreshPeople),
            ),
          );
        },
      ),
    );
  }

  void onPersonTap(Person? person, bool isDualPane) {
    setState(() {
      _selectedPerson = person;
    });
    if (!isDualPane && person != null) {
      Navigator.push(
        context,
        PortraitOnlyRoute(
          builder: (context) => AmountsPage(selectedPerson: person, appBarHidden: false, refreshPeople: refreshPeople),
        ),
      );
    }
  }

  void refreshPeople() {
    _peoplePageKey.currentState?.refreshPeopleStream();
  }

  void personDeleted(Person person) {
    if (person.id == _selectedPerson?.id) {
      setState(() {
        _selectedPerson = null;
      });
    }
  }

  void jumpToTop() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    setState(() {
      _selectedPerson = null;
    });
  }
}
