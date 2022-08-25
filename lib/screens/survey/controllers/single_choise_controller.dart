import 'package:flutter/material.dart';
import 'package:survey/models/question.dart';
import 'package:survey/models/response_list_campaign.dart';

class SingleChoiseController extends ChangeNotifier {
  FocusNode otherNode = FocusNode();
  List<Poll> listData = [];
  Poll data = Poll();
  SingleChoiseController(List<Poll> list, [HValues? value]) {
    listData = list;
    // if (!list.any((element) => element.label == "Khác")) {
    //   listData.add(Poll(label: "Khác"));
    // }
    if (value != null) {
      data = listData.firstWhere((element) => element.label == value.label);
    }
    notifyListeners();
  }

  onChange(Poll? val) {
    data = val ?? Poll();
    if (data.label != "Khác") {
      otherNode.unfocus();
    } else {
      otherNode.requestFocus();
    }
    notifyListeners();
  }

  changeLableAnother(String val) {
    listData.last.label = val;
  }
}
