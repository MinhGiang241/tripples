import 'package:flutter/material.dart';
import 'package:survey/constants.dart';
import 'package:survey/models/response_list_campaign.dart';
import 'package:survey/screens/details/details_screen.dart';
import 'package:survey/utils/extentions/ex.dart';

class TemplateItem extends StatelessWidget {
  const TemplateItem({
    Key? key,
    required this.campaign,
    required this.isCompleted,
    required this.onBack,
    this.status,
  }) : super(key: key);
  final ScheduleCampaign campaign;
  final bool isCompleted;
  final String? status;
  final Function(bool) onBack;

  @override
  Widget build(BuildContext context) {
    print(status);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding / 2, horizontal: padding),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => DetailsScreen(
                        status: campaign.status != null
                            ? campaign.status as String
                            : '',
                        questions: campaign.questions,
                        idSchedule: campaign.sId!,
                        idCampaign: campaign.refCampaignIdCampaignDto != null
                            ? campaign.refCampaignIdCampaignDto!.cid ?? ""
                            : "",
                        department: campaign.refDepartmentIdDepartmentDto!,
                        campaign: campaign.refCampaignIdCampaignDto,
                        isCompleted: isCompleted,
                        questionResultScheduleIdDto:
                            campaign.questionResultScheduleIdDto,
                        questionResults: campaign.questionResult,
                      ))).then((value) {
            onBack(true);
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              campaign.refCompanyIdCompanyDto!.name ?? "",
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(
              height: padding,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Wrap(
                    children: [
                      Text(
                        "Chi nhánh : ",
                        style: Theme.of(context).textTheme.caption?.copyWith(
                            height: 1.5, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${campaign.refDepartmentIdDepartmentDto!.name ?? ''}",
                        style: Theme.of(context).textTheme.caption?.copyWith(
                            height: 1.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Expanded(
                  flex: 3,
                  child: Wrap(
                    children: [
                      Text(
                        isCompleted ? "Thời gian gửi : " : "Thời gian : ",
                        style: Theme.of(context).textTheme.caption?.copyWith(
                            height: 1.5, fontWeight: FontWeight.bold),
                      ),
                      isCompleted
                          ? Text(
                              "${campaign.questionResult?.answers?[0].updatedTime!.formatDateTimeHmDMY()}",
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(
                                      height: 1.5, fontWeight: FontWeight.bold),
                            )
                          : Text(
                              "${(campaign.refCampaignIdCampaignDto!.startTime ?? DateTime.now().toIso8601String()).formatDateTimeDMY()} - ${(campaign.refCampaignIdCampaignDto!.endTime ?? DateTime.now().toIso8601String()).formatDateTimeDMY()}",
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(
                                      height: 1.5, fontWeight: FontWeight.bold),
                            ),
                      Text("Ngày hẹn : ",
                          style: Theme.of(context).textTheme.caption?.copyWith(
                              height: 1.5, fontWeight: FontWeight.bold)),
                      Text(
                        "${campaign.surveyTime} - ${(campaign.surveyDate ?? DateTime.now().toIso8601String()).formatDateTimeDMY()}",
                        style: Theme.of(context).textTheme.caption?.copyWith(
                            height: 1.5, fontWeight: FontWeight.bold),
                      ),
                      // Text(
                      //   campaign.sId != null ? campaign.sId as String : '',
                      //   style: Theme.of(context).textTheme.caption?.copyWith(
                      //       height: 1.5, fontWeight: FontWeight.bold),
                      // )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: padding / 2,
            ),
            // isCompleted ||
            status == 'COMPLETE'
                ? Text(
                    "Đã hoàn thành",
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        ?.copyWith(height: 1.5, color: Colors.green),
                  )
                : status == 'INPROCESS'
                    ? Text(
                        "Đang chạy",
                        style: Theme.of(context)
                            .textTheme
                            .caption
                            ?.copyWith(height: 1.5, color: Colors.amber[600]),
                      )
                    : Text(
                        "Chưa bắt đầu",
                        style: Theme.of(context)
                            .textTheme
                            .caption
                            ?.copyWith(height: 1.5, color: Colors.grey[600]),
                      ),
            SizedBox(
              height: padding / 2,
            ),
            Divider(
              thickness: 2,
            )
          ],
        ),
      ),
    );
  }
}
