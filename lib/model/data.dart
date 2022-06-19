import 'package:money_link/model/person.dart';

import 'amount.dart';

class Data {
  static final List<Amount> amounts = [
    Amount(id: 10, value: 100, note: 'Foo'),
    Amount(id: 20, value: 200, note: 'Bar'),
    Amount(id: 30, value: 300, note: 'FooBar'),
    Amount(id: 10, value: -1001, note: 'Foo'),
    Amount(id: 20, value: -2002, note: 'Bar'),
    Amount(id: 30, value: -3003, note: 'FooBar'),
    Amount(id: 40, value: 400, note: 'Foo'),
    Amount(id: 50, value: 500, note: 'Bar'),
    Amount(id: 60, value: 600, note: 'FooBar'),
    Amount(id: 70, value: 700, note: 'Foo'),
    Amount(id: 80, value: 800, note: 'Bar'),
    Amount(id: 90, value: 900, note: 'FooBar'),
  ];

  static final List<Person> people = [
    Person(id: 1, fullName: 'Sipho Ndawonde'),
    Person(id: 2, fullName: 'Ntombile Catherine Mhlongo'),
    Person(id: 3, fullName: 'Nkokhelo Emmanuel Siyabonga Mhlongo'),
    Person(id: 4, fullName: 'Samkelisiwe Fortunate Mhlongo'),
    Person(id: 5, fullName: 'Lonathemba Zekhethelo Mhlongo'),
    Person(id: 6, fullName: 'Hlelolwenkosi Zibusiso Mhlongo'),
    Person(id: 7, fullName: 'Foo Bar'),
  ];
}
