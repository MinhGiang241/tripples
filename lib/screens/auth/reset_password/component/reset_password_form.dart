import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:survey/screens/auth/login/login_screen.dart';

import '../../../../constants.dart';
import '../../../../data_sources/api/constants.dart';
import '../../../../generated/l10n.dart';
import '../../components/auth_button.dart';
import '../../components/auth_input.dart';

class ResetPasswordForm extends StatefulWidget {
  ResetPasswordForm(
      {Key? key,
      required this.email,
      required this.codeEditingController,
      required this.newPasswordEditingController,
      required this.confirmNewPasswordEditingController})
      : super(key: key);
  final String email;
  final TextEditingController codeEditingController;
  final TextEditingController newPasswordEditingController;
  final TextEditingController confirmNewPasswordEditingController;
  var disabled = false;
  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var changePassword =
      '''mutation (\$mailTo: String,\$new_pw: String,\$otp: String){
  authorization_forgot_password(mailTo: \$mailTo, new_pw:\$new_pw,otp:\$otp){
		code
    message
    data
  }
  }''';
  bool showValKey = false;
  bool hideNewPass = true;
  bool hideConfirmPass = true;
  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(ApiConstants.baseUrl);

    final AuthLink authLink = AuthLink(getToken: () {
      return null;
    });
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
      child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nhập code và mật khẩu mới",
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(
                height: padding / 2,
              ),
              AuthInput(
                  controller: widget.codeEditingController,
                  hint: "Mã OTP",
                  keyboardType: TextInputType.number,
                  prefixIcon: Icon(Icons.mail),
                  validator: (v) {
                    if (v!.isEmpty) {
                      return S.current.not_blank;
                    } else {
                      return null;
                    }
                  }),
              AuthInput(
                  controller: widget.newPasswordEditingController,
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
                  obscure: hideNewPass,
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
                  }),
              AuthInput(
                  controller: widget.confirmNewPasswordEditingController,
                  hint: "Nhập lại mật khẩu mới",
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
                  obscure: hideConfirmPass,
                  validator: (v) {
                    if (v!.isEmpty) {
                      return S.current.not_blank;
                    } else if (v != widget.newPasswordEditingController.text) {
                      return 'mật khẩu không khớp';
                    } else {
                      return null;
                    }
                  }),
              if (showValKey)
                FlutterPwValidator(
                    controller: widget.newPasswordEditingController,
                    minLength: 6,
                    uppercaseCharCount: 1,
                    numericCharCount: 1,
                    specialCharCount: 1,
                    width: 400,
                    height: 150,
                    onSuccess: () {
                      print("Matched");
                    }),
              Mutation(
                  options: MutationOptions(
                      document: gql(changePassword),
                      onCompleted: (dynamic result) async {
                        setState(() {
                          widget.disabled = false;
                        });
                        if (result["authorization_forgot_password"]['code'] ==
                            0) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Đã đổi mật khẩu thành công")));
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => LoginScreen()));
                        } else {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text("mã OTP không hợp lệ hoặc đã hết hạn")));
                        }
                      }),
                  builder: ((runMutation, result) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: AuthButton(
                        disabled: widget.disabled,
                        title: 'Đổi mật khẩu',
                        onPress: () {
                          setState(() {
                            widget.disabled = true;
                          });
                          if (_formKey.currentState!.validate()) {
                            print('submit');
                            runMutation({
                              "mailTo": widget.email,
                              "new_pw":
                                  widget.newPasswordEditingController.text,
                              "otp": widget.codeEditingController.text
                            });
                            // if (result!.data?["authorization_forgot_password"]
                            //         ['code'] ==
                            //     0) {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //       SnackBar(
                            //           content:
                            //               Text("Đã đổi mật khẩu thành công")));
                            //   Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //           builder: (_) => LoginScreen()));
                            // } else {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //       SnackBar(
                            //           content: Text(
                            //               "mã OTP không đúng hoặc đã hết hạn")));
                            // }
                          }
                        },
                      ))))
            ],
          )),
    );
  }
}
