import 'package:money_link/model/person.dart';
import 'package:objectbox/objectbox.dart';

import 'base_model.dart';

@Entity()
class Amount extends Model {
  @Id()
  final int id;
  final double value;
  final String note;
  DateTime? paidDate;
  final DateTime created = DateTime.now();

  Amount({this.id = 0, required this.value, required this.note}) : super(objectId: id);

  final person = ToOne<Person>();

  bool matchQuery(String query) {
    return note.contains(query) || value.toString().contains(query);
  }

  String moneyValue() => "R $value";

  highlight() {
    return "$created - $note";
  }

  details() {
    return """
    Value: ${moneyValue()}
    Created: $created
    ${paidDate == null ? "Not paid" : "Paid: $paidDate"}
    Note: $note
    """;
  }
}
