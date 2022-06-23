import 'package:money_link/model/amount.dart';
import 'package:money_link/model/base_model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Person extends BaseModel {
  @Id()
  int id;
  String fullName;
  DateTime created = DateTime.now();

  @Backlink('person')
  final amounts = ToMany<Amount>();

  Person({this.id = 0, this.fullName = ""}) : super(id);

  double total() {
    return amounts.fold(0, (sum, amount) => sum + amount.value);
  }

  String moneyFormattedTotal() {
    return "R ${total()}";
  }

  List<String> names() => fullName.split(" ");
  String firstName() => names().first;
  String lastName() => names().last;

  bool matchQuery(NameSearch search) {
    var query = search.query;
    if (query.isEmpty) {
      return false;
    }
    if (search is LenientMatch) {
      var queryParts = query.split(" ");
      var matches = queryParts.map((q) => names().where((n) => n.toLowerCase().startsWith(q.toLowerCase())).isNotEmpty);
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
