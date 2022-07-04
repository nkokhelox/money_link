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
    return MaterialApp(
      home: Home(),
      theme: ThemeData(
        brightness: Brightness.light,
        disabledColor: Colors.green[50],
        hintColor: Colors.blue[100],
        selectedRowColor: Colors.blue[100],
        textTheme: TextTheme(subtitle2: TextStyle(color: Colors.blueGrey)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        disabledColor: Colors.black54,
        primarySwatch: Colors.blueGrey,
        selectedRowColor: Colors.grey[600],
        iconTheme: IconThemeData(color: Colors.black54),
        appBarTheme: AppBarTheme(foregroundColor: Colors.black),
        textTheme: TextTheme(
          headline6: TextStyle(color: Colors.black),
          subtitle1: TextStyle(color: Colors.black),
          subtitle2: TextStyle(color: Colors.black54),
          bodyText1: TextStyle(color: Colors.black),
          bodyText2: TextStyle(color: Colors.black54),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.system,
    );
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
  void initState() {
    super.initState();
  }

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
              title: InkWell(child: Text(isDualPane ? "PEOPLE - AMOUNTS" : "PEOPLE", style: TextStyle(letterSpacing: 4)), onLongPress: jumpToTop),
              actions: chartIcon(isDualPane),
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
    clearSelectedPerson();
  }

  List<Widget> chartIcon(bool isDualPane) {
    return isDualPane ? [IconButton(onPressed: clearSelectedPerson, icon: Icon(Icons.stacked_bar_chart))] : [];
  }

  void clearSelectedPerson() {
    setState(() {
      _selectedPerson = null;
    });
  }
}
