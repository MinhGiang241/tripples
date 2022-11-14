import 'package:flutter/material.dart';
import 'package:survey/constants.dart';

class AuthButton extends StatefulWidget {
  AuthButton(
      {Key? key,
      required this.title,
      required this.onPress,
      this.disabled = false,
      this.color})
      : super(key: key);
  final String title;
  bool disabled;
  final Function onPress;
  final Color? color;

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
  @override
  Widget build(BuildContext context) {
    print(widget.disabled);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: double.infinity, minHeight: 50),
        child: ElevatedButton(
            onPressed: widget.disabled
                ? null
                : () {
                    widget.onPress();
                  },
            style: TextButton.styleFrom(
                backgroundColor: widget.color != null
                    ? widget.color
                    : widget.disabled
                        ? Colors.grey
                        : Theme.of(context).primaryColor),
            child: widget.disabled
                ? SizedBox(
                    height: 28, width: 28, child: CircularProgressIndicator())
                : Text(
                    widget.title,
                    style: Theme.of(context)
                        .textTheme
                        .button
                        ?.copyWith(color: Colors.white),
                  )),
      ),
    );
  }
}
