import 'package:flutter/material.dart';
import 'package:survey/data_sources/api/api_auth.dart';
import 'package:survey/data_sources/shared_preferences/auth_shared_prf.dart';
import 'package:survey/models/account.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum AuthStatus { none, authentication, unauthentication }

class AuthController extends ChangeNotifier {
  AuthStatus authStatus = AuthStatus.none;
  Account? account;
  String? _token;
  String get token => _token!;
  bool isLoading = false;
  String? idUser;
  AuthController() {
    _init();
  }

  Future<String> login(
      {required String username, required String password}) async {
    loading();
    try {
      _token = await ApiAuth().login(username: username, password: password);
      unloading();
      if (_token != null) {
        authStatus = AuthStatus.authentication;
        notifyListeners();
      } else {
        authStatus = AuthStatus.unauthentication;
        notifyListeners();
      }
    } catch (e) {
      unloading();
      Fluttertoast.showToast(
          msg: e.toString().split(":").last,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black.withOpacity(0.8),
          textColor: Colors.white,
          fontSize: 16.0);
    }
    return _token ?? "";
  }

  Future logOut() async {
    loading();
    await AuthSharedPref.auth.clearAccount().then((value) async {
      unloading();
      authStatus = AuthStatus.none;
      notifyListeners();
      await Future.delayed(Duration(seconds: 1), () {
        authStatus = AuthStatus.unauthentication;
        notifyListeners();
      });
    });
  }

  loading() {
    isLoading = true;
    notifyListeners();
  }

  unloading() {
    isLoading = false;
    notifyListeners();
  }

  Future _init() async {
    await AuthSharedPref.auth.getAccount().then((acc) async {
      if (acc != null) {
        account = acc;
        await login(username: acc.userName!, password: acc.pass!);
      } else {
        authStatus = AuthStatus.unauthentication;
        notifyListeners();
      }
    });
  }
}
