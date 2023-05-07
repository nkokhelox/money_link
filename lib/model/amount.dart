import 'package:money_link/extensions.dart';
import 'package:money_link/model/base_model.dart';
import 'package:money_link/model/payment.dart';
import 'package:money_link/model/person.dart';
import 'package:objectbox/objectbox.dart';

import '../util.dart';

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

  highlight() {
    var balanceAmount = balance();
    if (value == balanceAmount) {
      return "${created.niceDescription()} - $note";
    }

    if (paidDate == null) {
      return "Balance: ${Util.moneyFormat(balanceAmount)} - $note";
    }

    var paymentsTotalAmount = paymentsTotal();
    var paidAmount = paidTotal();
    if (paymentsTotalAmount != 0 && paymentsTotalAmount != value) {
      var change = Util.moneyFormat(paymentsTotalAmount - value);
      if (paidAmount >= value) {
        return "Change: $change - $note";
      } else {
        var paidMoney = Util.moneyFormat(paymentsTotalAmount);
        return "Paid: $paidMoney [change: $change] - $note";
      }
    }
    return "Paid: ${Util.moneyFormat(paidAmount)} - $note";
  }

  @override
  String dialogTitle() => "Amount ${Util.moneyFormat(value)}";

  double balance() {
    return paidDate != null ? 0 : value - paymentsTotal();
  }

  double owingTotal() {
    return value +
        payments
            .where((payment) => payment.value < 0)
            .fold<double>(0.0, (sum, payment) => sum + payment.value)
            .abs();
  }

  double paidTotal() {
    return paidDate != null && payments.isEmpty
        ? value
        : payments
            .where((payment) => payment.value > 0)
            .fold<double>(0.0, (sum, payment) => sum + payment.value);
  }

  double paymentsTotal() {
    return payments.fold<double>(0.0, (sum, payment) => sum + payment.value);
  }
}
