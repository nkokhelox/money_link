import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_link/chart.dart';
import 'package:money_link/model/person.dart';

import 'component/amount_widget.dart';
import 'model/amount.dart';
import 'model/data.dart';
import 'model/tile.dart';

class AmountDetailPage extends StatelessWidget {
  final Person? person;
  const AmountDetailPage({Key? key, required this.person}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (_) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: InkWell(
            onTap: () => jumpToTop(scrollController),
            child: Center(child: Text(person?.fullName ?? "AMOUNTS")),
          ),
        ),
        body: SlidableAutoCloseBehavior(
          child: ListView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: getListItems(context),
          ),
        ),
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
    final List<Tile> paidAmounts = amounts.where((a) => a.paidDate != null).map((a) => EntityTile.amountTile(a)).toList();
    final paidUpExpansionTile = GroupTile(
      title: "PAID AMOUNTS",
      subtitle: "Paid amounts",
      innerTiles: paidAmounts,
    );

    final List<Tile> unpaidAmounts = amounts.where((a) => a.paidDate == null).map((a) => EntityTile.amountTile(a)).toList();
    final Iterable<Tile> groups = [paidUpExpansionTile].where((group) => group.innerTiles.isNotEmpty).toList();

    List<Tile> comboList = <Tile>[];
    comboList.addAll(unpaidAmounts);
    comboList.addAll(groups);

    return comboList.map((t) => buildTile(context, t)).toList();
  }

  Widget buildTile(BuildContext context, Tile tile, {double subTileIndentation = 10.0}) {
    if (tile is EntityTile<Amount>) {
      return AmountWidget(amount: tile.object, titleLeftPad: subTileIndentation);
    }

    final group = tile as GroupTile;
    return Card(
      child: ExpansionTile(
        backgroundColor: Colors.blue[50] ?? Colors.lightBlue,
        tilePadding: EdgeInsets.only(left: subTileIndentation),
        title: Text(group.title),
        subtitle: Text(group.subtitle, maxLines: 1, style: const TextStyle(color: Colors.blueGrey)),
        children: (group).innerTiles.map((subTile) => buildTile(context, subTile, subTileIndentation: max(25.0, 2 * subTileIndentation))).toList(),
      ),
    );
  }

  void jumpToTop(ScrollController scrollController) {
    scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }
}
