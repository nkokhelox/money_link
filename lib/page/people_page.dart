import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_link/component/person_widget.dart';
import 'package:money_link/component/search_field.dart';
import 'package:money_link/model/person.dart';
import 'package:money_link/model/tile.dart';
import 'package:money_link/objectbox.dart';
import 'package:money_link/objectbox.g.dart';

class PeoplePage extends StatefulWidget {
  final Person? selectedPerson;
  final ScrollController scrollController;
  final void Function(Person?) onTappedPerson;
  final void Function(Person) onPersonDeleted;

  const PeoplePage({
    Key? key,
    required this.onTappedPerson,
    required this.onPersonDeleted,
    required this.scrollController,
    this.selectedPerson,
  }) : super(key: key);

  @override
  State<PeoplePage> createState() => PeoplePageState();
}

class PeoplePageState extends State<PeoplePage> {
  final TextEditingController _searchFieldController = TextEditingController();
  final _peopleBox = ObjectBox.store.box<Person>();
  late Stream<List<Person>> _peopleStream;

  @override
  void initState() {
    super.initState();
    _onSearchChanged();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Person>>(
      initialData: [],
      stream: _peopleStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SlidableAutoCloseBehavior(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(parent: const BouncingScrollPhysics()),
              controller: widget.scrollController,
              children: _getPersonListItems(context, snapshot.data ?? <Person>[]),
            ),
          );
        }

        return ErrorWidget(snapshot.error ?? "Something went wrong :(");
      },
    );
  }

  List<Widget> _getPersonListItems(BuildContext context, List<Person> people) {
    final content = <Widget>[];
    content.add(
      SearchField(
        hint: 'Find or Add a person',
        keyboardType: TextInputType.name,
        onSearchChanged: _onSearchChanged,
        editTextController: _searchFieldController,
        textCapitalization: TextCapitalization.words,
      ),
    );

    content.addAll(_peopleCards(context, people));
    return content;
  }

  List<Widget> _peopleCards(BuildContext context, List<Person> people) {
    final searchTerm = _searchFieldController.text;
    if (people.isEmpty && searchTerm.isNotEmpty) {
      return [
        Card(
          child: ListTile(
            title: Text(searchTerm),
            contentPadding: const EdgeInsets.only(left: 16),
            trailing: IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _addPerson),
            subtitle: const Text("Tap + to add this person", style: TextStyle(color: Colors.blueGrey)),
          ),
        ),
      ];
    } else if (people.isNotEmpty && searchTerm.isNotEmpty) {
      return people.map((p) => _buildTile(EntityTile.personTile(p))).toList();
    }
    final List<EntityTile> otherPeopleTiles = people.where((p) => p.owingTotal() != 0).map((p) => EntityTile.personTile(p)).toList();

    final List<EntityTile<Person>> paidUpPeopleTiles = people.where((p) => p.owingTotal() == 0).map((p) => EntityTile.personTile(p)).toList();

    if (otherPeopleTiles.isEmpty) {
      return paidUpPeopleTiles.map(_buildTile).toList();
    }
    if (paidUpPeopleTiles.isEmpty) {
      return otherPeopleTiles.map(_buildTile).toList();
    }

    final paidTotal = paidUpPeopleTiles.fold<double>(0.0, (sum, pt) => sum + pt.object.paidTotal());

    final paidUpExpansionTile = GroupTile(title: "SETTLED PEOPLE", subtitle: "R $paidTotal", innerTiles: paidUpPeopleTiles);

    List<Tile> comboList = <Tile>[];
    comboList.addAll(otherPeopleTiles);
    comboList.add(paidUpExpansionTile);

    return comboList.map(_buildTile).toList();
  }

  Widget _buildTile(Tile tile, {double subTileIndentation = 10}) {
    if (tile is EntityTile<Person>) {
      final isSelectedPerson = tile.object.id == widget.selectedPerson?.id;
      return PersonWidget(
        person: tile.object,
        isSelected: isSelectedPerson,
        onTappedPerson: widget.onTappedPerson,
        onPersonDeleted: widget.onPersonDeleted,
        titleLeftPad: subTileIndentation,
        refreshPeople: refreshPeopleStream,
      );
    }

    final group = tile as GroupTile;
    return Card(
      child: ExpansionTile(
        tilePadding: EdgeInsets.only(left: subTileIndentation),
        title: Text(group.title, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        subtitle: Text(group.subtitle),
        children: group.innerTiles.map((subTile) => _buildTile(subTile, subTileIndentation: 2 * subTileIndentation)).toList(),
      ),
    );
  }

  void _onSearchChanged() {
    setState(() {
      String searchTerm = _searchFieldController.text;
      if (searchTerm.isEmpty) {
        _peopleStream = _peopleBox.query().watch(triggerImmediately: true).map((q) => q.find());
      } else {
        _peopleStream = _peopleBox.query(Person_.fullName.startsWith(searchTerm)).watch(triggerImmediately: true).map((q) => q.find());
      }
    });
  }

  void _addPerson() => _peopleBox.put(Person(fullName: _searchFieldController.text));

  void refreshPeopleStream() => _onSearchChanged();
}
