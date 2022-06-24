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

  String moneyValue() => "R $value";

  highlight() {
    if (value == difference()) {
      return "$created - $note";
    }
    return "Balance: ${moneyBalance()} - $note";
  }

  details() {
    return """
    Value: ${moneyValue()}
    Balance: ${moneyBalance()}
    Created: $created
    ${paidDate == null ? "Not paid" : "Paid: $paidDate"}
    Note: $note
    """;
  }

  @override
  String dialogTitle() => "Amount ${moneyValue()}";

  double difference() => value - payments.fold(0.0, (sum, payment) => sum + payment.value);

  String moneyBalance() => "R ${difference()}";
}
