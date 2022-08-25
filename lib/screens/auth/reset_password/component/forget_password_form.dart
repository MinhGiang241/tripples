import 'package:flutter/material.dart';

import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../constants.dart';
import '../../../../data_sources/api/constants.dart';
import '../../../../generated/l10n.dart';

import '../../components/auth_button.dart';
import '../../components/auth_input.dart';
import '../reset_password.dart';

class ForgetPasswordForm extends StatefulWidget {
  ForgetPasswordForm({
    Key? key,
    required this.emailEditingController,
  }) : super(key: key);
  final TextEditingController emailEditingController;
  var disabled = false;

  @override
  State<ForgetPasswordForm> createState() => _ForgetPasswordFormState();
}

class _ForgetPasswordFormState extends State<ForgetPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var sendOtp = '''
  mutation (\$mailTo: String) {
  authorization_generate_otp(mailTo: \$mailTo){
    code
    message
    data
    }
  }
  ''';

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
                "Nhập lại email đã đăng ký tài khoản",
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(
                height: padding / 2,
              ),
              AuthInput(
                  controller: widget.emailEditingController,
                  hint: S.current.email,
                  keyboardType: TextInputType.text,
                  prefixIcon: Icon(Icons.mail),
                  validator: (v) {
                    if (v!.isEmpty) {
                      return S.current.not_blank;
                    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(v)) {
                      return "Không phải email";
                    } else {
                      return null;
                    }
                  }),
              Mutation(
                  options: MutationOptions(
                      document: gql(sendOtp),
                      onCompleted: (dynamic result) async {
                        print(result);
                        setState(() {
                          widget.disabled = false;
                        });
                        if (result['authorization_generate_otp']['code'] != 0) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Gửi mã OTP không thành công" //result['authorization_generate_otp']['message']
                                  )));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text("Đã gửi mã OTP vào email của bạn")));
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ResetPassword(
                                      email:
                                          widget.emailEditingController.text)));
                        }
                      }),
                  builder: ((runMutation, result) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: AuthButton(
                        disabled: widget.disabled,
                        title: 'Gửi Mã OTP',
                        onPress: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              widget.disabled = true;
                            });
                            runMutation(
                                {'mailTo': widget.emailEditingController.text});
                            print(widget.emailEditingController.text);
                          }
                        },
                      ))))
            ],
          )),
    );
  }
}
