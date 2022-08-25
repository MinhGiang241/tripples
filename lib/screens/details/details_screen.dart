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
import 'components/list_details.dart';

import 'package:survey/models/response_list_campaign.dart';

class DetailsScreen extends StatelessWidget {
  final String idCampaign;
  final RefDepartmentIdDepartmentDto department;
  final bool isCompleted;
  final String idSchedule;
  final List<QuestionResultScheduleIdDto>? questionResultScheduleIdDto;
  final QuestionResult? questionResults;
  final RefCampaignIdCampaignDto? campaign;
  final List<Questions>? questions;
  const DetailsScreen(
      {Key? key,
      required this.idCampaign,
      required this.department,
      required this.isCompleted,
      required this.idSchedule,
      required this.questions,
      required this.questionResultScheduleIdDto,
      required this.questionResults,
      this.campaign})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(" id campain: " + idCampaign);

    // print(idCampaign);
    // print(department);
    // print(idSchedule);
    // print(questionResultScheduleIdDto);

    return Scaffold(
        appBar: AppBar(
          title: Text(
            S.current.details,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        body: SafeArea(
            child: idCampaign.isEmpty
                ? Center(
                    child: Text("Không có dữ liệu"),
                  )
                : Stack(
                    children: [
                      ListDetails(
                        refCampaignIdCampaignDto: campaign,
                        department: department,
                      ),
                      Positioned(
                        bottom: padding,
                        left: MediaQuery.of(context).size.width / 4,
                        right: MediaQuery.of(context).size.width / 4,
                        child: AuthButton(
                          onPress: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => SurveyScreen(
                                          campaignId: idCampaign,
                                          scheduleId: idSchedule,
                                          isCompleted: isCompleted,
                                          campaign: campaign,
                                          questions:
                                              questions as List<Questions>,
                                          questionResults:
                                              questionResults as QuestionResult,
                                          //     campaign
                                          //             .questions ??
                                          //         [],
                                          questionResultScheduleIdDto:
                                              questionResultScheduleIdDto ?? [],
                                        )));
                          },
                          title:
                              isCompleted ? S.current.result : S.current.start,
                        ),
                      )
                    ],
                  )));
  }
}
