import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../../constants.dart';
import '../login/components/header_login.dart';
import 'component/forget_password_form.dart';

class ForgetPassword extends StatelessWidget {
  ForgetPassword({Key? key}) : super(key: key);
  final TextEditingController emailEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(elevation: 0),
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: padding),
          child: ListView(physics: BouncingScrollPhysics(), children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: padding),
              child: Text(
                'Quên mật khẩu',
                style: Theme.of(context).textTheme.headline6?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ForgetPasswordForm(
              emailEditingController: emailEditingController,
            )
          ]),
        ));
  }
}
