import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_link/component/chart.dart';
import 'package:money_link/model/person.dart';

import '../component/amount_widget.dart';
import '../model/amount.dart';
import '../model/data.dart';
import '../model/tile.dart';

class DetailAmountPage extends StatelessWidget {
  final Person? person;
  const DetailAmountPage({Key? key, required this.person}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlidableAutoCloseBehavior(
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        children: getListItems(context),
      ),
    );
  }

  List<Widget> getListItems(BuildContext context) {
    List<Amount> amounts = Data.amounts;
    if (person == null) {
      return [
        PeopleChart(people: Data.people),
      ];
    }
    final List<Tile> paidAmounts = amounts
        .where((amount) => amount.paidDate != null)
        .map((amount) => EntityTile.amountTile(amount))
        .toList();
    final paidUpExpansionTile = GroupTile(
      title: "PAID AMOUNTS",
      subtitle: "Paid amounts",
      innerTiles: paidAmounts,
    );

    final List<Tile> unpaidAmounts = amounts
        .where((amount) => amount.paidDate == null)
        .map((amount) => EntityTile.amountTile(amount))
        .toList();
    final Iterable<Tile> groups = [paidUpExpansionTile]
        .where((group) => group.innerTiles.isNotEmpty)
        .toList();

    List<Tile> comboList = <Tile>[];
    comboList.addAll(unpaidAmounts);
    comboList.addAll(groups);

    return comboList.map((t) => buildTile(context, t)).toList();
  }

  Widget buildTile(BuildContext context, Tile tile,
      {double subTileIndentation = 10.0}) {
    if (tile is EntityTile<Amount>) {
      return AmountWidget(
          amount: tile.object, titleLeftPad: subTileIndentation);
    }

    final group = tile as GroupTile;
    return Card(
      child: ExpansionTile(
        backgroundColor: Colors.blue[50] ?? Colors.lightBlue,
        tilePadding: EdgeInsets.only(left: subTileIndentation),
        title: Text(group.title),
        subtitle: Text(group.subtitle,
            maxLines: 1, style: const TextStyle(color: Colors.blueGrey)),
        children: (group)
            .innerTiles
            .map((subTile) => buildTile(context, subTile,
                subTileIndentation: max(25.0, 2 * subTileIndentation)))
            .toList(),
      ),
    );
  }
}
