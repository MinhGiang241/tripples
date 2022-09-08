import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../data_sources/api/constants.dart';
import 'edit_password.dart';

class DetailUser extends StatelessWidget {
  final String userId;
  DetailUser(this.userId);

  @override
  Widget build(BuildContext context) {
    print(userId);
    final HttpLink httpLink = HttpLink(ApiConstants.baseUrl);

    final AuthLink authLink = AuthLink(
        getToken: () => 'Bearer ${context.read<AuthController>().token}');
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
    final queryInfo = '''
              query (\$userId : String!) {
    find_Account_dto(_id: \$userId){
      data {
        _id
        avatar
  
        createdTime
        display_name
        creator
        email
        follower_numb
        fullName
        isActive
  
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

    return GraphQLProvider(
      client: client,
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("Thông tin cá nhân",
                style: Theme.of(context).textTheme.headline6),
            elevation: 0,
          ),
          body: Query(
              options: QueryOptions(
                  document: gql(queryInfo), variables: {"userId": userId}),
              builder: (result, {fetchMore, refetch}) {
                if (result.data?['response'] != null &&
                    result.data?['response']['code'] == 1) {
                  return Center(
                      child: Text(' không lấy được thông tin tài khoản'));
                }

                final userInfo = result.data?['find_Account_dto']['data'];
                print(userInfo);

                return result.isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : result.data == null
                        ? Center(
                            child: Text(
                                'Lỗi kết nối, Không lấy được dữ liệu thông tin người dùng'),
                          )
                        : ListView(
                            padding: EdgeInsets.all(padding),
                            children: [
                              userInfo['avatar'] != null &&
                                      userInfo['avatar'] != ''
                                  ? Center(
                                      child: ClipOval(
                                        // borderRadius: BorderRadius.circular(500),
                                        child: Image.network(
                                          'http://api.triples.hoasao.demego.vn/headless/stream/upload?load=${userInfo['avatar']}',
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(),
                                      padding: EdgeInsets.symmetric(
                                          vertical: padding),
                                      height: 200,
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
                                      ? userInfo['phoneNumber']
                                      : 'chưa có số điện thoại',
                                  "Số điện thoại:"),
                              if (userInfo.containsKey('roles'))
                                buildUserInfoDisplay(
                                    userInfo['roles'][0]['display_name'] != null
                                        ? userInfo['roles'][0]['display_name']
                                        : 'chưa có chứu vụ',
                                    "Chức vụ:"),
                              Center(
                                child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: padding),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      UpdatePassword()));
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
            padding: EdgeInsets.only(bottom: 5),
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
                      // Icon(
                      //   Icons.keyboard_arrow_right,
                      //   color: Colors.grey,
                      //   size: 40.0,
                      // )
                    ]))
              ],
            )),
      );
}
