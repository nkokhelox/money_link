import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_link/objectbox.dart';

import '../model/person.dart';
import 'value_form.dart';

class PersonWidget extends StatelessWidget {
  final Person person;
  final bool isSelected;
  final double titleLeftPad;
  final VoidCallback refreshPeople;
  final void Function(Person) onTappedPerson;
  final void Function(Person) onPersonDeleted;
  const PersonWidget({
    Key? key,
    required this.person,
    required this.isSelected,
    required this.titleLeftPad,
    required this.onTappedPerson,
    required this.onPersonDeleted,
    required this.refreshPeople,
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
        startActionPane: person.total() != 0.0
            ? null
            : ActionPane(
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
          trailing: const Icon(CupertinoIcons.chevron_right),
          contentPadding: EdgeInsets.only(left: titleLeftPad),
          title: Text(person.fullName),
          subtitle: Text(person.moneyFormattedTotal(), maxLines: 1, style: const TextStyle(color: Colors.blueGrey, fontSize: 10)),
          onTap: () => onTappedPerson(person),
        ),
      ),
    );
  }

  void deletePerson(Person person) {
    ObjectBox.store.box<Person>().remove(person.id);
    onPersonDeleted(person);
  }

  void addAmount(BuildContext context, Person person) async {
    showDialog(context: context, builder: (context) => ValueForm(model: person, refreshFunction: refreshPeople));
  }
}
