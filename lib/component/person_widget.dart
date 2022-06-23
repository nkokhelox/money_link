import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../model/person.dart';
import 'add_amount_form.dart';

class PersonWidget extends StatelessWidget {
  final Person person;
  final bool isSelected;
  final double titleLeftPad;
  final void Function(Person) onTappedPerson;
  final void Function(Person) onPersonDeleted;
  const PersonWidget({
    Key? key,
    required this.person,
    required this.isSelected,
    required this.titleLeftPad,
    required this.onTappedPerson,
    required this.onPersonDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maybeSelectionColor = isSelected ? Colors.blue[100] : null;
    return Card(
      color: maybeSelectionColor, // Colors.lightBlueAccent;,
      child: Slidable(
        key: ValueKey(person.id),
        closeOnScroll: true,
        groupTag: 'person',
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          dragDismissible: false,
          children: [
            SlidableAction(
              onPressed: (BuildContext context) => deletePerson(person),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              autoClose: true,
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          dragDismissible: false,
          children: [
            SlidableAction(
              onPressed: (context) => addAmount(context, person),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              icon: Icons.add,
              label: 'Amount',
              autoClose: true,
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.only(left: titleLeftPad),
          title: Text(person.fullName),
          subtitle: Text(person.moneyFormattedTotal(), maxLines: 1, style: const TextStyle(color: Colors.blueGrey)),
          onTap: () => onTappedPerson(person),
        ),
      ),
    );
  }

  void deletePerson(Person person) {
    //TODO: 1 - add a person into the DB.
    onPersonDeleted(person);
  }

  void addAmount(BuildContext context, Person person) async {
    showDialog(
      context: context,
      builder: (context) => AddAmountForm(person: person),
    );
  }
}
