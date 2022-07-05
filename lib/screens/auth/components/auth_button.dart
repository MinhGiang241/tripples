import 'package:flutter/material.dart';
import 'package:survey/constants.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({
    Key? key,
    required this.title,
    required this.onPress,
  }) : super(key: key);
  final String title;
  final Function onPress;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding / 2),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: double.infinity, minHeight: 50),
        child: ElevatedButton(
            onPressed: () {
              onPress();
            },
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor),
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .button
                  ?.copyWith(color: Colors.white),
            )),
      ),
    );
  }
}
