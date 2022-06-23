import 'package:flutter/material.dart';
import 'package:money_link/objectbox.dart';

import '../component/person_widget.dart';
import '../model/person.dart';
import '../model/tile.dart';
import '../objectbox.g.dart';

class PeoplePage extends StatefulWidget {
  final Person? selectedPerson;
  final ScrollController scrollController;
  final void Function(Person?) onTappedPerson;
  final void Function(Person) onPersonDeleted;

  const PeoplePage({Key? key, required this.onTappedPerson, required this.onPersonDeleted, required this.scrollController, this.selectedPerson})
      : super(key: key);

  @override
  State<PeoplePage> createState() => _State();
}

class _State extends State<PeoplePage> {
  final TextEditingController _editTextController = TextEditingController();
  String _searchTerm = "";

  final _peopleBox = ObjectBox.store.box<Person>();
  late Stream<List<Person>> _peopleStream;

  @override
  void initState() {
    super.initState();
    _clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Person>>(
        initialData: [],
        stream: _peopleStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              controller: widget.scrollController,
              children: getListItems(context, snapshot.data ?? <Person>[]),
            );
          }

          return ErrorWidget(snapshot.error ?? "Something went wrong :(");
        });
  }

  List<Widget> getListItems(BuildContext context, List<Person> people) {
    final content = <Widget>[];
    content.add(
      Card(
        child: TextField(
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.search,
          controller: _editTextController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            suffixIcon: _searchTerm.isEmpty
                ? const Icon(Icons.search)
                : IconButton(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.clear),
                  ),
            hintStyle: const TextStyle(color: Colors.blueGrey),
            hintText: 'Find or Add a person',
          ),
        ),
      ),
    );

    content.addAll(peopleCards(context, people));
    return content;
  }

  List<Widget> peopleCards(BuildContext context, List<Person> people) {
    if (people.isEmpty && _searchTerm.isNotEmpty) {
      return [
        Card(
          child: ListTile(
            title: Text(_searchTerm),
            contentPadding: const EdgeInsets.only(left: 16),
            trailing: IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _addPerson),
            subtitle: const Text("Tap + to add this person", style: TextStyle(color: Colors.blueGrey)),
          ),
        ),
      ];
    } else if (people.isNotEmpty && _searchTerm.isNotEmpty) {
      return people.map((p) => buildTile(EntityTile.personTile(p))).toList();
    }
    final List<Tile> otherPeopleTiles = people.where((p) => p.total() != 0).map((p) => EntityTile.personTile(p)).toList();

    final List<Tile> paidUpPeopleTiles = people.where((p) => p.total() == 0).map((p) => EntityTile.personTile(p)).toList();

    if (otherPeopleTiles.isEmpty) {
      return paidUpPeopleTiles.map(buildTile).toList();
    }
    if (paidUpPeopleTiles.isEmpty) {
      return otherPeopleTiles.map(buildTile).toList();
    }

    final paidUpExpansionTile = GroupTile(title: "SETTLED", subtitle: "Everything paid up", innerTiles: paidUpPeopleTiles);
    final List<Tile> groups = [paidUpExpansionTile].where((group) => group.innerTiles.isNotEmpty).toList();

    List<Tile> comboList = <Tile>[];
    comboList.addAll(otherPeopleTiles);
    comboList.addAll(groups);

    return comboList.map(buildTile).toList();
  }

  Widget buildTile(Tile tile, {double subTileIndentation = 10}) {
    if (tile is EntityTile<Person>) {
      final isSelectedPerson = tile.object.id == widget.selectedPerson?.id;
      return PersonWidget(
          person: tile.object,
          isSelected: isSelectedPerson,
          onTappedPerson: widget.onTappedPerson,
          onPersonDeleted: widget.onPersonDeleted,
          titleLeftPad: subTileIndentation);
    }

    final group = tile as GroupTile;
    return Card(
      child: ExpansionTile(
        backgroundColor: Colors.grey[200],
        tilePadding: EdgeInsets.only(left: subTileIndentation),
        title: Text(
          group.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        subtitle: Text(
          group.subtitle,
          style: const TextStyle(
            color: Colors.blueGrey,
          ),
        ),
        children: group.innerTiles
            .map((subTile) => buildTile(
                  subTile,
                  subTileIndentation: 2 * subTileIndentation,
                ))
            .toList(),
      ),
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchTerm = value;
      if (_searchTerm.isEmpty) {
        _peopleStream = _peopleBox.query().watch(triggerImmediately: true).map((q) => q.find());
      } else {
        _peopleStream = _peopleBox.query(Person_.fullName.startsWith(_searchTerm)).watch(triggerImmediately: true).map((q) => q.find());
      }
    });
  }

  void _addPerson() {
    _peopleBox.put(Person(fullName: _searchTerm));
  }

  void _clearSearch() {
    _editTextController.clear();
    _onSearchChanged("");
  }
}
