import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_link/component/person_widget.dart';

import '../component/amount_widget.dart';
import '../model/amount.dart';
import '../model/data.dart';
import '../model/person.dart';
import '../model/tile.dart';

class PortraitPersonAmountsWidget extends APerson {
  final Person person;
  final bool isSelected;
  final double titleLeftPad;
  final void Function(Person) onTappedPerson;
  const PortraitPersonAmountsWidget({
    Key? key,
    required this.person,
    required this.isSelected,
    required this.titleLeftPad,
    required this.onTappedPerson,
    required super.onPersonDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maybeSelectionColor = isSelected ? Colors.blue[50] : null;
    return Card(
      color: maybeSelectionColor, // Colors.lightBlueAccent;,
      child: Slidable(
        key: ValueKey(person.objectId),
        closeOnScroll: true,
        groupTag: 'person',
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          dragDismissible: false,
          children: [
            SlidableAction(
              onPressed: (BuildContext context) => deletePerson(context, person),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              autoClose: true,
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          dragDismissible: false,
          children: [
            SlidableAction(
              onPressed: (context) => addAmount(context, person),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              icon: Icons.add,
              label: 'Amount',
              autoClose: true,
            ),
          ],
        ),
        child: getPerson(),
      ),
    );
  }

  Widget getPerson() {
    final amounts = Data.amounts;
    final paidAmountTiles = amounts.where((amounts) => amounts.paidDate != null).map((e) => EntityTile.amountTile(e)).toList();
    final unpaidAmountTiles = amounts.where((amounts) => amounts.paidDate == null).map((e) => EntityTile.amountTile(e)).toList();

    final paidGroupTile = GroupTile(title: "SETTLED", subtitle: "Paid up amounts", innerTiles: paidAmountTiles);

    List<Tile> comboList = <Tile>[];
    comboList.addAll(unpaidAmountTiles);
    if (paidGroupTile.innerTiles.isNotEmpty) {
      comboList.add(paidGroupTile);
    }

    List<Widget> children = comboList.map((tile) => buildAmountTile(tile, 2 * titleLeftPad)).toList();
    //person.amounts.map((tile) => buildAmountTile(tile, 2 * titleLeftPad)).toList();
    if (children.isEmpty) {
      children = [const Center(child: Text("No amounts"))];
    }

    return ExpansionTile(
      backgroundColor: Colors.amber[50] ?? Colors.amber,
      tilePadding: EdgeInsets.only(left: titleLeftPad),
      title: Text(person.fullName),
      subtitle: Text(person.moneyFormattedTotal(), maxLines: 1, style: const TextStyle(color: Colors.blueGrey)),
      onExpansionChanged: (_) => onTappedPerson(person),
      children: children,
    );
  }

  Widget buildAmountTile(Tile tile, double titleLeftPad) {
    if (tile is GroupTile) {
      return Card(
        child: ExpansionTile(
          backgroundColor: Colors.amber[100] ?? Colors.amber,
          tilePadding: EdgeInsets.only(left: titleLeftPad),
          title: const Text("PAID AMOUNTS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
          subtitle: const Text("Money paid back", maxLines: 1, style: TextStyle(color: Colors.blueGrey)),
          onExpansionChanged: (_) => onTappedPerson(person),
          children: tile.innerTiles.map((t) => buildAmountTile(t, titleLeftPad * 2)).toList(),
        ),
      );
    }

    return AmountWidget(amount: (tile as EntityTile<Amount>).object, titleLeftPad: titleLeftPad);
  }
}
