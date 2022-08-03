// ignore_for_file: deprecated_member_use

import "package:flutter/material.dart";
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:survey/constants.dart';

import '../../controllers/auth/auth_controller.dart';
import '../../data_sources/api/constants.dart';
import 'user_profile.dart';

class UpdatePassord extends StatefulWidget {
  UpdatePassord();
  @override
  State<UpdatePassord> createState() => _UpdatePassord();
}

class _UpdatePassord extends State<UpdatePassord> {
  final oldPasController = TextEditingController();
  final newPasCotroller = TextEditingController();
  final confirmNewPasCotroller = TextEditingController();

  void submitData() {
    print(oldPasController.text);
    print(newPasCotroller.text);
    print(confirmNewPasCotroller.text);
    Navigator.of(context).pop();
  }

  SnackBar createSnackBar(String message) {
    return SnackBar(
        content: Text(
      message,
      style: TextStyle(color: Colors.white),
    ));
  }

  void onSubmit(runMutation, result) async {
    if (_formKey.currentState!.validate()) {
      print('validated');
      print(result);
      // ignore: await_only_futures
      var r = await runMutation(
          {"oldpass": oldPasController.text, "newpass": newPasCotroller.text});
    }
  }

  void onCompleteMutation(data) {
    var message = data["authorization_change_password"]["message"];
    if (message == null) {
      final snackBar = createSnackBar("Đã đổi mật khẩu thành công");
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pop(context);
    } else {
      final snackBar = createSnackBar(message);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var changePassword = '''
      mutation  (\$oldpass: String, \$newpass: String){
    authorization_change_password (old_pw:\$oldpass , new_pw:\$newpass){
  	  message
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
        cache: GraphQLCache(store: HiveStore()),
      ),
    );

    return GraphQLProvider(
      client: client,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Đổi mật khẩu",
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        body: Card(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextField(
                    decoration: const InputDecoration(labelText: "Mật khẩu cũ"),
                    controller: oldPasController,
                    onSubmitted: (_) => submitData),
                TextField(
                    decoration: const InputDecoration(
                      labelText: "Mật khẩu mới",
                      errorText: null,
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.0),
                      ),
                    ),
                    controller: newPasCotroller,
                    onSubmitted: (_) => submitData),
                TextFormField(
                  validator: (val) {
                    // ignore: unrelated_type_equality_checks
                    if (val == newPasCotroller.text) {
                      return null;
                    } else {
                      return 'Password không khớp';
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: "Nhập lại mật khẩu mới",
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1.0),
                    ),
                  ),
                  controller: confirmNewPasCotroller,
                  // onSubmitted: (_) => submitData
                ),
                Mutation(
                  options: MutationOptions(
                    document: gql(changePassword),
                    onCompleted: (data) => onCompleteMutation(data),
                  ),
                  builder: ((runMutation, result) => Padding(
                        padding: EdgeInsets.symmetric(vertical: padding),
                        child: ElevatedButton(
                            onPressed: () => onSubmit(runMutation, result),
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).primaryColor),
                            child: Text(
                              "Đổi mật khẩu",
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  ?.copyWith(color: Colors.white),
                            )),
                      )),
                )
              ],
            ),
          ),
        )),
      ),
    );
  }
}
