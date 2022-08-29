import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:survey/constants.dart';
import 'package:survey/models/company.dart';
import 'package:survey/models/response_list_campaign.dart';
import 'package:survey/screens/home/components/template_item.dart';

import '../../../models/department.dart';

class TemplateTabView extends StatefulWidget {
  TemplateTabView({
    Key? key,
    required this.listCampaign,
    required this.isCompleted,
    required this.onBack,
    required this.onLoading,
    required this.onRefresh,
  }) : super(key: key);
  List<ScheduleCampaign> listCampaign;
  final bool isCompleted;
  final Function(bool) onBack;
  final Function() onLoading;
  final Function() onRefresh;
  @override
  _TemplateTabViewState createState() => _TemplateTabViewState();
}

class _TemplateTabViewState extends State<TemplateTabView> {
  final TextEditingController searchController = TextEditingController();
  bool onSearch = false;
  List<ScheduleCampaign> listSearch = [];
  late RefDepartmentIdDepartmentDto selectedDepartment;
  List<RefDepartmentIdDepartmentDto> departments =
      <RefDepartmentIdDepartmentDto>[
    RefDepartmentIdDepartmentDto(id: '-1', name: '-- Tất cả --')
  ];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    selectedDepartment = departments[0];
    var resultDepartments = widget.listCampaign
        .where((element) => element.refDepartmentIdDepartmentDto != null)
        .map((element) => element.refDepartmentIdDepartmentDto!)
        .toSet()
        .toList();
    var idSet = <String?>{};
    for (var d in resultDepartments) {
      if (idSet.add(d.id)) {
        departments.add(RefDepartmentIdDepartmentDto(id: d.id!, name: d.name!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listCampaign.length > 0) {
      // if (widget.isCompleted) {
      //   widget.listCampaign.sort((a, b) => DateTime.parse(
      //           b.questionResultScheduleIdDto![0].answers![0].updatedTime!)
      //       .compareTo(DateTime.parse(
      //           a.questionResultScheduleIdDto![0].answers![0].updatedTime!)));
      // } else {
      //   widget.listCampaign.sort((a, b) => DateTime.parse(
      //           a.refCampaignIdCampaignDto!.endTime ??
      //               DateTime.now().toIso8601String())
      //       .compareTo(DateTime.parse(b.refCampaignIdCampaignDto!.endTime ??
      //           DateTime.now().toIso8601String())));
      // }
      return SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: false,
        onRefresh: () async {
          await Future.delayed(Duration(milliseconds: 1000));

          widget.onRefresh();
          _refreshController.refreshCompleted();
        },
        onLoading: () {
          widget.onLoading();
          _refreshController.loadComplete();
        },
        header: WaterDropMaterialHeader(
          backgroundColor: Theme.of(context).primaryColor,
        ),
        child: ListView(
          padding: EdgeInsets.only(top: padding, bottom: padding),
          physics: BouncingScrollPhysics(),
          children: [
            DropdownButton<RefDepartmentIdDepartmentDto>(
              isExpanded: true,
              value: selectedDepartment,
              onChanged: (RefDepartmentIdDepartmentDto? value) {
                setState(() {
                  selectedDepartment = value!;
                  // listSearch = widget.listCampaign;
                  if (value.id == '-1') {
                    onSearch = false;
                  } else {
                    listSearch.clear();
                    widget.listCampaign.forEach((element) {
                      if (element.refDepartmentIdDepartmentDto!.id ==
                          value.id) {
                        listSearch.add(element);
                      }
                    });
                    onSearch = true;
                  }

                  if (widget.isCompleted) {
                    listSearch.sort((a, b) => DateTime.parse(b
                            .questionResultScheduleIdDto![0]
                            .answers![0]
                            .updatedTime!)
                        .compareTo(DateTime.parse(a
                            .questionResultScheduleIdDto![0]
                            .answers![0]
                            .updatedTime!)));
                  } else {
                    listSearch.sort((a, b) =>
                        DateTime.parse(a.refCampaignIdCampaignDto!.endTime!)
                            .compareTo(DateTime.parse(
                                b.refCampaignIdCampaignDto!.endTime!)));
                  }
                });
              },
              items: departments.map((RefDepartmentIdDepartmentDto department) {
                return DropdownMenuItem<RefDepartmentIdDepartmentDto>(
                  value: department,
                  child: Center(
                    child: new Text(
                      department.name!,
                      style: new TextStyle(color: Colors.black),
                    ),
                  ),
                );
              }).toList(),
            ),
            ...onSearch
                ? listSearch.length > 0
                    ? List.generate(
                        listSearch.length,
                        (index) => TemplateItem(
                              campaign: listSearch[index],
                              isCompleted: widget.isCompleted,
                              onBack: widget.onBack,
                            ))
                    : List.generate(
                        1,
                        (index) => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Không có kết quả nào được tìm kiếm"),
                                  SizedBox(
                                    height: padding,
                                  ),
                                  TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          searchController.clear();
                                          listSearch.clear();
                                          onSearch = false;
                                        });
                                      },
                                      icon: Icon(Icons.replay_outlined),
                                      label: Text("Trở về mặc định"))
                                ],
                              ),
                            ))
                : List.generate(
                    widget.listCampaign.length,
                    (index) => TemplateItem(
                          campaign: widget.listCampaign[index],
                          isCompleted: widget.isCompleted,
                          onBack: widget.onBack,
                        ))
          ],
        ),
      );
    } else {
      return SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: false,
        onRefresh: () async {
          await Future.delayed(Duration(milliseconds: 1000));

          widget.onRefresh();
          _refreshController.refreshCompleted();
        },
        onLoading: () {
          widget.onLoading();
          _refreshController.loadComplete();
        },
        header: WaterDropMaterialHeader(
          backgroundColor: Theme.of(context).primaryColor,
        ),
        child: Center(
          child: widget.isCompleted
              ? Text("Chưa hoàn thành chiến dịch nào")
              : Text("Chưa có chiến dịch mới nào"),
        ),
      );
    }
  }
}

class TimeTemplateItem extends StatelessWidget {
  const TimeTemplateItem({
    Key? key,
    required this.title,
    this.item,
  }) : super(key: key);
  final String title;
  final Object? item;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyText1?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
