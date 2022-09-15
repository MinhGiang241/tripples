import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:survey/constants.dart';
import 'package:survey/generated/l10n.dart';
import 'package:survey/models/campaign.dart';
import 'package:survey/models/department.dart';
import 'package:survey/utils/extentions/ex.dart';
import '../../../controllers/auth/auth_controller.dart';
import '../../../data_sources/api/constants.dart';
import 'item_detail.dart';

class ListDetails extends StatelessWidget {
  const ListDetails(
      {Key? key,
      required this.refCampaignIdCampaignDto,
      required this.department,
      required this.status,
      required this.surveyDate})
      : super(key: key);
  final RefCampaignIdCampaignDto? refCampaignIdCampaignDto;
  final RefDepartmentIdDepartmentDto department;
  final String? surveyDate;
  final String status;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(padding),
      children: [
        Text(
          (refCampaignIdCampaignDto?.name ?? "") +
              " (${(refCampaignIdCampaignDto?.startTime ?? "").formatDateTimeDMY()} -${(refCampaignIdCampaignDto?.endTime ?? "").formatDateTimeDMY()})",
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(
          height: padding,
        ),
        if (refCampaignIdCampaignDto?.description != null)
          ItemDetails(
              title: S.current.campaign_description,
              description: refCampaignIdCampaignDto?.description ?? ""),
        ItemDetails(
            title: S.current.customer, description: department.company ?? ''),
        ItemDetails(
            title: S.current.branch, description: department.name ?? ""),
        ItemDetails(
            title: S.current.address, description: department.address ?? ""),
        ItemDetails(
            title: 'Ngày- giờ khảo sát',
            description: (surveyDate ?? "").formatDateTimeHmDMY()),
        ItemDetails(
          title: "Trạng thái lịch triển khai",
          description: status == 'PENDING'
              ? 'Chưa bắt đầu'
              : status == 'INPROCESS'
                  ? 'Đang chạy'
                  : 'Đã hoàn thành',
        ),
      ],
    );
  }
}
