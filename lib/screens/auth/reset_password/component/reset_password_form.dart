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

class ResetPasswordForm extends StatefulWidget {
  ResetPasswordForm(
      {Key? key,
      required this.codeEditingController,
      required this.newPasswordEditingController,
      required this.confirmNewPasswordEditingController})
      : super(key: key);
  final TextEditingController codeEditingController;
  final TextEditingController newPasswordEditingController;
  final TextEditingController confirmNewPasswordEditingController;

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var queryChangepassword = '''''';

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
                  options: MutationOptions(document: gql(queryChangepassword)),
                  builder: ((runMutation, result) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: AuthButton(
                        title: 'Đổi mật khẩu',
                        onPress: () {
                          if (_formKey.currentState!.validate()) {
                            print('submit');
                          }
                        },
                      ))))
            ],
          )),
    );
  }
}
