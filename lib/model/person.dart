import 'package:money_link/model/amount.dart';
import 'package:objectbox/objectbox.dart';

import 'base_model.dart';

@Entity()
class Person extends Model {
  @Id()
  final int id;
  final String fullName;
  final DateTime created = DateTime.now();
  late final List<String> names;
  Person({this.id = 0, required this.fullName}) : super(objectId: id) {
    names = fullName.split(" ").toList(growable: false);
  }

  @Backlink('amount')
  final amounts = ToMany<Amount>();

  double total() {
    return amounts.fold(0, (sum, amount) => sum + amount.value);
  }

  String moneyFormattedTotal() {
    return "R ${total()}";
  }

  String firstName() => names.first;
  String lastName() => names.last;

  bool matchQuery(NameSearch search) {
    var query = search.query;
    if (query.isEmpty) {
      return false;
    }
    if (search is LenientMatch) {
      var queryParts = query.split(" ");
      var matches = queryParts.map((q) => names.where((n) => n.toLowerCase().startsWith(q.toLowerCase())).isNotEmpty);
      return matches.every((e) => e);
    }

    return fullName.startsWith(query);
  }
}

abstract class NameSearch {
  String query;
  NameSearch(this.query);
}

class StrictMatch extends NameSearch {
  StrictMatch(query) : super(query);
}

class LenientMatch extends NameSearch {
  LenientMatch(query) : super(query);
}
