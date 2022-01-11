import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    required this.controller,
    required this.labelText,
    required this.keyboardType,
    required this.validationString,
    this.inputFormatters,
    this.focusNode,
    this.onFieldSubmitted,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;
  final String labelText;
  final String validationString;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      cursorHeight: 20,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      validator: (val) {
        if (val!.isEmpty) {
          return validationString;
        } else {
          return null;
        }
      },
    );
  }
}
