import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'model/person.dart';

class PeopleChart extends StatelessWidget {
  static var chartColors = const [
    Colors.redAccent,
    Colors.indigoAccent,
    Colors.orangeAccent,
    Colors.blueGrey,
    Colors.yellowAccent,
    Colors.grey,
    Colors.greenAccent,
    Colors.blueAccent,
  ];

  static Color getColor(int index) {
    return chartColors[index % chartColors.length];
  }

  const PeopleChart({Key? key, required this.people}) : super(key: key);
  final List<Person> people;

  double getTotalSum() {
    return people.isEmpty ? 0.0 : people.map((p) => p.total().abs()).reduce((sum, value) => sum + value);
  }

  @override
  Widget build(BuildContext context) {
    final double total = getTotalSum();
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
            letterSpacing: 4,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => Container(
        padding: const EdgeInsets.all(5),
        height: constraints.maxWidth,
        width: constraints.maxWidth,
        child: Center(
          child: PieChart(
            PieChartData(
              borderData: FlBorderData(show: false),
              sectionsSpace: 0,
              centerSpaceRadius: constraints.maxWidth / 5,
              sections: getSections(context, constraints, total),
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> getSections(BuildContext context, BoxConstraints constraints, double total) {
    return people
        .asMap()
        .entries
        .map((entry) => PieChartSectionData(
              color: PeopleChart.getColor(entry.key),
              title: "${entry.value.firstName()} (${percentage(total, entry.value.total())}%)",
              value: entry.value.total().abs(),
              radius: constraints.maxWidth / 5,
            ))
        .toList();
  }

  String percentage(double sum, double value) {
    return ((value / sum) * 100).toStringAsFixed(2);
  }
}
