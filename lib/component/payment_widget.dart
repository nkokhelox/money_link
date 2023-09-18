import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_link/model/payment.dart';
import 'package:money_link/objectbox.dart';
import 'package:money_link/util.dart';

class PaymentWidget extends StatelessWidget {
  final Payment payment;
  final VoidCallback refreshFunction;

  const PaymentWidget(
      {Key? key, required this.payment, required this.refreshFunction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Slidable(
        key: ValueKey(payment.id),
        closeOnScroll: true,
        groupTag: 'amount',
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          dragDismissible: false,
          children: [
            SlidableAction(
              onPressed: (BuildContext context) => deletePayment(payment),
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              autoClose: true,
            ),
          ],
        ),
        child: ExpansionTile(
          shape: Border.all(color: Colors.transparent, width: 0),
          title: Text(Util.moneyFormat(payment.value)),
          childrenPadding: EdgeInsets.only(left: 20),
          expandedAlignment: Alignment.topLeft,
          subtitle: Text(
            payment.highlight(),
            maxLines: 1,
            style: TextStyle(fontSize: 10),
          ),
          children: [
            Text(
              payment.details(),
              style: const TextStyle(fontSize: 10),
            )
          ],
        ),
      ),
    );
  }

  void deletePayment(Payment payment) {
    ObjectBox.store.box<Payment>().remove(payment.id);
    refreshFunction();
  }
}
