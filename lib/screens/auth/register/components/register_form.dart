import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:survey/constants.dart';
import 'package:survey/controllers/auth/auth_controller.dart';
import 'package:survey/data_sources/api/constants.dart';
import 'package:survey/generated/l10n.dart';
import 'package:survey/screens/auth/components/auth_button.dart';
import 'package:survey/screens/auth/components/auth_input.dart';

class RegisterForm extends StatelessWidget {
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
                controller: usernameController,
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
                controller: emailController,
                hint: S.current.email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(Icons.abc),
                validator: (val) {
                  if (val!.isEmpty) {
                    return S.current.not_blank;
                  } else {
                    return null;
                  }
                },
              ),
              AuthInput(
                controller: phoneController,
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
                obscure: true,
                controller: passwordController,
                hint: S.current.password,
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
                controller: confirmPassController,
                hint: S.current.confirm_pass,
                keyboardType: TextInputType.text,
                prefixIcon: Icon(Icons.lock),
                validator: (val) {
                  if (val != passwordController.text) {
                    return S.current.not_same;
                  } else {
                    return null;
                  }
                },
              ),
              Mutation(
                options: MutationOptions(
                  document: gql(
                      """
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
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(resultData["register"]["message"])));
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
                            "userName": usernameController.text,
                            "email": emailController.text,
                            "password": passwordController.text,
                            "phoneNumber": phoneController.text
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
