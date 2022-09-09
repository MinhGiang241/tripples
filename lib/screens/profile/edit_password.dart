// ignore_for_file: deprecated_member_use

import "package:flutter/material.dart";

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:survey/constants.dart';

import '../../controllers/auth/auth_controller.dart';
import '../../data_sources/api/constants.dart';
import '../../generated/l10n.dart';
import '../auth/components/auth_input.dart';
import '../home/home_screens.dart';
import '../root/root_screen.dart';
import 'user_profile.dart';

class UpdatePassword extends StatefulWidget {
  UpdatePassword();
  @override
  State<UpdatePassword> createState() => _UpdatePassword();
}

class _UpdatePassword extends State<UpdatePassword> {
  final oldPasController = TextEditingController();
  final newPasController = TextEditingController();
  final confirmNewPasController = TextEditingController();
  var disabled = false;

  SnackBar createSnackBar(String message) {
    return SnackBar(
        content: Text(
      message,
      style: TextStyle(color: Colors.white),
    ));
  }

  void onSubmit(runMutation, result) async {
    if (_formKey1.currentState!.validate() &&
        _formKey2.currentState!.validate() &&
        _formKey3.currentState!.validate()) {
      print('validated');
      FocusScope.of(context).unfocus();
      setState(() {
        disabled = true;
      });
      print(result);
      // ignore: await_only_futures
      await runMutation({
        "oldpass": oldPasController.text.trim(),
        "newpass": newPasController.text.trim(),
        "renewpw": confirmNewPasController.text.trim()
      });
    }
  }

  void onCompleteMutation(data) {
    setState(() {
      disabled = false;
    });
    try {
      String? message = data["authorization_change_password"]["message"];
      var code = data["authorization_change_password"]["code"];
      if (code == 0) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        final snackBar = createSnackBar("Đổi mật khẩu thành công");
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => RootScreen()));
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        final snackBar = createSnackBar(message != null
            ? message.split(':').last
            : "Đổi mật khẩu không thành công");
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print(e);
      print('loooooo');
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      final snackBar =
          createSnackBar("Đã xảy ra lỗi, vui lòng kiểm tra lại kết nối");
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _oldPassFocusNode = FocusNode();
  bool showValKey = false;
  bool hideOldPass = true;
  bool hideNewPass = true;
  bool hideConfirmPass = true;

  @override
  void dispose() {
    _oldPassFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _oldPassFocusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var changePassword = '''
      mutation  (\$oldpass: String, \$newpass: String, \$renewpw:String){
    authorization_change_password (old_pw:\$oldpass , new_pw:\$newpass, re_new_pw:\$renewpw){
  	  message
      code 
      data
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
        cache: GraphQLCache(
            // store: HiveStore()
            ),
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
                padding: EdgeInsets.symmetric(
                    horizontal: padding, vertical: padding),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Form(
                        key: _formKey1,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: AuthInput(
                          blockUnicode: true,
                          focusNode: _oldPassFocusNode,
                          obscure: hideOldPass,
                          controller: oldPasController,
                          hint: "Mật khẩu cũ",
                          keyboardType: TextInputType.text,
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                              onPressed: () => {
                                    setState(() {
                                      hideOldPass = !hideOldPass;
                                    })
                                  },
                              icon: hideOldPass
                                  ? Icon(Icons.visibility_rounded)
                                  : Icon(Icons.visibility_off_sharp)),
                          validator: (val) {
                            // setState(() {
                            disabled = false;
                            // });
                            if (val!.isEmpty) {
                              return S.current.not_blank;
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                      Form(
                        key: _formKey2,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: AuthInput(
                          blockUnicode: true,
                          obscure: hideNewPass,
                          controller: newPasController,
                          hint: "Mật khẩu mới",
                          keyboardType: TextInputType.text,
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                              onPressed: () => {
                                    setState(() {
                                      hideNewPass = !hideNewPass;
                                    })
                                  },
                              icon: hideNewPass
                                  ? Icon(Icons.visibility_rounded)
                                  : Icon(Icons.visibility_off_sharp)),
                          tab: () {
                            setState(() {
                              showValKey = true;
                            });
                          },
                          validator: (val) {
                            disabled = false;

                            if (val!.isEmpty) {
                              return S.current.not_blank;
                            } else if (!RegExp(r"^[\s\S]{6,20}$")
                                .hasMatch(val)) {
                              return "Mật khẩu ít nhất 6 ký tự và nhiều nhất 20 ký tự";
                            } else if (!RegExp(r"(.*[a-z].*)").hasMatch(val) ||
                                !RegExp(r"(.*[A-Z].*)").hasMatch(val)) {
                              return "Mật khẩu ít nhất 1 chữ cái hoa, 1 chữ cái thường";
                            } else if (!RegExp(r"(.*[0-9].*)").hasMatch(val)) {
                              return "Mật khẩu ít nhất 1 chữ số";
                            } else if (!RegExp(
                                    r"(?=.*[@$!%*#?&)(\-+=\[\]\{\}\.\,<>\'\`~:;\\|/])[A-Za-z\d@$!%*#?&]")
                                .hasMatch(val)) {
                              return "Mật khẩu ít nhất 1 ký tự đặc biệt";
                            }
                            return null;
                          },
                        ),
                      ),
                      Form(
                        key: _formKey3,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: AuthInput(
                          blockUnicode: true,
                          obscure: hideConfirmPass,
                          controller: confirmNewPasController,
                          hint: "Nhập lại mật khẩu", //S.current.confirm_pass,
                          keyboardType: TextInputType.text,
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                              onPressed: () => {
                                    setState(() {
                                      hideConfirmPass = !hideConfirmPass;
                                    })
                                  },
                              icon: hideConfirmPass
                                  ? Icon(Icons.visibility_rounded)
                                  : Icon(Icons.visibility_off_sharp)),
                          validator: (val) {
                            // setState(() {
                            disabled = false;
                            // });
                            if (val!.isEmpty) {
                              return S.current.not_blank;
                            } else if (val != newPasController.text) {
                              return S.current.not_same;
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                      // if (showValKey)
                      // FlutterPwValidator(
                      //   controller: newPasController,
                      //   minLength: 6,
                      //   uppercaseCharCount: 1,
                      //   numericCharCount: 1,
                      //   specialCharCount: 1,
                      //   width: 400,
                      //   height: 150,
                      //   onSuccess: () {
                      //     print("Matched");
                      //   },
                      // ),
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
                    ]))),
      ),
    );
  }
}
