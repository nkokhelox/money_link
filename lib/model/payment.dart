import 'package:money_link/extensions.dart';
import 'package:money_link/model/amount.dart';
import 'package:money_link/model/base_model.dart';
import 'package:objectbox/objectbox.dart';

import '../util.dart';

@Entity()
class Payment extends BaseModel {
  @Id()
  int id;
  double value;
  String note;
  @Property(type: PropertyType.date)
  DateTime created = DateTime.now();

  Payment({this.id = 0, this.value = 0, this.note = ""}) : super(id);

  final amount = ToOne<Amount>();

  highlight() {
    return "${created.niceDescription()} - $note";
  }

  details() {
    return """
    Payment for: ${Util.moneyFormat(amount.target?.value)}
    Value: ${Util.moneyFormat(value)}
    Created: ${created.niceDescription(suffix: " ago")}
    Note: $note
    """;
  }

  @override
  String dialogTitle() => "Payment ${Util.moneyFormat(value)}";
}
