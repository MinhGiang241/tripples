import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:survey/constants.dart';
import 'package:survey/controllers/auth/auth_controller.dart';
import 'package:survey/data_sources/api/constants.dart';
import 'package:survey/models/response_list_campaign.dart';
import 'components/home_appbar.dart';
import 'components/home_tabbar.dart';
import 'components/template_tab_view.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController tabController;
  final String queryMe = """mutation {
    authorization_me{
      code
      message
      data
      }
    }""";
  final String queryTemplate = """
  mutation {
     scheduleresult_get_questions_and_answers_by_schedule  {
        code
        message
        data
    }
}


  """;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

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
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          //appBar: HomeAppBar(),
          body: Query(
            options: QueryOptions(document: gql(queryMe)),
            builder: (meResult, {fetchMore, refetch}) {
              print(meResult);

              if (meResult.isLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (meResult.data != null) if (meResult.data!['authorization_me']
                      ['data'] ==
                  null) {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Tài khoản đã bị xoá hoặc không có dữ liệu"),
                      TextButton(
                          onPressed: () async {
                            await context.read<AuthController>().logOut();
                          },
                          child: Text("Đăng nhập lại"))
                    ]);
                // Center(
                //   child: Text("Tài khoản đã bị xoá hoặc không có dữ liệu"),
                // );
              }
              var isRoot =
                  meResult.data!['authorization_me']['data']['isRoot'] ?? false;
              context.read<AuthController>().idUser =
                  meResult.data!['authorization_me']['data']['_id'] as String;
              var filter = {
                "filter": {
                  "withRecords": true,
                  "group": {
                    "children": [
                      {
                        "id": "agent",
                        "value":
                            meResult.data!['authorization_me']['data'] != null
                                ? meResult.data!['authorization_me']['data']
                                        ['userName'] ??
                                    ""
                                : ""
                      },
                      {
                        "id": "survey_date",
                        "value": DateTime(DateTime.now().year,
                                DateTime.now().month, DateTime.now().day)
                            .toUtc()
                            .toString()
                      }
                    ]
                  }
                }
              };

              return Column(
                children: [
                  SizedBox(height: AppBar().preferredSize.height),
                  HomeAppBar(
                      name: meResult.data!["authorization_me"]["data"] != null
                          ? meResult.data!["authorization_me"]["data"]
                                  ["fullName"] ??
                              meResult.data!["authorization_me"]["data"]
                                  ["userName"] ??
                              "Tên"
                          : "",
                      userId: meResult.data!["authorization_me"]["data"] != null
                          ? meResult.data!["authorization_me"]["data"]["_id"]
                          : "id"
                      // user: meResult.data!["authorization_me"]["data"],
                      ),
                  SizedBox(height: padding),
                  HomeTabBar(tabController: tabController),
                  Expanded(
                      child: Query(
                    options: QueryOptions(
                        document: gql(queryTemplate), variables: filter),
                    builder: (result, {fetchMore, refetch}) {
                      if (result.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      ResponseListTemplate responseListTemplate =
                          ResponseListTemplate.fromJson(result.data!);
                      List<ScheduleCampaign> listInprogress = [];
                      List<ScheduleCampaign> listCompleted = [];
                      for (int i = 0;
                          i <
                              responseListTemplate
                                  .querySchedulesDto!.data!.length;
                          i++) {
                        if (responseListTemplate.querySchedulesDto!.data![i]
                                    .questionResult !=
                                null &&
                            responseListTemplate.querySchedulesDto!.data![i]
                                    .questionResult?.answers !=
                                null &&
                            responseListTemplate.querySchedulesDto!.data![i]
                                    .questionResult?.answers!.length !=
                                0) {
                          listCompleted.add(
                              responseListTemplate.querySchedulesDto!.data![i]);
                        } else {
                          listInprogress.add(
                              responseListTemplate.querySchedulesDto!.data![i]);
                        }
                      }
                      return TabBarView(
                          controller: tabController,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            TemplateTabView(
                              listCampaign: listInprogress,
                              isCompleted: false,
                              onBack: (val) {
                                if (val == true) setState(() {});
                              },
                              onLoading: _onLoading,
                              onRefresh: _onRefresh,
                            ),
                            TemplateTabView(
                              listCampaign: listCompleted,
                              onLoading: _onLoading,
                              onRefresh: _onRefresh,
                              isCompleted: true,
                              onBack: (val) {
                                if (val == true) setState(() {});
                              },
                            ),
                          ]);
                    },
                  ))
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _onRefresh() async {
    // monitor network fetch
    // if failed,use refreshFailed()
    if (mounted) setState(() {});
  }

  void _onLoading() async {
    if (mounted) setState(() {});
  }
}
