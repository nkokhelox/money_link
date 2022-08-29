import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_link/component/amount_widget.dart';
import 'package:money_link/component/people_chart.dart';
import 'package:money_link/model/amount.dart';
import 'package:money_link/model/person.dart';
import 'package:money_link/model/tile.dart';
import 'package:money_link/objectbox.dart';
import 'package:money_link/objectbox.g.dart';

import '../component/value_form.dart';

class AmountsPage extends StatelessWidget {
  final bool appBarHidden;
  final Person? selectedPerson;
  final VoidCallback refreshPeople;
  final ScrollController _scrollController = ScrollController();

  late Stream<List<Amount>> _amountStream;

  AmountsPage({super.key, required this.selectedPerson, required this.appBarHidden, required this.refreshPeople}) {
    _amountStream = _personAmountsQuery();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Amount>>(
      initialData: const <Amount>[],
      stream: _amountStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: appBarHidden
                ? null
                : AppBar(
                    title: InkWell(
                      onTap: _jumpToTop,
                      child: Text(selectedPerson?.fullName ?? "AMOUNTS", style: const TextStyle(letterSpacing: 4)),
                    ),
                  ),
            body: SlidableAutoCloseBehavior(
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(parent: const BouncingScrollPhysics()),
                children: _getListItems(context, snapshot.data ?? <Amount>[]),
              ),
            ),
            floatingActionButton: this.selectedPerson == null
                ? null
                : FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => addAmount(context),
                  ),
          );
        }

        return ErrorWidget(snapshot.error ?? "Something went wrong :(");
      },
    );
  }

  List<Widget> _getListItems(BuildContext context, List<Amount> amounts) {
    if (selectedPerson == null) {
      return [
        Padding(
          padding: const EdgeInsets.all(5),
          child: PeopleChart(),
        ),
      ];
    }

    if (amounts.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(10),
          child: Text(
            "${selectedPerson!.firstName()} has a clean slate",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 16,
            ),
          ),
        ),
      ];
    }

    final paidAmounts = amounts.where((amount) => amount.paidDate != null);
    final paidUpExpansionTile = GroupTile(
      title: "PAID AMOUNTS",
      subtitle: "R ${paidAmounts.fold<double>(0.0, (sum, amount) => sum + amount.paidTotal())}",
      innerTiles: paidAmounts.map((amount) => EntityTile.amountTile(amount)).toList(),
    );

    final List<Tile> unpaidAmounts = amounts.where((amount) => amount.paidDate == null).map((amount) => EntityTile.amountTile(amount)).toList();
    final Iterable<Tile> groups = [paidUpExpansionTile].where((group) => group.innerTiles.isNotEmpty).toList();

    List<Widget> comboList = <Widget>[];
    comboList.addAll(unpaidAmounts.map((et) => _buildTile(context, et)).toList());
    comboList.addAll(groups.map((gt) => _buildTile(context, gt)).toList());

    return comboList;
  }

  Widget _buildTile(BuildContext context, Tile tile, {double subTileIndentation = 10.0}) {
    if (tile is EntityTile<Amount>) {
      return AmountWidget(
        amount: tile.object,
        refreshPeople: refreshPeople,
        refreshAmounts: refreshAmountStream,
        titleLeftPad: subTileIndentation,
      );
    }

    final group = tile as GroupTile;
    return Card(
      child: ExpansionTile(
        tilePadding: EdgeInsets.only(left: subTileIndentation),
        title: Text(group.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(group.subtitle, maxLines: 1),
        children: (group).innerTiles.map((subTile) => _buildTile(context, subTile, subTileIndentation: 2 * subTileIndentation)).toList(),
      ),
    );
  }

  Stream<List<Amount>> _personAmountsQuery() {
    var queryBuilder = ObjectBox.store.box<Amount>().query();
    queryBuilder.link(Amount_.person, Person_.id.equals(selectedPerson?.id ?? 0));
    return queryBuilder.watch(triggerImmediately: true).map((q) => q.find());
  }

  void _jumpToTop() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void refreshAmountStream() {
    _amountStream = _personAmountsQuery();
    refreshPeople();
  }

  void addAmount(BuildContext context) async {
    var person = this.selectedPerson;
    if (person != null) {
      showDialog(
        context: context,
        builder: (context) => ValueForm(model: person, refreshFunction: refreshAmountStream),
      );
    }
  }
}
