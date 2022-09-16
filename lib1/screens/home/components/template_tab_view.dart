import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:survey/constants.dart';
import 'package:survey/models/company.dart';
import 'package:survey/models/response_list_campaign.dart';
import 'package:survey/screens/home/components/month_year_picker.dart';
import 'package:survey/screens/home/components/template_item.dart';

import '../../../models/department.dart';

class TemplateTabView extends StatefulWidget {
  TemplateTabView(
      {Key? key,
      required this.listCampaign,
      required this.isCompleted,
      required this.onBack,
      required this.onLoading,
      required this.onRefresh,
      required this.selectMonthAndYear,
      required this.year,
      required this.month})
      : super(key: key);
  List<ScheduleCampaign> listCampaign;
  final bool isCompleted;
  final Function(bool) onBack;
  final Function() onLoading;
  final Function() onRefresh;
  final int year;
  final int month;
  final Function selectMonthAndYear;

  @override
  _TemplateTabViewState createState() => _TemplateTabViewState();
}

class _TemplateTabViewState extends State<TemplateTabView>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController searchController = TextEditingController();
  bool onSearch = false;
  List<ScheduleCampaign> listSearch = [];
  late RefCompanyIdCompanyDto selectedCompany;
  List<RefCompanyIdCompanyDto> companies = <RefCompanyIdCompanyDto>[
    RefCompanyIdCompanyDto(id: '-1', name: '-- Tất cả --')
  ];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool loading = false;

  @override
  void initState() {
    selectedCompany = companies[0];
    var resultCompanies = widget.listCampaign
        .where((element) => element.refCompanyIdCompanyDto != null)
        .map((element) => element.refCompanyIdCompanyDto!)
        .toSet()
        .toList();
    var idSet = <String?>{};
    for (var d in resultCompanies) {
      if (idSet.add(d.id)) {
        companies.add(RefCompanyIdCompanyDto(id: d.id!, name: d.name!));
      }
    }
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

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

      print(widget.listCampaign);
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
            ChooseMonthYear(
                year: widget.year,
                month: widget.month,
                selectMonthAndYear: widget.selectMonthAndYear),
            // loading ? LinearProgressIndicator() : widget.child,
            DropdownButton<RefCompanyIdCompanyDto>(
              onTap: () async {
                print('tab');
                await Future.delayed(Duration(seconds: 1000));
              },
              isExpanded: true,
              // autofocus: true,
              // elevation: 1,pp
              value: selectedCompany,
              onChanged: (RefCompanyIdCompanyDto? value) async {
                setState(() {
                  selectedCompany = value!;
                  // listSearch = widget.listCampaign;
                  if (value.id == '-1') {
                    onSearch = false;
                  } else {
                    listSearch.clear();
                    widget.listCampaign.forEach((element) {
                      if (element.refCompanyIdCompanyDto!.id == value.id) {
                        listSearch.add(element);
                      }
                    });
                    onSearch = true;
                  }

                  if (widget.isCompleted) {
                    listSearch.sort((a, b) => DateTime.parse(b.updatedTime!)
                        .compareTo(DateTime.parse(a.updatedTime!)));
                  } else {
                    listSearch.sort(
                        (a, b) => DateTime.parse(a.surveyDate as String)
                            .compareTo(DateTime.parse(b.surveyDate as String))
                        // a.status!.compareTo(b.status!)
                        );
                    listSearch.sort(
                        (a, b) => a.status!.compareTo(b.status as String));
                  }
                });
                // await Future.delayed(Duration(seconds: 1000));
              },
              items: companies.map((RefCompanyIdCompanyDto company) {
                return DropdownMenuItem<RefCompanyIdCompanyDto>(
                  value: company,
                  child: Center(
                    child: new Text(
                      company.name!,
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
                              status: widget.listCampaign[index].status,
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
                          status: widget.listCampaign[index].status,
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
        child: Column(children: [
          Padding(
            padding: EdgeInsets.only(top: padding),
            child: ChooseMonthYear(
                year: widget.year,
                month: widget.month,
                selectMonthAndYear: widget.selectMonthAndYear),
          ),
          Expanded(
            child: Center(
              child: widget.isCompleted
                  ? Text("Chưa hoàn thành chiến dịch nào")
                  : Text("Chưa có chiến dịch mới nào"),
            ),
          )
        ]),
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
