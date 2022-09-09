import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:survey/constants.dart';

class AuthInput extends StatelessWidget {
  AuthInput(
      {Key? key,
      required this.controller,
      required this.hint,
      this.obscure = false,
      required this.keyboardType,
      required this.prefixIcon,
      this.suffixIcon,
      this.validator,
      this.tab,
      this.focusNode,
      this.maxLength,
      this.autoFocus = false,
      this.blockUnicode = false})
      : super(key: key);
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Function? tab;
  final int? maxLength;
  final bool autoFocus;
  bool blockUnicode = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding / 2),
      child: TextFormField(
        autofocus: autoFocus,
        maxLength: maxLength,
        inputFormatters: blockUnicode
            ? <TextInputFormatter>[
                FilteringTextInputFormatter.deny(RegExp(
                    r'[ àÀảẢãÃáÁạẠăĂằẰẳẲẵẴắẮặẶâÂầẦẩẨẫẪấẤậẬđĐèÈẻẺẽẼéÉẹẸêÊềỀểỂễỄếẾệỆìÌỉỈĩĨíÍịỊòÒỏỎõÕóÓọỌôÔồỒổỔỗỖốỐộỘơƠờỜởỞỡỠớỚợỢùÙủỦũŨúÚụỤưƯừỪửỬữỮứỨựỰỳỲỷỶỹỸýÝỵỴ]')),
              ]
            : null,
        onTap: () {
          if (tab != null) {
            tab!();
          }
        },
        focusNode: focusNode,
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
