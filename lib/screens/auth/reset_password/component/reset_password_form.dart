import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:survey/screens/auth/login/login_screen.dart';

import '../../../../constants.dart';
import '../../../../data_sources/api/constants.dart';
import '../../../../generated/l10n.dart';
import '../../../root/root_screen.dart';
import '../../components/auth_button.dart';
import '../../components/auth_input.dart';

class ResetPasswordForm extends StatefulWidget {
  ResetPasswordForm(
      {Key? key,
      required this.formKey1,
      required this.formKey2,
      required this.formKey3,
      required this.email,
      required this.codeEditingController,
      required this.newPasswordEditingController,
      required this.confirmNewPasswordEditingController})
      : super(key: key);
  final String email;
  var formKey1;
  var formKey2;
  var formKey3;
  final TextEditingController codeEditingController;
  final TextEditingController newPasswordEditingController;
  final TextEditingController confirmNewPasswordEditingController;
  var disabled = false;

  // @override

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  // final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  // final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  // final GlobalKey<FormState> _formKey3 = GlobalKey<FormState>();
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
  bool notValidation = false;
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
        // child: Form(
        //     autovalidateMode: AutovalidateMode.onUserInteraction,
        //     key: _formKey,
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

            Form(
              key: widget.formKey1,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: AuthInput(
                  blockUnicode: true,
                  autoFocus: true,
                  controller: widget.codeEditingController,
                  hint: "Mã OTP",
                  keyboardType: TextInputType.number,
                  prefixIcon: Icon(Icons.mail),
                  validator: (v) {
                    // setState(() {
                    widget.disabled = false;
                    // });
                    if (v!.isEmpty) {
                      return S.current.not_blank;
                    } else {
                      return null;
                    }
                  }),
            ),
            Form(
              key: widget.formKey2,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: AuthInput(
                blockUnicode: true,
                maxLength: 20,
                controller: widget.newPasswordEditingController,
                hint: "Mật khẩu mới",
                keyboardType: TextInputType.text,
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                    onPressed: () => {
                          setState(() {
                            notValidation = true;
                            hideNewPass = !hideNewPass;
                          })
                        },
                    icon: hideNewPass
                        ? Icon(Icons.visibility_rounded)
                        : Icon(Icons.visibility_off_sharp)),
                obscure: hideNewPass,
                enableSuggestions: true,
                validator: (val) {
                  // setState(() {
                  widget.disabled = false;
                  // });
                  if (val!.isEmpty) {
                    return S.current.not_blank;
                  } else if (!RegExp(r"^[\s\S]{6,20}$").hasMatch(val)) {
                    return "Mật khẩu ít nhất 6 ký tự và nhiều nhất 20 ký tự";
                  } else if (!RegExp(r"(.*[a-z].*)").hasMatch(val) ||
                      !RegExp(r"(.*[A-Z].*)").hasMatch(val)) {
                    return "Mật khẩu ít nhất 1 chữ hoa, 1 chữ thường";
                  } else if (!RegExp(r"(.*[0-9].*)").hasMatch(val)) {
                    return "Mật khẩu ít nhất 1 chữ số";
                  } else if (!RegExp(
                          r"(?=.*[@$!%*#?&)(\-+=\[\]\{\}\.\,<>\'\`~:;\\|/])[A-Za-z\d@$!%*#?&]")
                      .hasMatch(val)) {
                    return "Mật khẩu ít nhất 1 ký tự đặc biệt";
                  } else if (RegExp(
                          r'[àÀảẢãÃáÁạẠăĂằẰẳẲẵẴắẮặẶâÂầẦẩẨẫẪấẤậẬđĐèÈẻẺẽẼéÉẹẸêÊềỀểỂễỄếẾệỆìÌỉỈĩĨíÍịỊòÒỏỎõÕóÓọỌôÔồỒổỔỗỖốỐộỘơƠờỜởỞỡỠớỚợỢùÙủỦũŨúÚụỤưƯừỪửỬữỮứỨựỰỳỲỷỶỹỸýÝỵỴ]')
                      .hasMatch(val)) {
                    return 'Không nhập tiếng việt có dấu!';
                  }
                  return null;
                },
              ),
            ),
            Form(
              key: widget.formKey3,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: AuthInput(
                  blockUnicode: true,
                  maxLength: 20,
                  enableSuggestions: true,
                  controller: widget.confirmNewPasswordEditingController,
                  hint: "Nhập lại mật khẩu mới",
                  keyboardType: TextInputType.text,
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                      onPressed: () => {
                            setState(() {
                              notValidation = true;
                              hideConfirmPass = !hideConfirmPass;
                            })
                          },
                      icon: hideConfirmPass
                          ? Icon(Icons.visibility_rounded)
                          : Icon(Icons.visibility_off_sharp)),
                  obscure: hideConfirmPass,
                  validator: (v) {
                    // setState(() {
                    widget.disabled = false;
                    if (v!.isEmpty) {
                      return S.current.not_blank;
                    } else if (v != widget.newPasswordEditingController.text) {
                      return 'Mật khẩu không khớp';
                    } else {
                      return null;
                    }
                  }),
            ),
            // if (showValKey)
            //   FlutterPwValidator(
            //       controller: widget.newPasswordEditingController,
            //       minLength: 6,
            //       uppercaseCharCount: 1,
            //       numericCharCount: 1,
            //       specialCharCount: 1,
            //       width: 400,
            //       height: 150,
            //       onSuccess: () {
            //         print("Matched");
            //       }),
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
                            MaterialPageRoute(builder: (_) => RootScreen()));
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
                        var form_1Validate =
                            widget.formKey1.currentState!.validate();
                        var form_2Validate =
                            widget.formKey2.currentState!.validate();
                        var form_3Validate =
                            widget.formKey3.currentState!.validate();
                        if (form_1Validate &&
                            form_2Validate &&
                            form_3Validate) {
                          print('submit');
                          FocusScope.of(context).unfocus();

                          runMutation({
                            "mailTo": widget.email,
                            "new_pw": widget.newPasswordEditingController.text,
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
        ));
  }
}
