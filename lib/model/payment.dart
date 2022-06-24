import 'package:objectbox/objectbox.dart';

import 'amount.dart';
import 'base_model.dart';

@Entity()
class Payment extends BaseModel {
  @Id()
  int id;
  double value;
  String note;
  final DateTime created = DateTime.now();

  Payment({this.id = 0, this.value = 0, this.note = ""}) : super(id);

  final amount = ToOne<Amount>();

  bool matchQuery(String query) {
    return note.contains(query) || value.toString().contains(query);
  }

  String moneyValue() => "R $value";

  highlight() {
    return "$created - $note";
  }

  details() {
    return """
    Payment for: ${amount.target?.moneyValue()}
    Value: ${moneyValue()}
    Created: $created
    Note: $note
    """;
  }

  String dialogTitle() => "Payment ${moneyValue()}";
}
