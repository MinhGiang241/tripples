import 'package:shared_preferences/shared_preferences.dart';
import 'package:survey/models/account.dart';

class AuthSharedPref {
  static final AuthSharedPref auth = AuthSharedPref();
  final String saveAccountKey = "SAVEACCOUNTKEY";
  Future<bool> saveAccount(
      {required String username, required String pass}) async {
    final preference = await SharedPreferences.getInstance();
    return preference.setStringList(saveAccountKey, [username, pass]);
  }

  Future<Account?> getAccount() async {
    final preference = await SharedPreferences.getInstance();
    List<String>? acc = preference.getStringList(saveAccountKey);
    if (acc != null) {
      return Account(userName: acc[0], pass: acc[1]);
    } else {
      return null;
    }
  }

  Future<bool> clearAccount() async {
    final preference = await SharedPreferences.getInstance();
    return preference.remove(saveAccountKey);
  }
}
