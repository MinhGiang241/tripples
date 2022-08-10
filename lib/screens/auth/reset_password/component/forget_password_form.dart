import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../constants.dart';
import '../../../../data_sources/api/constants.dart';
import '../../../../generated/l10n.dart';
import '../../../profile/edit_password.dart';
import '../../components/auth_button.dart';
import '../../components/auth_input.dart';
import '../reset_password.dart';

class ForgetPasswordForm extends StatefulWidget {
  ForgetPasswordForm({
    Key? key,
    required this.emailEditingController,
  }) : super(key: key);
  final TextEditingController emailEditingController;

  @override
  State<ForgetPasswordForm> createState() => _ForgetPasswordFormState();
}

class _ForgetPasswordFormState extends State<ForgetPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var sendOtp = '''
  mutation (\$mailTo: String) {
  authorization_generate_otp(mailTo: \$mailTo){
    code
    
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
                    } else {
                      return null;
                    }
                  }),
              Mutation(
                  options: MutationOptions(document: gql(sendOtp)),
                  builder: ((runMutation, result) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: AuthButton(
                        title: 'Gửi Mã OTP',
                        onPress: () async {
                          if (_formKey.currentState!.validate()) {
                            runMutation(
                                {'mailTo': widget.emailEditingController.text});

                            if (result!.data?["authorization_generate_otp"]
                                    ['code'] ==
                                0) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "hệ thống Đã gửi mã OTP vào email của bạn")));
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ResetPassword()));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("Gửi mã OTP không thành công")));
                            }
                          }
                        },
                      ))))
            ],
          )),
    );
  }
}
