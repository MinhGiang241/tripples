import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:survey/screens/auth/reset_password/component/reset_password_form.dart';

import '../../../constants.dart';
import '../login/components/header_login.dart';
import 'component/reset_password_form.dart';

class ResetPassword extends StatelessWidget {
  final String email;
  var formKey1;
  var formKey2;
  var formKey3;
  ResetPassword({
    required this.email,
    required this.formKey1,
    required this.formKey2,
    required this.formKey3,
  });

  final TextEditingController codelEditingController = TextEditingController();
  final TextEditingController newPasswordEditingController =
      TextEditingController();
  final TextEditingController confirmNewPasswordEditingController =
      TextEditingController();

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
                'Đổi lại mật khẩu',
                style: Theme.of(context).textTheme.headline6?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ResetPasswordForm(
                formKey1: formKey1,
                formKey2: formKey2,
                formKey3: formKey3,
                email: email,
                codeEditingController: codelEditingController,
                newPasswordEditingController: newPasswordEditingController,
                confirmNewPasswordEditingController:
                    confirmNewPasswordEditingController)
          ]),
        ));
  }
}
