import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:survey/constants.dart';

class HomeTabBar extends StatelessWidget {
  const HomeTabBar({
    Key? key,
    required this.tabController,
  }) : super(key: key);

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return TabBar(
        controller: tabController,
        unselectedLabelColor: Colors.black.withOpacity(0.5),
        labelColor: Colors.black,
        indicatorPadding: EdgeInsets.symmetric(horizontal: padding / 2),
        indicatorColor: Theme.of(context).primaryColor,
        tabs: [
          Tab(
            child: AutoSizeText(
              "Việc cần làm".toUpperCase(),
              maxLines: 1,
              minFontSize: 1,
              style: TextStyle(fontSize: 12),
            ),
          ),
          Tab(
            child: AutoSizeText(
              "Đã hoàn thành".toUpperCase(),
              maxLines: 1,
              minFontSize: 1,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ]);
  }
}
