import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:survey/constants.dart';
import 'package:survey/controllers/auth/auth_controller.dart';
import 'package:survey/data_sources/api/constants.dart';
import 'package:survey/generated/l10n.dart';
import 'package:survey/screens/auth/components/auth_button.dart';
import 'package:survey/screens/auth/components/auth_input.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

class RegisterForm extends StatefulWidget {
  RegisterForm({
    Key? key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPassController,
    required this.phoneController,
  }) : super(key: key);
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPassController;
  final TextEditingController phoneController;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool showValKey = false;

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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.current.signup,
                style: Theme.of(context).textTheme.headline6?.copyWith(),
              ),
              SizedBox(
                height: padding / 2,
              ),
              AuthInput(
                controller: widget.usernameController,
                hint: S.current.user_name,
                keyboardType: TextInputType.name,
                prefixIcon: Icon(Icons.person),
                validator: (val) {
                  if (val!.isEmpty) {
                    return S.current.not_blank;
                  } else {
                    return null;
                  }
                },
              ),
              AuthInput(
                controller: widget.emailController,
                hint: S.current.email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(Icons.mail),
                validator: (val) {
                  if (val!.isEmpty) {
                    return S.current.not_blank;
                  } else if (!RegExp(
                          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$")
                      .hasMatch(val)) {
                    return "Không phải là email";
                  }
                  return null;
                },
              ),
              AuthInput(
                controller: widget.phoneController,
                hint: S.current.phone,
                keyboardType: TextInputType.number,
                prefixIcon: Icon(Icons.phone),
                validator: (val) {
                  if (val!.isEmpty) {
                    return S.current.not_blank;
                  } else {
                    return null;
                  }
                },
              ),
              AuthInput(
                blockUnicode: true,
                obscure: true,
                controller: widget.passwordController,
                hint: S.current.password,
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
                  controller: widget.passwordController,
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
                blockUnicode: true,
                obscure: true,
                controller: widget.confirmPassController,
                hint: S.current.confirm_pass,
                keyboardType: TextInputType.text,
                prefixIcon: Icon(Icons.lock),
                validator: (val) {
                  if (val != widget.passwordController.text) {
                    return S.current.not_same;
                  } else {
                    return null;
                  }
                },
              ),
              Mutation(
                options: MutationOptions(
                  document: gql("""
              mutation (\$userName: String!, \$email: String!, \$password: String!, \$phoneNumber: String!){
                    register(data: {userName: \$userName,
                                    email: \$email, 
                                    password: \$password,
                                    phoneNumber: \$phoneNumber}){
                    code
                    message 
                }
              }
              
              """),
                  update: (cache, result) {
                    return cache;
                  },
                  // or do something with the result.data on completion

                  onCompleted: (dynamic resultData) async {
                    Provider.of<AuthController>(context, listen: false)
                        .unloading();
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(resultData.containsKey("response")
                            ? resultData["response"]["message"]
                            : resultData["register"]["message"])));
                    if (resultData["register"]["code"] == 0) {
                      await Future.delayed(Duration(seconds: 1), () {
                        Navigator.pop(context);
                      });
                    }
                  },
                ),
                builder: (runMutation, result) {
                  return AuthButton(
                      title: S.current.signup,
                      onPress: () {
                        FocusScope.of(context).unfocus();
                        if (_formKey.currentState!.validate()) {
                          Provider.of<AuthController>(context, listen: false)
                              .loading();
                          runMutation({
                            "userName": widget.usernameController.text,
                            "email": widget.emailController.text,
                            "password": widget.passwordController.text,
                            "phoneNumber": widget.phoneController.text
                          });
                        }
                      });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
