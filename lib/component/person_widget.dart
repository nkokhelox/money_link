import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_link/component/value_form.dart';
import 'package:money_link/model/person.dart';
import 'package:money_link/objectbox.dart';

import '../util.dart';

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
    final maybeSelectionColor =
        isSelected ? Theme.of(context).selectedRowColor : null;
    return Card(
      color: maybeSelectionColor,
      child: Slidable(
        key: ValueKey(person.id),
        closeOnScroll: true,
        groupTag: 'person',
        startActionPane: person.owingTotal() != 0.0
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
        child: ListTile(
          trailing: const Icon(Icons.chevron_right),
          contentPadding: EdgeInsets.only(left: titleLeftPad),
          title: Text(person.fullName),
          subtitle: Text(
            Util.moneyFormat(
              person.balance() == 0
                  ? person.grandPaidTotal()
                  : person.balance(),
            ),
            maxLines: 1,
            style: TextStyle(fontSize: 10),
          ),
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
    showDialog(
        context: context,
        builder: (context) =>
            ValueForm(model: person, refreshFunction: refreshPeople));
  }
}
