import 'package:money_link/model/amount.dart';
import 'package:money_link/model/base_model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Person extends BaseModel {
  @Id()
  int id;
  String fullName;
  @Property(type: PropertyType.date)
  DateTime created = DateTime.now();

  @Backlink('person')
  final amounts = ToMany<Amount>();

  Person({this.id = 0, this.fullName = ""}) : super(id);

  double owingTotal() {
    return amounts.fold(0, (sum, amount) => sum + amount.balance());
  }

  String moneyFormattedOwingTotal() {
    return "R ${owingTotal()}";
  }

  double paidTotal() {
    return amounts.fold(0, (sum, amount) => sum + amount.paidTotal());
  }

  String moneyFormattedPaidTotal() {
    return "R ${paidTotal()}";
  }

  List<String> names() => fullName.split(" ");
  String firstName() => names().first;
  String lastName() => names().last;

  @override
  String dialogTitle() => firstName();
}
