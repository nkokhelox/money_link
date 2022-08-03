import 'package:flutter/material.dart';
import 'package:money_link/model/person.dart';
import 'package:money_link/objectbox.dart';

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

  PeopleChart({super.key}) {
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
                  .map((p) => p.total().abs())
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
                    letterSpacing: 2),
              ),
            );
          }

          final sortedPeople = people;
          sortedPeople.sort((p1, p2) =>
              Comparable.compare(p2.total().abs(), p1.total().abs()));

          return LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: peopleChart(context, sortedPeople,
                  maxBarWidth: constraints.maxWidth, peopleTotalSum: total),
            ),
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
        personTotal: person.total().abs(),
        peopleTotal: peopleTotalSum,
        maxBarWidth: maxBarWidth);
    return Wrap(
      direction: Axis.vertical,
      children: [
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              color: person.total() == 0 ? null : barColor),
          width: person.total() == 0 ? maxBarWidth : barWidthValue,
          height: 20,
        ),
        const Divider(height: 3),
        Row(
          children: [
            Icon(Icons.account_circle,
                color: person.total() == 0 ? Colors.blueGrey : barColor,
                size: 15),
            Icon(Icons.arrow_forward_sharp,
                color: person.total() == 0 ? Colors.blueGrey : barColor,
                size: 15),
            Text(
              " ${person.fullName} (${percentage(peopleTotalSum, person.total())}%)",
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

  List<Widget> peopleChart(BuildContext context, List<Person> sortedPeople,
      {required double maxBarWidth, required double peopleTotalSum}) {
    final List<Widget> content = <Widget>[];
    content.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("R 0", style: TextStyle(color: Colors.blueGrey)),
          Text("R ${peopleTotalSum / 2}",
              style: TextStyle(color: Colors.blueGrey)),
          Text("R $peopleTotalSum", style: TextStyle(color: Colors.blueGrey)),
        ],
      ),
    );

    final borderColor = Colors.blueGrey;

    content.add(Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(width: 1.0, color: borderColor),
          right: BorderSide(width: 1.0, color: borderColor),
          bottom: BorderSide(width: 1.0, color: borderColor),
        ),
      ),
      width: maxBarWidth,
      height: 10,
      alignment: Alignment.center,
      child: Container(width: 1, height: 10, color: borderColor),
    ));

    content.add(Container(height: 10));

    final bars = sortedPeople
        .asMap()
        .entries
        .map((e) => personBar(PeopleChart.getBarColors(e.key), e.value,
            maxBarWidth: maxBarWidth, peopleTotalSum: peopleTotalSum))
        .toList();

    content.addAll(bars);

    return content;
  }
}
