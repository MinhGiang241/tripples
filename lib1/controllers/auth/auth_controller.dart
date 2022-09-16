import 'package:flutter/material.dart';
import 'package:survey/data_sources/api/api_auth.dart';
import 'package:survey/data_sources/shared_preferences/auth_shared_prf.dart';
import 'package:survey/models/account.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:survey/screens/auth/login/login_screen.dart';

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
      print(e.toString().split(":").last);
      Fluttertoast.showToast(
          msg: e.toString().contains("hostname")
              ? "Kiểm tra kết nối mạng"
              : e.toString().split(":").last == " Incorrect password." ||
                      e.toString().split(":").last == ' User does not exist..'
                  ? 'Sai tài khoản hoặc mật khẩu'
                  : e.toString().contains("authorization")
                      ? "Không đăng nhập được tài khoản"
                      : e
                          .toString()
                          .split(":")
                          .last, //e.toString().split(":").last,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black.withOpacity(0.8),
          textColor: Colors.white,
          fontSize: 16.0);
    }
    return _token ?? "";
  }

  Future logOut(context) async {
    loading();
    await AuthSharedPref.auth.clearAccount().then((value) async {
      await unloading();
      authStatus = AuthStatus.none;
      notifyListeners();
      authStatus = AuthStatus.unauthentication;
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
