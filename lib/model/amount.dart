import 'package:money_link/extensions.dart';
import 'package:money_link/model/base_model.dart';
import 'package:money_link/model/payment.dart';
import 'package:money_link/model/person.dart';
import 'package:objectbox/objectbox.dart';

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

    if (paidDate == null) {
      return "Balance: ${moneyBalance()} - $note";
    }

    return "Paid: ${moneyPaidTotal()} - $note";
  }

  details() {
    if (paidDate == null) {
      return """Not paid yet
Value: ${moneyValue()}
Balance: ${moneyBalance()}
Created: ${created.niceDescription(suffix: " ago")}
Note: $note""";
    }
    return """Value: ${moneyValue()}
PaidTotal: ${moneyPaidTotal()}
Created: ${created.niceDescription(suffix: " ago")}
Paid: ${paidDate?.niceDescription(suffix: " ago")}
Note: $note""";
  }

  @override
  String dialogTitle() => "Amount ${moneyValue()}";

  double balance() {
    if (paidDate == null) {
      return value -
          payments.fold<double>(0.0, (sum, payment) => sum + payment.value);
    }
    return 0;
  }

  double paidTotal() {
    if (paidDate != null) {
      double repaymentsTotal = payments
          .where((payment) => payment.value > 0)
          .fold<double>(0.0, (sum, payment) => sum + payment.value);
      if (repaymentsTotal == 0) {
        return value;
      }
      return repaymentsTotal;
    }
    return 0;
  }

  String moneyBalance() => "R ${balance()}";
  String moneyPaidTotal() => "R ${paidTotal()}";
}
