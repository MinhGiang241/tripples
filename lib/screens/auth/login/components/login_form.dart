import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:survey/constants.dart';
import 'package:survey/controllers/auth/auth_controller.dart';
import 'package:survey/data_sources/api/constants.dart';
import 'package:survey/data_sources/shared_preferences/auth_shared_prf.dart';
import 'package:survey/generated/l10n.dart';
import 'package:survey/screens/auth/components/auth_button.dart';
import 'package:survey/screens/auth/components/auth_input.dart';
import 'package:survey/screens/auth/register/register_screen.dart';

import '../../reset_password/forget_password.dart';

class LoginForm extends StatefulWidget {
  LoginForm({
    Key? key,
    required this.userNameEditingController,
    required this.passwordEditingController,
  }) : super(key: key);
  final TextEditingController userNameEditingController;
  final TextEditingController passwordEditingController;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var isLogin = false;
  final _userNameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool hidePass = true;

  @override
  void dispose() {
    _userNameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

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
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.current.login,
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(
                height: padding / 2,
              ),
              AuthInput(
                  blockUnicode: true,
                  focusNode: _userNameFocusNode,
                  controller: widget.userNameEditingController,
                  hint: 'Tên tài khoản', //S.current.user_name,
                  keyboardType: TextInputType.text,
                  prefixIcon: Icon(Icons.person),
                  validator: (v) {
                    if (v!.trim().isEmpty) {
                      _userNameFocusNode.requestFocus();
                      return S.current.not_blank;
                    } else if (RegExp(
                            r'[àÀảẢãÃáÁạẠăĂằẰẳẲẵẴắẮặẶâÂầẦẩẨẫẪấẤậẬđĐèÈẻẺẽẼéÉẹẸêÊềỀểỂễỄếẾệỆìÌỉỈĩĨíÍịỊòÒỏỎõÕóÓọỌôÔồỒổỔỗỖốỐộỘơƠờỜởỞỡỠớỚợỢùÙủỦũŨúÚụỤưƯừỪửỬữỮứỨựỰỳỲỷỶỹỸýÝỵỴ]')
                        .hasMatch(v)) {
                      return 'Không nhập tiếng việt có dấu!';
                    } else {
                      return null;
                    }
                  }),
              AuthInput(
                  blockUnicode: true,
                  maxLength: 20,
                  focusNode: _passwordFocusNode,
                  controller: widget.passwordEditingController,
                  hint: 'Mật khẩu', //S.current.password,
                  keyboardType: TextInputType.text,
                  prefixIcon: Icon(Icons.lock),
                  obscure: hidePass,
                  suffixIcon: IconButton(
                      onPressed: () => {
                            setState(() {
                              hidePass = !hidePass;
                            })
                          },
                      icon: hidePass
                          ? Icon(Icons.visibility_rounded)
                          : Icon(Icons.visibility_off_sharp)),
                  validator: (v) {
                    if (v!.isEmpty) {
                      if (!_passwordFocusNode.hasFocus) {
                        _passwordFocusNode.requestFocus();
                      }

                      return S.current.not_blank;
                    } else if (v == 'admin' &&
                        widget.userNameEditingController.text == 'admin') {
                      return null;
                    } else if (!RegExp(r"^[\s\S]{6,20}$").hasMatch(v)) {
                      return "Mật khẩu ít nhất 6 ký tự và nhiều nhất 20 ký tự";
                    } else {
                      return null;
                    }
                  }),
              AuthButton(
                title: S.current.login,
                onPress: () async {
                  if (_formKey.currentState!.validate()) {
                    FocusScope.of(context).unfocus();
                    try {
                      String token = await Provider.of<AuthController>(context,
                              listen: false)
                          .login(
                              username:
                                  widget.userNameEditingController.text.trim(),
                              password:
                                  widget.passwordEditingController.text.trim());
                      if (token.isNotEmpty) {
                        await AuthSharedPref.auth.saveAccount(
                            username:
                                widget.userNameEditingController.text.trim(),
                            pass: widget.passwordEditingController.text.trim());
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
              ),
              Query(
                options: QueryOptions(document: gql("""query {
                                    response:configuration{
                                              code
                                              message
                                              data
                                              }
                                        }""")),
                builder: (result, {fetchMore, refetch}) {
                  if (result.hasException) {
                    return Container();
                  }
                  if (result.isLoading) {
                    return Container();
                  }
                  bool isDemo = result.data!["response"]["data"]["demo"];

                  return isDemo
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => ForgetPassword()));
                                  },
                                  child: Center(
                                    child: Text(
                                      'Quên mật khẩu',
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  )),
                              // Row(
                              //   children: [
                              //     Text(S.current.noAccount),
                              //     TextButton(
                              //         style: TextButton.styleFrom(
                              //             primary:
                              //                 Theme.of(context).primaryColor),
                              //         onPressed: () {
                              //           Navigator.push(
                              //               context,
                              //               MaterialPageRoute(
                              //                   builder: (_) =>
                              //                       RegisterScreen()));
                              //         },
                              //         child: Text(S.current.signup))
                              //   ],
                              // )
                            ],
                          ),
                        )
                      : Container();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
