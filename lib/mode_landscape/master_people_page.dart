import 'package:flutter/material.dart';

import '../model/data.dart';
import '../model/person.dart';
import '../model/tile.dart';
import 'master_person_widget.dart';

class MasterPeoplePage extends StatefulWidget {
  final Person? selectedPerson;
  final ScrollController scrollController;
  final void Function(Person?) onTappedPerson;
  final void Function(Person) onPersonDeleted;

  const MasterPeoplePage({Key? key, required this.onTappedPerson, required this.onPersonDeleted, required this.scrollController, this.selectedPerson})
      : super(key: key);

  @override
  State<MasterPeoplePage> createState() => _State();
}

class _State extends State<MasterPeoplePage> {
  final TextEditingController _editTextController = TextEditingController();
  List<Person> searchResult = [];
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const BouncingScrollPhysics(),
      controller: widget.scrollController,
      children: getListItems(context),
    );
  }

  List<Widget> getListItems(BuildContext context) {
    final content = <Widget>[];
    content.add(
      Card(
        child: TextField(
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.search,
          controller: _editTextController,
          onChanged: onTextChanged,
          decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            suffixIcon: searchQuery.isEmpty
                ? const Icon(Icons.search)
                : IconButton(
                    onPressed: clearSearch,
                    icon: const Icon(Icons.clear),
                  ),
            hintStyle: const TextStyle(color: Colors.blueGrey),
            hintText: 'Find or Add a person',
          ),
        ),
      ),
    );

    content.addAll(peopleCards(context));
    return content;
  }

  List<Widget> peopleCards(BuildContext context) {
    if (searchResult.isEmpty && searchQuery.isNotEmpty) {
      return [
        Card(
          child: ListTile(
            title: Text(searchQuery),
            contentPadding: const EdgeInsets.only(left: 16),
            trailing: IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: addPerson),
            subtitle: const Text("Tap + to add this person", style: TextStyle(color: Colors.blueGrey)),
          ),
        ),
      ];
    } else if (searchResult.isNotEmpty) {
      return searchResult.map((p) => buildTile(EntityTile.personTile(p))).toList();
    }
    final List<Tile> otherPeopleTiles = Data.people.where((p) => p.total() != 0).map((p) => EntityTile.personTile(p)).toList();

    final List<Tile> paidUpPeopleTiles = Data.people.where((p) => p.total() == 0).map((p) => EntityTile.personTile(p)).toList();

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
      return MasterPersonWidget(
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

  void onTextChanged(String value) {
    setState(() {
      searchQuery = value;
      searchResult = Data.people.where((p) => p.matchQuery(LenientMatch(value))).toList();
    });
  }

  void addPerson() {
    Data.people.add(Person(id: 0, fullName: searchQuery));
    final tempQuery = searchQuery;
    onTextChanged("");
    onTextChanged(tempQuery);
  }

  void deletePerson(BuildContext context, Person person) {
    Data.people.removeWhere((p) => p.id == person.id);
    widget.onPersonDeleted(person);
    var temp = searchQuery;
    onTextChanged("");
    onTextChanged(temp);
  }

  void clearSearch() {
    _editTextController.clear();
    onTextChanged("");
  }
}
