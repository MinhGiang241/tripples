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
  ResetPassword({Key? key}) : super(key: key);
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
                codeEditingController: codelEditingController,
                newPasswordEditingController: newPasswordEditingController,
                confirmNewPasswordEditingController:
                    confirmNewPasswordEditingController)
          ]),
        ));
  }
}
