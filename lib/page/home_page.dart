/// Copyright (c) Microsoft Corporation.
/// Licensed under the MIT License.
import 'package:dual_screen/dual_screen.dart';
import 'package:flutter/material.dart';
import 'package:money_link/component/portrait_only_route.dart';
import 'package:money_link/model/person.dart';
import 'package:money_link/page/amounts_page.dart';
import 'package:money_link/page/lockscreen_page.dart';
import 'package:money_link/page/people_page.dart';
import 'package:page_transition/page_transition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Person? _selectedPerson;
  final GlobalKey<PeoplePageState> _peoplePageKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: showExitPopup, //call function on back button press
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final isDualPane = constraints.maxWidth > 550;
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: InkWell(
                    child: Text(isDualPane ? "PEOPLE - AMOUNTS" : "PEOPLE",
                        style: TextStyle(letterSpacing: 4)),
                    onLongPress: jumpToTop),
                leading: IconButton(icon: Icon(Icons.lock), onPressed: lockApp),
                actions: chartIcon(isDualPane),
              ),
              body: TwoPane(
                paneProportion: 0.45,
                panePriority:
                    isDualPane ? TwoPanePriority.both : TwoPanePriority.start,
                startPane: PeoplePage(
                  key: _peoplePageKey,
                  onPersonDeleted: (Person person) => personDeleted(person),
                  onTappedPerson: (Person? person) =>
                      onPersonTap(person, isDualPane),
                  scrollController: _scrollController,
                  selectedPerson: _selectedPerson,
                ),
                endPane: AmountsPage(
                    selectedPerson: _selectedPerson,
                    appBarHidden: true,
                    refreshPeople: refreshPeople),
              ),
            );
          },
        ),
      ),
    );
  }

  void onPersonTap(Person? person, bool isDualPane) {
    setState(() {
      _selectedPerson = person;
    });
    if (!isDualPane) {
      Navigator.push(
        context,
        PortraitOnlyRoute(
          builder: (context) => AmountsPage(
              selectedPerson: person,
              appBarHidden: false,
              refreshPeople: refreshPeople),
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
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    clearSelectedPerson();
  }

  List<Widget> chartIcon(bool isDualPane) {
    if (isDualPane) {
      return this._selectedPerson != null
          ? [
              IconButton(
                  onPressed: clearSelectedPerson,
                  icon: Icon(Icons.stacked_bar_chart))
            ]
          : [];
    }

    return [
      IconButton(
          onPressed: () => onPersonTap(null, isDualPane),
          icon: Icon(Icons.stacked_bar_chart))
    ];
  }

  void clearSelectedPerson() {
    setState(() {
      _selectedPerson = null;
    });
  }

  void lockApp() {
    Navigator.pushReplacement(
      context,
      PageTransition(
        curve: Curves.linear,
        type: PageTransitionType.topToBottom,
        child: LockScreenPage(),
      ),
    );
  }

  Future<bool> showExitPopup() async {
    return await showDialog(
          //show confirm dialogue
          //the return value will be from "Yes" or "No" options
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit App'),
            content: Text('Do you want to exit an App?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                //return false when click on "NO"
                child: Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                //return true when click on "Yes"
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
