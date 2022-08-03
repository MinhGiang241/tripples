import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../data_sources/api/constants.dart';
import 'edit_password.dart';

class DetailUser extends StatelessWidget {
  DetailUser(this.userId);
  final queryInfo = '''
              query {
    find_Account_dto(_id:"61606338c82d3b710a385a20"){
      data {
        _id
        avatar
        companyId
        createdTime
        display_name
        creator
        email
        follower_numb
        fullName
        isRoot
        isActive
        isDraft
        isLocked  
        follower_numb
        task_numb
        tenantId
        userName
        work
        phoneNumber
        roles {
          code
          display_name
          schema
          schema_label
        }
      }
      message
    }
  }
    ''';
  final String userId;

  @override
  Widget build(BuildContext context) {
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
            title: Text("Thông tin cá nhân",
                style: Theme.of(context).textTheme.headline6),
          ),
          body: Query(
              options: QueryOptions(document: gql(queryInfo)),
              builder: (result, {fetchMore, refetch}) {
                final userInfo = result.data?['find_Account_dto']['data'];
                print(result);
                return ListView(
                  padding: EdgeInsets.all(padding),
                  children: [
                    Container(
                      decoration: BoxDecoration(),
                      padding: EdgeInsets.symmetric(vertical: padding),
                      height: 180,
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.shade400,
                        radius: 25,
                        child: Icon(
                          Icons.person,
                          size: 130,
                        ),
                      ),
                    ),
                    buildUserInfoDisplay(
                      userInfo['userName'],
                      'Tài khoản:',
                    ),
                    buildUserInfoDisplay(
                      userInfo['fullName'],
                      'Họ và tên:',
                    ),
                    buildUserInfoDisplay(
                      userInfo!['email'] != null
                          ? userInfo['email']
                          : 'chưa có email',
                      'Email:',
                    ),
                    buildUserInfoDisplay(
                        userInfo!['phoneNumber'] != null
                            ? '0' + userInfo['phoneNumber']
                            : 'chưa có số điện thoại',
                        "Số điện thoại"),
                    Center(
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: padding),
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => UpdatePassord()));
                              },
                              style: TextButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor),
                              child: Text(
                                "Đổi mật khẩu",
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    ?.copyWith(color: Colors.white),
                              ))),
                    )
                  ],
                );
              })),
    );
  }

  Widget buildUserInfoDisplay(String getValue, String title) => Center(
        child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 1,
                ),
                Container(
                    width: 350,
                    height: 40,
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ))),
                    child: Row(children: [
                      Expanded(
                          child: TextButton(
                              onPressed: () {},
                              child: Text(
                                getValue,
                                style: TextStyle(fontSize: 16, height: 1.4),
                              ))),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.grey,
                        size: 40.0,
                      )
                    ]))
              ],
            )),
      );
}
