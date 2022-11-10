import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_link/component/payment_widget.dart';
import 'package:money_link/model/amount.dart';
import 'package:money_link/model/payment.dart';
import 'package:money_link/model/tile.dart';
import 'package:money_link/objectbox.dart';
import 'package:money_link/objectbox.g.dart';

import '../component/value_form.dart';
import '../util.dart';

class PaymentsPage extends StatelessWidget {
  final Amount selectedAmount;
  final VoidCallback refreshAmounts;
  late Stream<List<Payment>> _paymentsStream;

  PaymentsPage(
      {super.key, required this.selectedAmount, required this.refreshAmounts}) {
    _paymentsStream = _amountPaymentsQuery();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Payment>>(
        initialData: const <Payment>[],
        stream: _paymentsStream,
        builder: (buildContext, streamSnapshot) {
          if (streamSnapshot.hasData) {
            return SlidableAutoCloseBehavior(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      selectedAmount.details(),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: const BouncingScrollPhysics(),
                      ),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      children: _getPaymentListItems(
                          buildContext,
                          (streamSnapshot.data ?? [])
                              .reversed
                              .toList(growable: false)),
                    ),
                  ),
                ],
              ),
            );
          }
          return ErrorWidget(streamSnapshot.error ?? "Something went wrong :(");
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => addPayment(context),
      ),
    );
  }

  List<Widget> _getPaymentListItems(
      BuildContext context, List<Payment> payments) {
    List<Widget> comboList = <Widget>[];

    if (payments.isEmpty) {
      comboList.add(
        Container(
          padding: const EdgeInsets.all(10),
          child: Text(
            "${Util.moneyFormat(selectedAmount.value)} has a no payments",
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 2),
          ),
        ),
      );
    } else {
      comboList.addAll(payments
          .map((p) => _buildTile(context, EntityTile.paymentTile(p)))
          .toList());
    }
    return comboList;
  }

  Widget _buildTile(BuildContext context, EntityTile<Payment> tile,
      {double subTileIndentation = 10.0}) {
    return PaymentWidget(payment: tile.object, refreshAmounts: refreshAmounts);
  }

  Stream<List<Payment>> _amountPaymentsQuery() {
    var queryBuilder = ObjectBox.store.box<Payment>().query();
    queryBuilder.link(Payment_.amount, Amount_.id.equals(selectedAmount.id));
    return queryBuilder.watch(triggerImmediately: true).map((q) => q.find());
  }

  void addPayment(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => ValueForm(
          model: this.selectedAmount, refreshFunction: refreshAmounts),
    );
  }
}
