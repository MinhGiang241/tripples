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
  final ResponseListTemplate? listTemplate;
  HomeScreen({this.listTemplate});
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

  List<ScheduleCampaign> listInprogress = [];
  List<ScheduleCampaign> listCompleted = [];
  @override
  void initState() {
    // responseListTemplate = widget.listTemplate;
    // if (responseListTemplate != null) {
    //   for (int i = 0;
    //       i < responseListTemplate!.querySchedulesDto!.data!.length;
    //       i++) {
    //     if (responseListTemplate!.querySchedulesDto!.data![i].questionResult !=
    //             null &&
    //         responseListTemplate!
    //                 .querySchedulesDto!.data![i].questionResult?.answers !=
    //             null &&
    //         responseListTemplate!.querySchedulesDto!.data![i].questionResult
    //                 ?.answers!.length !=
    //             0) {
    //       listCompleted.add(responseListTemplate!.querySchedulesDto!.data![i]);
    //     } else {
    //       listInprogress.add(responseListTemplate!.querySchedulesDto!.data![i]);
    //     }
    //   }
    // }

    super.initState();

    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(ApiConstants.baseUrl);

    final AuthLink authLink = AuthLink(
        getToken: () => 'Bearer ${context.read<AuthController>().token}');
    final Link link = authLink.concat(httpLink);
    final cl = GraphQLClient(
      link: link,
      // The default store is the InMemoryStore, which does NOT persist to disk
      cache: GraphQLCache(store: HiveStore()),
    );
    ValueNotifier<GraphQLClient> client = ValueNotifier(cl);
    setState(() {
      listInprogress = [];
      listCompleted = [];
    });
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
                          ResponseListTemplate.from(result.data);

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
                                  print('onback');
                                  if (val == true) setState(() {});
                                },
                                onLoading: _onLoading,
                                onRefresh: () {
                                  _onRefresh(cl, filter, queryTemplate);
                                }),
                            TemplateTabView(
                              listCampaign: listCompleted,
                              onLoading: _onLoading,
                              onRefresh: () =>
                                  _onRefresh(cl, filter, queryTemplate),
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

// void refresh = useMutation(
//       MutationOptions(
//         document: gql(query), // this is the mutation string you just created
//         // you can update the cache based on results
//         // update: (GraphQLDataProxy cache, QueryResult result)  {
//         //   return cache;
//         // },
//         // or do something with the result.data on completion

//         onCompleted: (dynamic resultData) {
//           setState(() {
//             ResponseListTemplate responseListTemplate =
//                 ResponseListTemplate.from(resultData.data);

//             for (int i = 0;
//                 i < responseListTemplate.querySchedulesDto!.data!.length;
//                 i++) {
//               if (responseListTemplate
//                           .querySchedulesDto!.data![i].questionResult !=
//                       null &&
//                   responseListTemplate.querySchedulesDto!.data![i]
//                           .questionResult?.answers !=
//                       null &&
//                   responseListTemplate.querySchedulesDto!.data![i]
//                           .questionResult?.answers!.length !=
//                       0) {
//                 listCompleted
//                     .add(responseListTemplate.querySchedulesDto!.data![i]);
//               } else {
//                 listInprogress
//                     .add(responseListTemplate.querySchedulesDto!.data![i]);
//               }
//             }
//           });
//         },

//       ),
//     )

  void _onRefresh(
      GraphQLClient client, Map<String, Object> filter, String mutation) async {
    var query = QueryOptions(document: gql(mutation), variables: filter);

    var result = await client.query(query);
    print(result);
    setState(() {});

    if (mounted) setState(() {});
  }

  void _onLoading() {
    print('onloading');
    if (mounted) setState(() {});
  }
}
