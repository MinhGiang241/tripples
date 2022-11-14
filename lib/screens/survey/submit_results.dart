import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth/auth_controller.dart';
import '../../data_sources/api/constants.dart';
import '../../models/question.dart';
import '../auth/components/auth_button.dart';
import '../root/root_screen.dart';
import 'models/model_answer.dart';

class SubmitResults extends StatefulWidget {
  const SubmitResults({
    Key? key,
    required this.listResult,
    required this.questions,
    required this.data,
    required this.surveyDate,
  }) : super(key: key);

  final List<ResultsList> listResult;
  final List<Questions> questions;
  final List<dynamic> data;
  final String surveyDate;
  @override
  State<SubmitResults> createState() => _SubmitResultsState();
}

class _SubmitResultsState extends State<SubmitResults> {
  bool disabled = false;
  @override
  Widget build(BuildContext context) {
    final mutationData = """
  mutation (\$data:Dictionary){
   scheduleresult_save_schedule_result (data: \$data ) {
        code
        message
        data
    }
  }
    """;

    final String changeStatus = """
        mutation(\$scheduleId: String , \$newStatus: String){
      schedule_change_status_schedule(scheduleId: \$scheduleId ,newStatus: \$newStatus ){
        code
        message
        data
      }
    }
  """;
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả'),
        elevation: 1,
      ),
      body: Mutation(
        options: MutationOptions(
            document: gql(mutationData),
            onCompleted: (data) async {
              disabled = false;
              await showDialog(
                context: context,
                builder: (_) {
                  if (data == null) {
                    return AlertDialog(
                        title: Text('Có lỗi xảy ra'),
                        content: Text("Kiểm tra lại kết nối"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Đóng'))
                        ]);
                  }
                  if (data["scheduleresult_save_schedule_result"]["code"] !=
                      0) {
                    return AlertDialog(
                        title: Text('Có lỗi xảy ra'),
                        content: Text("Không gửi kết quả lên được "),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Đóng'))
                        ]);
                  }
                  return AlertDialog(
                    title: data["scheduleresult_save_schedule_result"]
                                    ["code"] ==
                                0 &&
                            data["scheduleresult_save_schedule_result"]["data"]
                                    ["failure"] ==
                                0
                        ? Text("Thành công")
                        : Text("Thất bại"),
                    content:
                        data["scheduleresult_save_schedule_result"]["code"] == 0
                            ? Text(data["scheduleresult_save_schedule_result"]
                                    ["data"]["message"]
                                .split('<')
                                .first)
                            : Text(data["scheduleresult_save_schedule_result"]
                                ["message"]),
                    actions: [
                      TextButton(
                          onPressed: () {
                            if (data["scheduleresult_save_schedule_result"]
                                    ["code"] !=
                                0) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pop(context, true);
                            }
                          },
                          child: Text("OK"))
                    ],
                  );
                },
              ).then((value) {
                if (value != null) {
                  if (value == true) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GraphQLProvider(
                            client: client,
                            child: Mutation(
                              options: MutationOptions(
                                  document: gql(changeStatus),
                                  onCompleted: (result) {
                                    disabled = false;
                                    if (result == null) {
                                      showDialog(
                                          context: context,
                                          builder: (_) {
                                            return AlertDialog(
                                              title: Text('Có lỗi xảy ra '),
                                              content: Text(
                                                  'xem lại kết nối internet'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Đóng'),
                                                )
                                              ],
                                            );
                                          }).then((value) {
                                        disabled = false;
                                      });
                                    } else if (result[
                                                'schedule_change_status_schedule']
                                            ['code'] !=
                                        0) {
                                      // print(widget.campaign);
                                      showDialog(
                                          context: context,
                                          builder: (_) {
                                            return AlertDialog(
                                              title: Text(
                                                  'Không chuyển trạng thái chiến dịch được'),
                                              content: Text(
                                                  result['schedule_change_status_schedule']
                                                          ['message']
                                                      .split(':')
                                                      .last),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Đóng'),
                                                )
                                              ],
                                            );
                                          });
                                    } else {}
                                  }),
                              builder: (runMutation, result) {
                                var dta = DateTime.parse(widget.surveyDate);

                                return RootScreen(
                                  year: dta.year,
                                  month: dta.month,
                                );
                              },
                            ),
                          ),
                        ),
                        (route) => route.isFirst);
                  }
                }
              });
            }),
        builder: (runMutation, result) => Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(
                horizontal: 12,
              ),
              // height: MediaQuery.of(context)
              //         .size
              //         .height *
              //     0.7,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(
                    height: 24,
                  ),
                  Row(
                    children: [
                      // IconButton(
                      //   onPressed: () {
                      //     Navigator.pop(context);
                      //   },
                      //   icon: const Icon(Icons.close),
                      // ),
                      const Spacer(),
                      Text(
                        'Kết quả',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // IconButton(
                      //   onPressed: () {
                      //     runMutation({"data": widget.data});
                      //     setState(() {
                      //       disabled = true;
                      //     });
                      //     // submitResult();
                      //   },
                      //   icon: const Icon(
                      //     Icons.check,
                      //     color: Colors.blue,
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Table(
                    border: TableBorder.symmetric(
                      inside: BorderSide(width: 2),
                      outside: BorderSide(width: 2),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(7),
                      2: FlexColumnWidth(2)
                    },
                    children: [
                      TableRow(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.orange[100],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'STT',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Câu hỏi',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Điểm số',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ]),
                      ...widget.listResult.asMap().entries.map(
                        (e) {
                          var q = widget.questions.firstWhere((element) =>
                              element.questID == e.value.questionTemplateId);
                          return TableRow(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.cyan[100],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5),
                                child: Text(
                                  (e.key + 1).toString(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5),
                                child: Text(
                                  q.title!,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    '${e.value.score.toStringAsFixed(1)} / ${q.maxScore.toStringAsFixed(1)}',
                                    textAlign: TextAlign.center),
                              )
                            ],
                          );
                        },
                      )
                    ],
                  ),
                  SizedBox(
                    height: 80,
                  )
                ],
              ),
            ),
            Positioned(
              // top: MediaQuery.of(context).size.height - 10,
              bottom: 10,
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  width: MediaQuery.of(context).size.width,
                  child: AuthButton(
                    disabled: disabled,
                    onPress: () {
                      runMutation({'data': widget.data});
                      setState(() {
                        disabled = true;
                      });
                    },
                    title: "Gửi kết quả",
                  )),
            )
          ],
        ),
      ),
    );
  }
}
