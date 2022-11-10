import 'package:flutter/material.dart';
import 'package:money_link/model/person.dart';
import 'package:money_link/objectbox.dart';

import '../util.dart';

class PeopleChart extends StatelessWidget {
  static var chartColors = const [
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];
  final _peopleBox = ObjectBox.store.box<Person>();

  late Stream<List<Person>> _peopleStream;
  final ScrollController scrollController;

  PeopleChart({super.key, required this.scrollController}) {
    _peopleStream =
        _peopleBox.query().watch(triggerImmediately: true).map((q) => q.find());
  }

  static Color getBarColors(int index) {
    return chartColors[index % chartColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Person>>(
      initialData: const <Person>[],
      stream: _peopleStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final people = snapshot.data ?? <Person>[];
          final double total = people.isEmpty
              ? 0.0
              : people
                  .map((p) => p.owingTotal().abs())
                  .reduce((sum, value) => sum + value);
          var hideChart = people.isEmpty || total == 0;

          if (hideChart) {
            return Container(
              padding: const EdgeInsets.all(10),
              child: Text(
                people.isEmpty ? "Add people" : "Add amounts",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
            );
          }

          final sortedPeople = people;
          sortedPeople.sort((p1, p2) =>
              Comparable.compare(p2.owingTotal().abs(), p1.owingTotal().abs()));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              peopleChartHeadingAmounts(context, sortedPeople, total),
              peopleChartHeadingLine(context, sortedPeople, total),
              Container(height: 10),
              Expanded(
                child: peopleChartBars(context, sortedPeople, total),
              ),
            ],
          );
        }

        return ErrorWidget(snapshot.error ?? "Something went wrong :(");
      },
    );
  }

  String percentage(double sum, double value) {
    return ((value / sum) * 100).toStringAsFixed(2);
  }

  double barWidth(
      {required double personTotal,
      required double peopleTotal,
      required double maxBarWidth}) {
    return maxBarWidth * (personTotal / peopleTotal);
  }

  Widget personBar(Color barColor, Person person,
      {required double maxBarWidth, required double peopleTotalSum}) {
    final barWidthValue = barWidth(
        personTotal: person.owingTotal().abs(),
        peopleTotal: peopleTotalSum,
        maxBarWidth: maxBarWidth);
    return Wrap(
      direction: Axis.vertical,
      children: [
        // InkWell(
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            color: person.owingTotal() == 0 ? null : barColor,
          ),
          width: person.owingTotal() == 0 ? maxBarWidth : barWidthValue,
          height: 20,
        ),
        const Divider(height: 3),
        Row(
          children: [
            Icon(
              Icons.account_circle,
              color: person.owingTotal() == 0 ? Colors.blueGrey : barColor,
              size: 15,
            ),
            Icon(
              Icons.arrow_forward_sharp,
              color: person.owingTotal() == 0 ? Colors.blueGrey : barColor,
              size: 15,
            ),
            Text(
              " ${person.fullName} (${percentage(peopleTotalSum, person.owingTotal())}%)",
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey),
            ),
          ],
        ),
        const Divider(height: 10),
      ],
    );
  }

  Widget peopleChartHeadingAmounts(
      BuildContext context, List<Person> sortedPeople, double peopleTotalSum) {
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            Util.moneyFormat(0.0),
            style: TextStyle(color: Colors.blueGrey),
          ),
          Text(
            Util.moneyFormat(peopleTotalSum / 2),
            style: TextStyle(color: Colors.blueGrey),
          ),
          Text(
            Util.moneyFormat(peopleTotalSum),
            style: TextStyle(color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  Widget peopleChartHeadingLine(
      BuildContext context, List<Person> sortedPeople, double peopleTotalSum) {
    final borderColor = Colors.blueGrey;

    return LayoutBuilder(
      builder: (context, constraints) => Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(width: 1.0, color: borderColor),
            right: BorderSide(width: 1.0, color: borderColor),
            bottom: BorderSide(width: 1.0, color: borderColor),
          ),
        ),
        width: constraints.maxWidth,
        height: 10,
        alignment: Alignment.center,
        child: Container(width: 1, height: 10, color: borderColor),
      ),
    );
  }

  Widget peopleChartBars(
      BuildContext context, List<Person> sortedPeople, double peopleTotalSum) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: const BouncingScrollPhysics(),
        ),
        controller: scrollController,
        shrinkWrap: true,
        children: sortedPeople
            .asMap()
            .entries
            .map((e) => personBar(PeopleChart.getBarColors(e.key), e.value,
                maxBarWidth: constraints.maxWidth,
                peopleTotalSum: peopleTotalSum))
            .toList(),
      ),
    );
  }
}
