import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_link/component/person_widget.dart';

import 'component/settings.dart';
import 'model/data.dart';
import 'model/person.dart';
import 'model/tile.dart';

class PeoplePortraitPage extends StatefulWidget {
  final Person? selectedPerson;
  final void Function(Person?) onTappedPerson;
  final void Function(Person) onPersonDeleted;

  const PeoplePortraitPage(
      {Key? key,
      required this.onTappedPerson,
      required this.onPersonDeleted,
      this.selectedPerson})
      : super(key: key);

  @override
  State<PeoplePortraitPage> createState() => _State();
}

class _State extends State<PeoplePortraitPage> {
  final TextEditingController _editTextController = TextEditingController();
  List<Person> searchResult = [];
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (_) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        drawer: const SettingsDrawer(),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              SlidableAutoCloseBehavior(
            child: CustomScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  stretch: false,
                  floating: false,
                  leading: IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  expandedHeight: constraints.maxWidth,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: InkWell(
                      onTap: () => jumpToTop(scrollController),
                      child: const Text(
                        "PEOPLE",
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Card(
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
                                onPressed: () {
                                  _editTextController.clear();
                                  onTextChanged("");
                                },
                                icon: const Icon(Icons.clear),
                              ),
                        hintStyle: const TextStyle(color: Colors.blueGrey),
                        hintText: 'Find or Add a person',
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ListView(
                    primary: false,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    children: getListItems(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getListItems(BuildContext context) {
    if (searchResult.isEmpty && searchQuery.isNotEmpty) {
      return [
        Card(
          child: ListTile(
            title: Text(searchQuery),
            contentPadding: const EdgeInsets.only(left: 16),
            trailing: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: addPerson),
            subtitle: const Text("Tap + to add this person",
                style: TextStyle(color: Colors.blueGrey)),
          ),
        ),
      ];
    } else if (searchResult.isNotEmpty) {
      return searchResult
          .map((p) => buildTile(EntityTile.personTile(p)))
          .toList();
    } else {
      final List<Tile> otherPeopleTiles = Data.people
          .where((p) => p.total() != 0)
          .map((p) => EntityTile.personTile(p))
          .toList();
      final List<Tile> paidUpPeopleTiles = Data.people
          .where((p) => p.total() == 0)
          .map((p) => EntityTile.personTile(p))
          .toList();

      if (otherPeopleTiles.isEmpty) {
        return paidUpPeopleTiles.map(buildTile).toList();
      } else if (paidUpPeopleTiles.isEmpty) {
        return otherPeopleTiles.map(buildTile).toList();
      } else {
        final paidUpExpansionTile = GroupTile(
            title: "SETTLED",
            subtitle: "Everything paid up",
            innerTiles: paidUpPeopleTiles);
        final List<Tile> groups = [paidUpExpansionTile]
            .where((group) => group.innerTiles.isNotEmpty)
            .toList();

        List<Tile> comboList = <Tile>[];
        comboList.addAll(otherPeopleTiles);
        comboList.addAll(groups);

        return comboList.map(buildTile).toList();
      }
    }
  }

  Widget buildTile(Tile tile, {double subTileIndentation = 5.0}) {
    if (tile is EntityTile<Person>) {
      final isSelectedPerson = tile.object.id == widget.selectedPerson?.id;
      return PersonExpandableWidget(
        person: tile.object,
        isSelected: isSelectedPerson,
        onTappedPerson: widget.onTappedPerson,
        onPersonDeleted: widget.onPersonDeleted,
        titleLeftPad: subTileIndentation,
      );
    }

    final group = tile as GroupTile;
    return Card(
      child: ExpansionTile(
        backgroundColor: Colors.grey[200],
        tilePadding: EdgeInsets.only(left: subTileIndentation),
        title: Text(group.title,
            style:
                const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        subtitle: Text(group.subtitle,
            style: const TextStyle(color: Colors.blueGrey)),
        children: group.innerTiles
            .map((subTile) => buildTile(subTile,
                subTileIndentation: (2 * subTileIndentation)))
            .toList(),
      ),
    );
  }

  void addPerson() {
    Data.people.add(Person(id: 0, fullName: searchQuery));
    final tempQuery = searchQuery;
    onTextChanged("");
    onTextChanged(tempQuery);
  }

  void jumpToTop(ScrollController scrollController) {
    widget.onTappedPerson(null);
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void onTextChanged(String value) {
    setState(() {
      searchQuery = value;
      searchResult =
          Data.people.where((p) => p.matchQuery(LenientMatch(value))).toList();
    });
  }
}
