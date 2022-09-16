import 'package:flutter/material.dart';
import 'package:googleapis/displayvideo/v1.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:survey/constants.dart';
import 'package:survey/controllers/auth/auth_controller.dart';
import 'package:survey/data_sources/api/constants.dart';
import 'package:survey/generated/l10n.dart';
import 'package:survey/models/campaign.dart';
import 'package:survey/models/department.dart';
import 'package:survey/screens/auth/components/auth_button.dart';
import 'package:survey/screens/survey/survey_screen.dart';
import 'package:provider/provider.dart';
import '../../models/question.dart';
import '../root/root_screen.dart';
import 'components/list_details.dart';

import 'package:survey/models/response_list_campaign.dart';

class DetailsScreen extends StatefulWidget {
  final String idCampaign;
  final RefDepartmentIdDepartmentDto department;
  final bool isCompleted;
  final String idSchedule;
  final String? surveyTime;
  final String? surveyDate;
  String status;
  final List<QuestionResultScheduleIdDto>? questionResultScheduleIdDto;
  final QuestionResult? questionResults;
  final RefCampaignIdCampaignDto? campaign;
  final List<Questions>? questions;
  DetailsScreen(
      {Key? key,
      required this.idCampaign,
      required this.department,
      required this.isCompleted,
      required this.idSchedule,
      required this.questions,
      required this.surveyTime,
      required this.surveyDate,
      required this.questionResultScheduleIdDto,
      required this.questionResults,
      this.status = '',
      this.campaign})
      : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink(ApiConstants.baseUrl);

    final AuthLink authLink = AuthLink(getToken: () {
      return 'Bearer ${context.read<AuthController>().token}';
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

    const queryChangeStatus =
        '''mutation(\$scheduleId: String , \$newStatus: String){
      schedule_change_status_schedule(scheduleId: \$scheduleId ,newStatus: \$newStatus ){
        code
        message
        data
      }
    }''';
    print(widget.idSchedule);

    var status = widget.status;
    return GraphQLProvider(
      client: client,
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              S.current.details,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          body: SafeArea(
              child: widget.idCampaign.isEmpty
                  ? Center(
                      child: Text("Không có dữ liệu"),
                    )
                  : Stack(
                      children: [
                        ListDetails(
                            surveyTime: widget.surveyTime,
                            surveyDate: widget.surveyDate,
                            refCampaignIdCampaignDto: widget.campaign,
                            department: widget.department,
                            status: widget.status),
                        Mutation(
                          options: MutationOptions(
                              document: gql(queryChangeStatus),
                              onCompleted: (dynamic result) {
                                print(result);
                                if (result == null) {
                                  showDialog(
                                      context: context,
                                      builder: ((context) => AlertDialog(
                                              title: Text('Lỗi kết nối !'),
                                              content:
                                                  Text('Liểm tra kết nối mạng'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Đóng'),
                                                )
                                              ])));
                                } else if (result[
                                            'schedule_change_status_schedule']
                                        ['code'] !=
                                    0) {
                                  showDialog(
                                      context: context,
                                      builder: ((context) => AlertDialog(
                                              title: Text('có lỗi xảy ra!'),
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
                                              ])));
                                } else if (result[
                                            'schedule_change_status_schedule']
                                        ['code'] ==
                                    0) {
                                  setState(() {
                                    widget.status = 'INPROCESS';
                                  });
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: Text(
                                                "Lịch triển khai đã chuyển sang trạng thái đang chạy"),
                                            content:
                                                Text("Bắt đầu khảo sát ngay ?"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (_) =>
                                                                SurveyScreen(
                                                                  campaignId: widget
                                                                      .idCampaign,
                                                                  scheduleId: widget
                                                                      .idSchedule,
                                                                  isCompleted:
                                                                      widget
                                                                          .isCompleted,
                                                                  campaign: widget
                                                                      .campaign,
                                                                  questions: widget
                                                                          .questions
                                                                      as List<
                                                                          Questions>,
                                                                  questionResults:
                                                                      widget.questionResults
                                                                          as QuestionResult,
                                                                  questionResultScheduleIdDto:
                                                                      widget.questionResultScheduleIdDto ??
                                                                          [],
                                                                )));
                                                  },
                                                  child: Text(
                                                    "Có",
                                                    style: TextStyle(
                                                        color: Colors.blue),
                                                  )),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);

                                                    // Navigator.push(
                                                    //     context,
                                                    //     MaterialPageRoute(
                                                    //         builder: (_) =>
                                                    //             RootScreen()));
                                                  },
                                                  child: Text(
                                                    "Không",
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  )),
                                            ],
                                          ));
                                }
                              }),
                          builder: ((runMutation, result) => Positioned(
                                bottom: padding,
                                left: MediaQuery.of(context).size.width / 4,
                                right: MediaQuery.of(context).size.width / 4,
                                child: status == 'PENDING'
                                    ? AuthButton(
                                        onPress: () {
                                          runMutation({
                                            "scheduleId": widget.idSchedule,
                                            "newStatus": "INPROCESS"
                                          });
                                        },
                                        title: 'Bắt đầu khảo sát',
                                        color: Colors.amber[800])
                                    : AuthButton(
                                        onPress: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => SurveyScreen(
                                                        status: status,
                                                        campaignId:
                                                            widget.idCampaign,
                                                        scheduleId:
                                                            widget.idSchedule,
                                                        isCompleted:
                                                            widget.isCompleted,
                                                        campaign:
                                                            widget.campaign,
                                                        questions: widget
                                                                .questions
                                                            as List<Questions>,
                                                        questionResults: widget
                                                                .questionResults
                                                            as QuestionResult,
                                                        //     campaign
                                                        //             .questions ??
                                                        //         [],
                                                        questionResultScheduleIdDto:
                                                            widget.questionResultScheduleIdDto ??
                                                                [],
                                                      )));
                                        },
                                        title: status == 'COMPLETE'
                                            ? S.current.result
                                            : status == 'INPROCESS'
                                                ? "Chấm điểm"
                                                : S.current.begin,
                                      ),
                              )),
                        )
                      ],
                    ))),
    );
  }
}
