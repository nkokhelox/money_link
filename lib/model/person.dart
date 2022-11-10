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

  double balance() {
    return amounts.fold(0, (sum, amount) => sum + amount.balance());
  }

  double grandOwingTotal() {
    return amounts.fold(0, (sum, amount) => sum + amount.owingTotal());
  }

  double owingTotal() {
    return amounts
        .where((amount) => amount.paidDate == null)
        .fold(0, (sum, amount) => sum + amount.owingTotal());
  }

  double grandPaidTotal() {
    return amounts.fold(0, (sum, amount) => sum + amount.paidTotal());
  }

  double paidTotal() {
    return amounts
        .where((amount) => amount.paidDate == null)
        .fold(0, (sum, amount) => sum + amount.paidTotal());
  }

  double grandGivenTotal() {
    return amounts.fold(0, (sum, amount) => sum + amount.value);
  }

  double givenTotal() {
    return amounts
        .where((amount) => amount.paidDate == null)
        .fold(0, (sum, amount) => sum + amount.value);
  }

  List<String> names() => fullName.split(" ");
  String firstName() => names().first;
  String lastName() => names().last;

  @override
  String dialogTitle() => firstName();
}
