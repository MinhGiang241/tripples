import 'package:flutter/material.dart';
import 'package:survey/constants.dart';

class AuthInput extends StatelessWidget {
  const AuthInput({
    Key? key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    required this.keyboardType,
    required this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.tab,
  }) : super(key: key);
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Function? tab;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding / 2),
      child: TextFormField(
        onTap: () {
          if (tab != null) {
            tab!();
          }
        },
        obscureText: obscure,
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(width: 0.5)),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon),
      ),
    );
  }
}
