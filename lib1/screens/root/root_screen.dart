import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey/controllers/auth/auth_controller.dart';
import 'package:survey/screens/auth/login/login_screen.dart';
import 'package:survey/screens/home/home_screens.dart';

class RootScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var status = context.watch<AuthController>().authStatus;
    print(status);
    if (status == AuthStatus.unauthentication) {
      return LoginScreen(); //LoginScreen
    } else if (status == AuthStatus.authentication) {
      return HomeScreen();
    } else if (status == AuthStatus.none) {
      return LoginScreen();
    } else {
      return SplashScreen();
    }
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/icons/HoaSao.jpeg",
          width: 100,
        ),
      ),
    );
  }
}
