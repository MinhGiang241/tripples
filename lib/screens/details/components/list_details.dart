import 'package:flutter/material.dart';
import 'package:survey/constants.dart';
import 'package:survey/generated/l10n.dart';
import 'package:survey/models/campaign.dart';
import 'package:survey/models/department.dart';
import 'package:survey/utils/extentions/ex.dart';
import 'item_detail.dart';

class ListDetails extends StatelessWidget {
  const ListDetails({
    Key? key,
    required this.refCampaignIdCampaignDto,
    required this.department,
  }) : super(key: key);
  final RefCampaignIdCampaignDto? refCampaignIdCampaignDto;
  final RefDepartmentIdDepartmentDto department;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(padding),
      children: [
        Text(
          refCampaignIdCampaignDto?.name ?? "",
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
        // ItemDetails(
        //     title: S.current.working_time, description: "8:00 - 11:00"),

        ItemDetails(
            title: S.current.begin,
            description: (refCampaignIdCampaignDto?.startTime ?? "")
                .formatDateTimeDMY()),
        ItemDetails(
            title: S.current.end,
            description:
                (refCampaignIdCampaignDto?.endTime ?? "").formatDateTimeDMY()),
      ],
    );
  }
}
