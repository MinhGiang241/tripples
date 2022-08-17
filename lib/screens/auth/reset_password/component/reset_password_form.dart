import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:survey/screens/auth/login/login_screen.dart';

import '../../../../constants.dart';
import '../../../../data_sources/api/constants.dart';
import '../../../../generated/l10n.dart';
import '../../../profile/edit_password.dart';
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
        cache: GraphQLCache(store: HiveStore()),
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
                  hint: "code",
                  keyboardType: TextInputType.text,
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
                  prefixIcon: Icon(Icons.abc),
                  obscure: true,
                  validator: (v) {
                    if (v!.isEmpty) {
                      return S.current.not_blank;
                    } else {
                      return null;
                    }
                  }),
              AuthInput(
                  controller: widget.confirmNewPasswordEditingController,
                  hint: "Nhập lại mật khẩu mới",
                  keyboardType: TextInputType.text,
                  prefixIcon: Icon(Icons.abc),
                  obscure: true,
                  validator: (v) {
                    if (v!.isEmpty) {
                      return S.current.not_blank;
                    } else if (v != widget.newPasswordEditingController.text) {
                      return 'mật khẩu không khớp';
                    } else {
                      return null;
                    }
                  }),
              Mutation(
                  options: MutationOptions(document: gql(changePassword)),
                  builder: ((runMutation, result) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: AuthButton(
                        title: 'Đổi mật khẩu',
                        onPress: () {
                          if (_formKey.currentState!.validate()) {
                            print('submit');
                            runMutation({
                              "mailTo": widget.email,
                              "new_pw":
                                  widget.newPasswordEditingController.text,
                              "otp": widget.codeEditingController.text
                            });
                            if (result!.data?["authorization_forgot_password"]
                                    ['code'] ==
                                0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("Đã đổi mật khẩu thành công")));
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => LoginScreen()));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "mã OTP không đúng hoặc đã hết hạn")));
                            }
                          }
                        },
                      ))))
            ],
          )),
    );
  }
}
