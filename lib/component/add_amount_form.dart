import 'package:flutter/material.dart';

import '../model/amount.dart';
import '../model/person.dart';

class AddAmountForm extends StatefulWidget {
  const AddAmountForm({Key? key, required this.person}) : super(key: key);
  final Person person;

  @override
  State<AddAmountForm> createState() => AddAmountFormState();
}

class AddAmountFormState extends State<AddAmountForm> {
  final _formKey = GlobalKey<FormState>();
  final _valueFieldController = TextEditingController();
  final _noteFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      physics: const BouncingScrollPhysics(),
      child: AlertDialog(
        title: Text(widget.person.fullName, textAlign: TextAlign.center),
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
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Icon(Icons.money),
                    hintStyle: TextStyle(color: Colors.blueGrey),
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
                    hintStyle: TextStyle(color: Colors.blueGrey),
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
      final amount = Amount(value: double.parse(_valueFieldController.text), note: _noteFieldController.text);
      // TODO: 2 - add amount to the DB
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${amount.moneyValue()} saved for ${widget.person.firstName()}')),
      );
      Navigator.pop(context);
    }
  }
}
