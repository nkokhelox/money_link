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
import '../util.dart';

class AmountsPage extends StatelessWidget {
  final bool appBarHidden;
  final Person? selectedPerson;
  final VoidCallback refreshPeople;
  final ScrollController _scrollController = ScrollController();

  late Stream<List<Amount>> _amountStream;

  AmountsPage(
      {super.key,
      required this.selectedPerson,
      required this.appBarHidden,
      required this.refreshPeople}) {
    _amountStream = _personAmountsQuery();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Amount>>(
      initialData: const <Amount>[],
      stream: _amountStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (selectedPerson == null) {
            return Scaffold(
              appBar: appBarHidden
                  ? null
                  : AppBar(
                      title: Text(
                        "AMOUNTS CHART",
                        style: const TextStyle(letterSpacing: 4),
                      ),
                    ),
              body: _chart(),
            );
          }
          if (appBarHidden) {
            return Scaffold(
              body: _body(context, snapshot.data ?? <Amount>[]),
            );
          }
          return Scaffold(
              body: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _sliverAppBar(context, snapshot.data ?? <Amount>[]),
                  _body(context, snapshot.data ?? <Amount>[]),
                ],
              ),
              floatingActionButton: _fab(context));
        }

        return ErrorWidget(snapshot.error ?? "Something went wrong :(");
      },
    );
  }

  FloatingActionButton? _fab(BuildContext context) {
    if (this.selectedPerson == null) {
      return null;
    }
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () => addAmount(context),
    );
  }

  Widget _chart() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: PeopleChart(scrollController: _scrollController),
    );
  }

  Widget _body(BuildContext context, List<Amount> amounts) {
    if (appBarHidden) {
      return SlidableAutoCloseBehavior(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: const BouncingScrollPhysics(),
          ),
          children: _getListItems(context, amounts),
        ),
      );
    }

    return SlidableAutoCloseBehavior(
      child: SliverList(
        delegate: SliverChildListDelegate(_getListItems(context, amounts)),
      ),
    );
  }

  Widget _sliverAppBar(BuildContext context, List<Amount> amounts) {
    Color? expandedTextColor =
        Theme.of(context).brightness == Brightness.dark ? null : Colors.white;
    return SliverAppBar(
      expandedHeight: 245,
      title: InkWell(
        onLongPress: _jumpToTop,
        child: Text(
          selectedPerson?.fullName ?? "AMOUNTS CHART",
          style: const TextStyle(letterSpacing: 4),
        ),
      ),
      stretch: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0),
          child: selectedPerson == null
              ? Text("Chart")
              : Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Divider(),
                    Text(
                      "Grand Total Given: ${grandGivenTotal(amounts)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: expandedTextColor,
                        letterSpacing: 2,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      "Grand Total Paid: ${grandPaidTotal(amounts)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: expandedTextColor,
                        letterSpacing: 2,
                        fontSize: 10,
                      ),
                    ),
                    Divider(),
                    Text(
                      "Total Given",
                      style: TextStyle(
                        color: expandedTextColor,
                        letterSpacing: 2,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      unpaidGivenTotal(amounts),
                      style: TextStyle(
                        color: expandedTextColor,
                        letterSpacing: 2,
                        fontSize: 12,
                      ),
                    ),
                    Divider(),
                    Text(
                      "Total Repaid",
                      style: TextStyle(
                        color: expandedTextColor,
                        letterSpacing: 2,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      repaidTotal(amounts),
                      style: TextStyle(
                        color: expandedTextColor,
                        letterSpacing: 2,
                        fontSize: 12,
                      ),
                    ),
                    Divider(),
                    Text(
                      "Total Owing",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: expandedTextColor,
                        letterSpacing: 2,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      totalBalance(amounts),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: expandedTextColor,
                        letterSpacing: 2,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  List<Widget> _getListItems(BuildContext context, List<Amount> amounts) {
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

    final paidAmounts =
        amounts.where((amount) => amount.paidDate != null).toList();

    paidAmounts.sort((a, b) {
      int dateA = a.paidDate?.microsecondsSinceEpoch ?? 0;
      int dateB = b.paidDate?.microsecondsSinceEpoch ?? 0;
      return dateB.compareTo(dateA);
    });

    final paidUpExpansionTile = GroupTile(
      title: "PAID AMOUNTS",
      subtitle: Util.moneyFormat(paidAmounts.fold<double>(
          0.0, (sum, amount) => sum + amount.paidTotal())),
      innerTiles:
          paidAmounts.map((amount) => EntityTile.amountTile(amount)).toList(),
    );

    final List<Tile> unpaidAmounts = amounts
        .where((amount) => amount.paidDate == null)
        .map((amount) => EntityTile.amountTile(amount))
        .toList();

    final Iterable<Tile> groups = [paidUpExpansionTile]
        .where((group) => group.innerTiles.isNotEmpty)
        .toList();

    List<Widget> comboList = <Widget>[];
    comboList
        .addAll(unpaidAmounts.map((et) => _buildTile(context, et)).toList());
    comboList.addAll(groups.map((gt) => _buildTile(context, gt)).toList());

    return comboList;
  }

  Widget _buildTile(BuildContext context, Tile tile,
      {double subTileIndentation = 10.0}) {
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
        title: Text(group.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(group.subtitle, maxLines: 1),
        children: (group)
            .innerTiles
            .map((subTile) => _buildTile(context, subTile,
                subTileIndentation: 2 * subTileIndentation))
            .toList(),
      ),
    );
  }

  Stream<List<Amount>> _personAmountsQuery() {
    var queryBuilder = ObjectBox.store.box<Amount>().query();
    queryBuilder.link(
        Amount_.person, Person_.id.equals(selectedPerson?.id ?? 0));
    return queryBuilder.watch(triggerImmediately: true).map((q) => q.find());
  }

  void _jumpToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
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
        builder: (context) =>
            ValueForm(model: person, refreshFunction: refreshAmountStream),
      );
    }
  }

  String unpaidGivenTotal(List<Amount> amounts) {
    return Util.moneyFormat(
      amounts
          .where((amt) => amt.paidDate == null)
          .fold<double>(0.0, (sum, amt) => sum + amt.value),
    );
  }

  String repaidTotal(List<Amount> amounts) {
    return Util.moneyFormat(
      amounts
          .where((amt) => amt.paidDate == null)
          .fold<double>(0.0, (sum, amt) => sum + amt.paidTotal()),
    );
  }

  String totalBalance(List<Amount> amounts) {
    return Util.moneyFormat(
      amounts.fold<double>(0.0, (sum, amt) => sum + amt.balance()),
    );
  }

  String grandGivenTotal(List<Amount> amounts) {
    return Util.moneyFormat(
      amounts.fold<double>(0.0, (sum, amt) => sum + amt.value),
    );
  }

  String grandPaidTotal(List<Amount> amounts) {
    return Util.moneyFormat(
      amounts.fold<double>(0.0, (sum, amt) => sum + amt.paidTotal()),
    );
  }

  String balancePercentage(List<Amount> amounts) {
    double balance =
        amounts.fold<double>(0.0, (sum, amt) => sum + amt.balance());
    double givenTotal = amounts
        .where((amt) => amt.paidDate != null)
        .fold<double>(0.0, (sum, amt) => sum + amt.value);
    return Util.percentage(balance, givenTotal);
  }
}
