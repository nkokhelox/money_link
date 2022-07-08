import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_link/component/value_form.dart';
import 'package:money_link/model/amount.dart';
import 'package:money_link/objectbox.dart';
import 'package:money_link/page/payments_page.dart';

class AmountWidget extends StatelessWidget {
  final Amount amount;
  final double titleLeftPad;
  final VoidCallback refreshPeople;
  final VoidCallback refreshAmounts;
  const AmountWidget({super.key, required this.amount, required this.refreshPeople, required this.refreshAmounts, this.titleLeftPad = 10});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Slidable(
        key: ValueKey(amount.id),
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
        child: ListTile(
          trailing: amount.paidDate != null ? const Icon(Icons.check, color: Colors.green) : const Icon(Icons.info_outline),
          contentPadding: EdgeInsets.only(left: titleLeftPad, right: 10),
          title: Text(amount.moneyValue()),
          subtitle: Text(
            amount.highlight(),
            maxLines: 1,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).textTheme.subtitle2?.color,
            ),
          ),
          onLongPress: () => addPayment(context),
          onTap: () => showPayments(context),
        ),
      ),
    );
  }

  void deleteAmount(Amount amount) {
    ObjectBox.store.box<Amount>().remove(amount.id);
    refreshPeople();
  }

  void togglePaidStatus(Amount amount) {
    amount.paidDate = (amount.paidDate == null) ? DateTime.now() : null;
    ObjectBox.store.box<Amount>().put(amount);
    refreshPeople();
  }

  void addPayment(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => ValueForm(model: amount, refreshFunction: refreshAmounts),
    );
  }

  showPayments(BuildContext context) {
    showModalBottomSheet(context: context, builder: (_) => PaymentsPage(selectedAmount: amount, refreshAmounts: refreshAmounts));
  }
}
