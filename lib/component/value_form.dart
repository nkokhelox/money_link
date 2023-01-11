import 'package:flutter/material.dart';
import 'package:money_link/model/amount.dart';
import 'package:money_link/model/base_model.dart';
import 'package:money_link/model/payment.dart';
import 'package:money_link/model/person.dart';
import 'package:money_link/objectbox.dart';

import '../util.dart';

class ValueForm extends StatefulWidget {
  final BaseModel model;
  final VoidCallback refreshFunction;
  const ValueForm(
      {Key? key, required this.model, required this.refreshFunction})
      : super(key: key);

  @override
  State<ValueForm> createState() => ValueFormState();
}

class ValueFormState extends State<ValueForm> {
  final _formKey = GlobalKey<FormState>();
  final _valueFieldController = TextEditingController();
  final _noteFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      physics: const BouncingScrollPhysics(),
      child: AlertDialog(
        title: Text(title(widget.model), textAlign: TextAlign.center),
        content: Form(
          key: _formKey,
          child: Wrap(
            children: [
              Card(
                child: TextFormField(
                  autofocus: true,
                  autocorrect: false,
                  autofillHints: const ["-", ".00"],
                  validator: valueValidator,
                  controller: _valueFieldController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Icon(Icons.money),
                    hintText: '0.00',
                  ),
                ),
              ),
              Card(
                child: TextFormField(
                  autofocus: true,
                  autocorrect: false,
                  validator: noteValidator,
                  controller: _noteFieldController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Icon(Icons.note),
                    hintText: 'note',
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: onCancel, child: const Text("Cancel")),
          TextButton(onPressed: onSave, child: const Text("Save")),
        ],
      ),
    );
  }

  String? valueValidator(String? value) {
    try {
      if (value != null && value.isNotEmpty) {
        double.parse(value);
        return null;
      }
      throw Exception("not a number");
    } catch (_) {
      return "Enter a valid number";
    }
  }

  String? noteValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter some text as a note";
    }
    return null;
  }

  void onCancel() {
    Navigator.pop(context);
  }

  void onSave() {
    if (_formKey.currentState!.validate()) {
      final model = widget.model;
      final scaffold = ScaffoldMessenger.of(context);
      final value = double.parse(_valueFieldController.text);
      if (model is Person) {
        final amount = Amount(value: value, note: _noteFieldController.text);
        model.amounts.add(amount);
        ObjectBox.store.box<Person>().put(model);
        scaffold.showSnackBar(SnackBar(
            content: Text(
                'Added ${Util.moneyFormat(amount.value)} for ${widget.model.dialogTitle()}')));
      } else if (model is Amount) {
        final payment = Payment(value: value, note: _noteFieldController.text);
        model.payments.add(payment);
        ObjectBox.store.box<Amount>().put(model);
        scaffold.showSnackBar(SnackBar(
            content: Text(
                'Added ${Util.moneyFormat(payment.value)} for ${widget.model.dialogTitle()}')));
      } else {
        scaffold.showSnackBar(SnackBar(
            content: Text('Failed to save: ${widget.model.dialogTitle()}')));
      }

      widget.refreshFunction();
      Navigator.pop(context);
    }
  }

  String title(BaseModel model) {
    if (model is Person) {
      return "Amount for ${model.fullName}";
    } else if (model is Amount) {
      return "Payment for ${Util.moneyFormat(model.value)}";
    } else {
      return "Exit this dialog";
    }
  }
}
