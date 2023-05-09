import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final String hint;
  final TextInputType keyboardType;
  final VoidCallback onSearchChanged;
  final TextCapitalization textCapitalization;
  final TextEditingController editTextController;

  const SearchField({
    super.key,
    required this.hint,
    required this.onSearchChanged,
    required this.editTextController,
    this.keyboardType = TextInputType.none,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: TextField(
        keyboardType: keyboardType,
        onChanged: (_) => onSearchChanged(),
        controller: editTextController,
        textCapitalization: textCapitalization,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          suffixIcon: editTextController.text.isEmpty
              ? Icon(Icons.search)
              : IconButton(
                  onPressed: _clearSearch,
                  icon: Icon(Icons.clear),
                ),
        ),
      ),
    );
  }

  void _clearSearch() {
    editTextController.clear();
    onSearchChanged();
  }
}
