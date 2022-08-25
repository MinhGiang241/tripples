// ignore_for_file: deprecated_member_use

import "package:flutter/material.dart";
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:survey/constants.dart';

import '../../controllers/auth/auth_controller.dart';
import '../../data_sources/api/constants.dart';
import '../../generated/l10n.dart';
import '../auth/components/auth_input.dart';
import 'user_profile.dart';

class UpdatePassword extends StatefulWidget {
  UpdatePassword();
  @override
  State<UpdatePassword> createState() => _UpdatePassword();
}

class _UpdatePassword extends State<UpdatePassword> {
  final oldPasController = TextEditingController();
  final newPasController = TextEditingController();
  final confirmNewPasCotroller = TextEditingController();
  var disabled = false;
  void submitData() {
    print(oldPasController.text);
    print(newPasController.text);
    print(confirmNewPasCotroller.text);
    Navigator.of(context).pop();
  }

  SnackBar createSnackBar(String message) {
    return SnackBar(
        content: Text(
      message,
      style: TextStyle(color: Colors.white),
    ));
  }

  void onSubmit(runMutation, result) async {
    if (_formKey.currentState!.validate()) {
      print('validated');
      setState(() {
        disabled = true;
      });
      print(result);
      // ignore: await_only_futures
      await runMutation(
          {"oldpass": oldPasController.text, "newpass": newPasController.text});
    }
  }

  void onCompleteMutation(data) {
    setState(() {
      disabled = false;
    });
    var message = data["authorization_change_password"]["message"];
    if (message == null) {
      final snackBar = createSnackBar("Đã đổi mật khẩu thành công");
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pop(context);
    } else {
      final snackBar = createSnackBar(message);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  final _formKey = GlobalKey<FormState>();
  bool showValKey = false;
  @override
  Widget build(BuildContext context) {
    var changePassword = '''
      mutation  (\$oldpass: String, \$newpass: String){
    authorization_change_password (old_pw:\$oldpass , new_pw:\$newpass){
  	  message
    }
    }
      ''';

    final HttpLink httpLink = HttpLink(ApiConstants.baseUrl);

    final AuthLink authLink = AuthLink(
        getToken: () => 'Bearer ${context.read<AuthController>().token}');
    final Link link = authLink.concat(httpLink);
    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: link,
        // The default store is the InMemoryStore, which does NOT persist to disk
        cache: GraphQLCache(store: HiveStore()),
      ),
    );

    return GraphQLProvider(
      client: client,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(
            "Đổi mật khẩu",
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        body: Card(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                AuthInput(
                  obscure: true,
                  controller: oldPasController,
                  hint: "Old Password",
                  keyboardType: TextInputType.text,
                  prefixIcon: Icon(Icons.lock),
                  validator: (val) {
                    if (val!.isEmpty) {
                      return S.current.not_blank;
                    } else {
                      return null;
                    }
                  },
                ),
                AuthInput(
                  obscure: true,
                  controller: newPasController,
                  hint: "New Password",
                  keyboardType: TextInputType.text,
                  prefixIcon: Icon(Icons.lock),
                  tab: () {
                    setState(() {
                      showValKey = true;
                    });
                  },
                  validator: (val) {
                    if (val!.isEmpty) {
                      return S.current.not_blank;
                    } else if (!RegExp(r"^[\s\S]{6,20}$").hasMatch(val)) {
                      return "Mật khẩu ít nhất 6 ký tự và nhiều nhất 20 ký tự";
                    } else if (!RegExp(r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]")
                        .hasMatch(val)) {
                      return "Mật khẩu ít nhất 1 chữ cái , 1 số";
                    } else if (!RegExp(r"(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]")
                        .hasMatch(val)) {
                      return "Mật khẩu ít nhất 1 ký tự đặc biệt";
                    }
                    return null;
                  },
                ),
                if (showValKey)
                  FlutterPwValidator(
                    controller: newPasController,
                    minLength: 6,
                    uppercaseCharCount: 1,
                    numericCharCount: 1,
                    specialCharCount: 1,
                    width: 400,
                    height: 150,
                    onSuccess: () {
                      print("Matched");
                    },
                  ),
                AuthInput(
                  obscure: true,
                  controller: confirmNewPasCotroller,
                  hint: S.current.confirm_pass,
                  keyboardType: TextInputType.text,
                  prefixIcon: Icon(Icons.lock),
                  validator: (val) {
                    if (val!.isEmpty) {
                      return S.current.not_blank;
                    } else if (val != confirmNewPasCotroller.text) {
                      return S.current.not_same;
                    } else {
                      return null;
                    }
                  },
                ),
                Mutation(
                  options: MutationOptions(
                    document: gql(changePassword),
                    onCompleted: (data) => onCompleteMutation(data),
                  ),
                  builder: ((runMutation, result) => Padding(
                        padding: EdgeInsets.symmetric(vertical: padding),
                        child: ElevatedButton(
                            onPressed: disabled
                                ? null
                                : () => onSubmit(runMutation, result),
                            style: TextButton.styleFrom(
                                backgroundColor: disabled
                                    ? Colors.grey
                                    : Theme.of(context).primaryColor),
                            child: Text(
                              "Đổi mật khẩu",
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  ?.copyWith(color: Colors.white),
                            )),
                      )),
                )
              ],
            ),
          ),
        )),
      ),
    );
  }
}
