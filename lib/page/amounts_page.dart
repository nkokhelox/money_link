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

class AmountsPage extends StatefulWidget {
  final bool appBarHidden;
  final Person? selectedPerson;
  final VoidCallback refreshPeople;
  final ScrollController _scrollController = ScrollController();
  late Stream<List<Amount>> _amountStream;

  AmountsPage({
    super.key,
    required this.selectedPerson,
    required this.appBarHidden,
    required this.refreshPeople,
  }) {
    _amountStream = _personAmountsQuery();
  }

  @override
  _AmountsPageState createState() => _AmountsPageState();

  Stream<List<Amount>> _personAmountsQuery() {
    var queryBuilder = ObjectBox.store.box<Amount>().query();
    queryBuilder.link(
      Amount_.person,
      Person_.id.equals(selectedPerson?.id ?? 0),
    );
    return queryBuilder.watch(triggerImmediately: true).map((q) => q.find());
  }

  void refreshAmountStream() {
    _amountStream = _personAmountsQuery();
    refreshPeople();
  }

  void addAmount(BuildContext context) async {
    var person = selectedPerson;
    if (person != null) {
      showDialog(
        context: context,
        builder: (context) => ValueForm(
          model: person,
          refreshFunction: refreshAmountStream,
        ),
      );
    }
  }
}

class _AmountsPageState extends State<AmountsPage> {
  var sorting = 0;
  var showPaidPeople = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Amount>>(
      initialData: const <Amount>[],
      stream: widget._amountStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (widget.selectedPerson == null) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: widget.appBarHidden
                  ? null
                  : AppBar(
                      title: Text(
                        "AMOUNTS CHART",
                        style: const TextStyle(letterSpacing: 4),
                      ),
                      actions: [
                        IconButton(
                          onPressed: togglePaidPeopleRow,
                          icon: showPaidPeople
                              ? Icon(Icons.account_balance_wallet)
                              : Icon(Icons.account_balance_wallet_outlined),
                          tooltip: showPaidPeople
                              ? "Hide people with 0.0%"
                              : "Show people with 0.0%",
                        ),
                      ],
                    ),
              body: _chart(),
            );
          }
          if (widget.appBarHidden) {
            return Scaffold(
              body: _body(context, snapshot.data ?? <Amount>[]),
            );
          }
          return Scaffold(
              body: CustomScrollView(
                controller: widget._scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: const BouncingScrollPhysics(),
                ),
                slivers: [
                  _sliverAppBar(context, snapshot.data ?? <Amount>[]),
                  _body(
                    context,
                    snapshot.data ?? <Amount>[],
                  ),
                ],
              ),
              floatingActionButton: _fab(context));
        }

        return ErrorWidget(snapshot.error ?? "Something went wrong :(");
      },
    );
  }

  Widget _sliverAppBar(BuildContext context, List<Amount> amounts) {
    return SliverAppBar(
      expandedHeight: 146,
      title: InkWell(
        onLongPress: _jumpToTop,
        child: Text(
          widget.selectedPerson?.fullName ?? "AMOUNTS CHART",
          style: const TextStyle(letterSpacing: 4),
        ),
      ),
      actions: [
        IconButton(
          onPressed: toggleSorting,
          icon: Icon(sortingIcon()),
          tooltip: "Sort by balance",
        ),
      ],
      stretch: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: widget.selectedPerson == null
            ? Text("Chart")
            : Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Divider(),
                  SelectableText(
                    "Total Balance: ${totalBalance(amounts)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 16,
                    ),
                  ),
                  SelectableText(
                    "Grand Total Given: ${grandGivenTotal(amounts)}",
                    style: TextStyle(
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),
                  SelectableText(
                    "Grand Total Paid: ${grandPaidTotal(amounts)}",
                    style: TextStyle(
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),
                  Divider(),
                ],
              ),
      ),
    );
  }

  String unpaidGivenTotal(List<Amount> amounts) {
    return Util.moneyFormat(
      amounts
          .where((amt) => amt.paidDate == null)
          .fold<double>(0.0, (sum, amt) => sum + amt.value),
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

  FloatingActionButton? _fab(BuildContext context) {
    if (widget.selectedPerson == null) {
      return null;
    }
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () => widget.addAmount(context),
    );
  }

  Widget _chart() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: PeopleChart(
        scrollController: widget._scrollController,
        showPaidPeople: showPaidPeople,
      ),
    );
  }

  Widget _body(BuildContext context, List<Amount> amounts) {
    if (widget.appBarHidden) {
      return SlidableAutoCloseBehavior(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          controller: widget._scrollController,
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

  List<Widget> _getListItems(BuildContext context, List<Amount> amounts) {
    if (amounts.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(10),
          child: Text(
            "${widget.selectedPerson!.firstName()} has a clean slate",
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
      title: "PAID AMOUNTS  (${paidAmounts.length})",
      subtitle: Util.moneyFormat(paidAmounts.fold<double>(
          0.0, (sum, amount) => sum + amount.paidTotal())),
      innerTiles:
          paidAmounts.map((amount) => EntityTile.amountTile(amount)).toList(),
    );

    final unpaidAmounts =
        amounts.where((amount) => amount.paidDate == null).toList();

    if (sorting != 0) {
      unpaidAmounts.sort((a, b) {
        switch (sorting) {
          case 1:
            return (a.balance()).compareTo(b.balance());
          case 2:
          default:
            return (b.balance()).compareTo(a.balance());
        }
      });
    }

    final List<Tile> unpaidAmountsTiles =
        unpaidAmounts.map((amount) => EntityTile.amountTile(amount)).toList();

    final Iterable<Tile> groups = [paidUpExpansionTile]
        .where((group) => group.innerTiles.isNotEmpty)
        .toList();

    List<Widget> comboList = <Widget>[];
    comboList.addAll(
        unpaidAmountsTiles.map((et) => _buildTile(context, et)).toList());
    comboList.addAll(groups.map((gt) => _buildTile(context, gt)).toList());

    return comboList;
  }

  Widget _buildTile(BuildContext context, Tile tile,
      {double subTileIndentation = 10.0}) {
    if (tile is EntityTile<Amount>) {
      return AmountWidget(
        amount: tile.object,
        refreshPeople: widget.refreshPeople,
        refreshAmounts: widget.refreshAmountStream,
        titleLeftPad: subTileIndentation,
      );
    }

    final group = tile as GroupTile;
    return Card(
      child: ExpansionTile(
        tilePadding: EdgeInsets.only(left: subTileIndentation),
        shape: Border.all(color: Colors.transparent, width: 0),
        title: Text(group.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(group.subtitle, maxLines: 1),
        children: (group)
            .innerTiles
            .map((subTile) => _buildTile(
                  context,
                  subTile,
                  subTileIndentation: 2 * subTileIndentation,
                ))
            .toList(),
      ),
    );
  }

  void _jumpToTop() {
    widget._scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  togglePaidPeopleRow() {
    setState(() {
      showPaidPeople = !showPaidPeople;
    });
  }

  toggleSorting() {
    setState(() {
      sorting = ++sorting % 3;
    });
  }

  sortingIcon() {
    switch (sorting) {
      case 1:
        return Icons.arrow_circle_down;
      case 2:
        return Icons.arrow_circle_up;
      default:
        return Icons.date_range;
    }
  }
}
