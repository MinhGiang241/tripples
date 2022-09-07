import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:survey/constants.dart';
import 'package:survey/controllers/auth/auth_controller.dart';
import 'package:survey/data_sources/api/constants.dart';
import 'package:survey/models/response_list_campaign.dart';
import 'package:survey/screens/survey/controllers/answer_controller.dart';
import 'components/home_appbar.dart';
import 'components/home_tabbar.dart';
import 'components/month_year_picker.dart';
import 'components/template_tab_view.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController tabController;
  final String queryMe = """mutation {
     authorization_get_user_me  {
        code
        message
        data
    }
}
        """;
  final String queryTemplate = """
  mutation (\$year: Float, \$month: Float){
  scheduleresult_get_questions_and_answers_by_schedule(year: \$year, month: \$month){
    code
    data
    message
  }
}
  """;

  List<ScheduleCampaign> listInprogress = [];
  List<ScheduleCampaign> listCompleted = [];
  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);
  }

  int year = DateTime.now().year;
  int month = DateTime.now().month;
  String avatar = '';
  void selectMonthAndYear(int selectedYear, int selectedMonth) {
    setState(() {
      year = selectedYear;
      month = selectedMonth;
    });
    Future.delayed(Duration(milliseconds: 100), () {});
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
      cache: GraphQLCache(),
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
              if (meResult.data != null) if (meResult
                      .data!['authorization_get_user_me']['data'] ==
                  null) {
                print(meResult);
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Tài khoản đã bị xoá hoặc không có dữ liệu"),
                      TextButton(
                          onPressed: () async {
                            await context
                                .read<AuthController>()
                                .logOut(context);
                          },
                          child: Text("Đăng nhập lại"))
                    ]);
              }

              avatar = meResult.data != null &&
                      meResult.data!['authorization_get_user_me']['data']
                              ['avatar'] !=
                          null
                  ? meResult.data!['authorization_get_user_me']['data']
                      ['avatar']
                  : '';
              var isRoot = meResult.data != null &&
                      meResult.data!['authorization_get_user_me']['data']
                          ['isRoot']
                  ? meResult.data!['authorization_get_user_me']['data']
                      ['isRoot']
                  : false;

              context.read<AuthController>().idUser = meResult.data != null
                  ? meResult.data!['authorization_get_user_me']['data']['_id']
                      as String
                  : null;
              var filter = {
                // "filter": {
                //   "withRecords": true,
                //   "group": {
                //     "children": [
                //       {
                //         "id": "agent",
                //         "value": meResult.data!['authorization_get_user_me']
                //                     ['data'] !=
                //                 null
                //             ? meResult.data!['authorization_get_user_me']
                //                     ['data']['userName'] ??
                //                 ""
                //             : ""
                //       },
                //       {
                //         "id": "survey_date",
                //         "value": DateTime(DateTime.now().year,
                //                 DateTime.now().month, DateTime.now().day)
                //             .toUtc()
                //             .toString()
                //       }
                //     ]
                //   }
                // }
              };

              return Column(
                children: [
                  SizedBox(height: AppBar().preferredSize.height),
                  HomeAppBar(
                    name: meResult.data != null
                        ? meResult.data!["authorization_get_user_me"]["data"] !=
                                null
                            ? meResult.data!["authorization_get_user_me"]
                                    ["data"]["fullName"] ??
                                meResult.data!["authorization_get_user_me"]
                                    ["data"]["userName"] ??
                                "Tên"
                            : ""
                        : "",
                    userId: meResult.data != null
                        ? meResult.data!["authorization_get_user_me"]["data"] !=
                                null
                            ? meResult.data!["authorization_get_user_me"]
                                ["data"]["_id"]
                            : "id"
                        : "id",
                    avatar: avatar,
                    // user: meResult.data!["authorization_me"]["data"],
                  ),
                  SizedBox(height: padding),
                  HomeTabBar(tabController: tabController),
                  Expanded(
                      child: Query(
                    options: QueryOptions(
                        document: gql(queryTemplate),
                        variables: {'year': year, 'month': month}),
                    builder: (result, {fetchMore, refetch}) {
                      if (result.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      listCompleted = [];
                      listInprogress = [];
                      if (result.data == null) {
                        RefreshController _refreshController =
                            RefreshController(initialRefresh: false);
                        return SmartRefresher(
                            controller: _refreshController,
                            enablePullDown: true,
                            enablePullUp: false,
                            onRefresh: () {
                              setState(() {});
                            },
                            child: Center(
                                child: Text(
                                    'Lỗi kết nối ,không lấy được dữ liệu lịch triển khai')));
                      }
                      ResponseListTemplate? responseListTemplate =
                          ResponseListTemplate.from(result.data);

                      print(responseListTemplate);
                      if (responseListTemplate.querySchedulesDto == null) {}

                      if (responseListTemplate.querySchedulesDto != null &&
                          responseListTemplate.querySchedulesDto!.data !=
                              null) {
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
                            listCompleted.add(responseListTemplate
                                .querySchedulesDto!.data![i]);
                          } else {
                            listInprogress.add(responseListTemplate
                                .querySchedulesDto!.data![i]);
                          }
                        }
                      }

                      // Provider.of<AnswerController>(context);

                      return TabBarView(
                          controller: tabController,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            TemplateTabView(
                                listCampaign: listInprogress,
                                isCompleted: false,
                                selectMonthAndYear: selectMonthAndYear,
                                year: year,
                                month: month,
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
                              year: year,
                              month: month,
                              selectMonthAndYear: selectMonthAndYear,
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

  void _onRefresh(GraphQLClient client, filter, String mutation) async {
    // var query = QueryOptions(document: gql(mutation));

    // var result = await client.query(query);
    // print(result);

    if (mounted) setState(() {});
  }

  void _onLoading() {
    print('onloading');
    if (mounted) setState(() {});
  }
}
