import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../component/add_form.dart';
import '../model/data.dart';
import '../model/person.dart';

class MasterPersonWidget extends StatelessWidget {
  final Person person;
  final bool isSelected;
  final double titleLeftPad;
  final void Function(Person) onTappedPerson;
  final void Function(Person) onPersonDeleted;
  const MasterPersonWidget(
      {Key? key,
      required this.person,
      required this.isSelected,
      required this.titleLeftPad,
      required this.onTappedPerson,
      required this.onPersonDeleted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maybeSelectionColor = isSelected ? Colors.blue[100] : null;
    return Card(
      color: maybeSelectionColor, // Colors.lightBlueAccent;,
      child: Slidable(
        key: ValueKey(person.objectId),
        closeOnScroll: true,
        groupTag: 'person',
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          dragDismissible: false,
          children: [
            SlidableAction(
              onPressed: (BuildContext context) =>
                  deletePerson(context, person),
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
          subtitle: Text(person.moneyFormattedTotal(),
              maxLines: 1, style: const TextStyle(color: Colors.blueGrey)),
          onTap: () => onTappedPerson(person),
        ),
      ),
    );
  }

  void deletePerson(BuildContext context, Person person) {
    Data.people.removeWhere((p) => p.id == person.id);
    onPersonDeleted(person);
  }

  void addAmount(BuildContext context, Person person) async {
    showBottomSheet(
      elevation: 3,
      context: context,
      enableDrag: true,
      builder: (context) => AddAmountForm(person: person),
    );
  }
}
