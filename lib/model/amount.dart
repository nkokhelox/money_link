import 'package:money_link/extensions.dart';
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
  @Property(type: PropertyType.date)
  DateTime? paidDate;
  @Property(type: PropertyType.date)
  DateTime created = DateTime.now();

  Amount({this.id = 0, this.value = 0, this.note = ""}) : super(id);

  final person = ToOne<Person>();

  @Backlink('amount')
  final payments = ToMany<Payment>();

  String moneyValue() => "R $value";

  highlight() {
    if (value == balance()) {
      return "${created.niceDescription()} - $note";
    }
    return "Balance: ${moneyBalance()} - $note";
  }

  details() {
    return """
    Value: ${moneyValue()}
    Balance: ${moneyBalance()}
    Created: ${created.niceDescription()}
    ${paidDate == null ? "Not paid" : "Paid: ${paidDate?.niceDescription(suffix: " ago")}"}
    Note: $note
    """;
  }

  @override
  String dialogTitle() => "Amount ${moneyValue()}";

  double balance() {
    if (paidDate == null) {
      return value - payments.fold<double>(0.0, (sum, payment) => sum + payment.value);
    }
    return 0;
  }

  String moneyBalance() => "R ${balance()}";
}
