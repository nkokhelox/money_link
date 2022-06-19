import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../model/amount.dart';
import '../model/data.dart';

class AmountWidget extends StatelessWidget {
  final Amount amount;
  final double titleLeftPad;
  const AmountWidget({Key? key, required this.amount, this.titleLeftPad = 10}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Slidable(
        key: ValueKey(amount.objectId),
        closeOnScroll: true,
        groupTag: 'amount',
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          dragDismissible: false,
          children: [
            SlidableAction(
              onPressed: (BuildContext context) => deleteAmount(amount),
              backgroundColor: const Color(0xFFFE4A49),
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
              onPressed: (BuildContext context) => togglePaidStatus(amount),
              backgroundColor: amount.paidDate == null ? Colors.teal : Colors.orange,
              foregroundColor: Colors.white,
              icon: Icons.check_circle,
              label: amount.paidDate == null ? 'Paid' : 'Unpaid',
              autoClose: true,
            ),
          ],
        ),
        child: ExpansionTile(
          trailing: amount.paidDate != null ? const Icon(Icons.check, color: Colors.green) : const Icon(Icons.info_outline),
          backgroundColor: amount.value > 0 ? Colors.red[50] ?? Colors.white70 : Colors.green[50] ?? Colors.white70,
          tilePadding: EdgeInsets.only(left: titleLeftPad, right: 10),
          title: Text(amount.moneyValue()),
          subtitle: Text(amount.highlight(), maxLines: 1, style: const TextStyle(color: Colors.blueGrey)),
          children: [
            Text(amount.details()),
          ],
        ),
      ),
    );
  }

  void deleteAmount(Amount amount) {
    Data.amounts.remove(amount);
  }

  void togglePaidStatus(Amount amount) {
    Data.amounts.remove(amount);
    amount.paidDate = amount.paidDate == null ? DateTime.now() : null;
    Data.amounts.add(amount);
  }
}
