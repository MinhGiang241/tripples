import 'package:flutter/material.dart';
import 'package:survey/controllers/auth/auth_controller.dart';
import 'components/header_login.dart';
import 'components/login_form.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameEditingController =
      TextEditingController();

  final TextEditingController passEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            elevation: 0,
          ),
          body: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              HeaderLogin(),
              LoginForm(
                userNameEditingController: usernameEditingController,
                passwordEditingController: passEditingController,
              )
            ],
          ),
        ),
        if (context.watch<AuthController>().isLoading)
          Container(
            color: Colors.black45,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
      ],
    );
  }
}
