import 'package:money_link/model/payment.dart';
import 'package:money_link/model/person.dart';
import 'package:objectbox/objectbox.dart';

import 'base_model.dart';

@Entity()
class Amount extends BaseModel {
  @Id()
  int id;
  double value;
  String note;
  DateTime? paidDate;
  final DateTime created = DateTime.now();

  Amount({this.id = 0, this.value = 0, this.note = ""}) : super(id);

  final person = ToOne<Person>();

  @Backlink('amount')
  final payments = ToMany<Payment>();

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
