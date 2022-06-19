import 'package:flutter/material.dart';

import '../model/data.dart';
import '../model/person.dart';
import 'add_amount_form.dart';

abstract class APerson extends StatelessWidget {
  final void Function(Person) onPersonDeleted;

  const APerson({Key? key, required this.onPersonDeleted}) : super(key: key);

  void deletePerson(BuildContext context, Person person) {
    Data.people.removeWhere((p) => p.id == person.id);
    onPersonDeleted(person);
  }

  void addAmount(BuildContext context, Person person) async {
    showDialog(
      context: context,
      builder: (context) => AddAmountForm(person: person),
    );
  }
}
