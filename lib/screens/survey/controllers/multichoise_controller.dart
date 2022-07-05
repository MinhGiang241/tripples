import 'package:flutter/material.dart';
import 'package:survey/models/question.dart';
import 'package:survey/models/response_list_campaign.dart';

class MultichoiseController extends ChangeNotifier {
  List<Poll> listData = [];
  MultichoiseController(List<Poll> list, List<HValues> values) {
    list.forEach((element) {
      listData.add(Poll(
          factor: element.factor, isSelected: false, label: element.label));
    });
    if (values.length > 0) {
      values.forEach((element) {
        listData.firstWhere((e) => e.label == element.label).isSelected = true;
      });
    }
    notifyListeners();
  }
  onChange(int index, bool val) {
    listData[index].isSelected = val;
    notifyListeners();
  }
}
