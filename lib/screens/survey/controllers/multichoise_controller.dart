import 'package:flutter/material.dart';
import 'package:survey/models/question.dart';
import 'package:survey/models/response_list_campaign.dart';

class MultichoiseController extends ChangeNotifier {
  List<Poll> listData = [];
  MultichoiseController(List<Poll> list, values) {
    list.forEach((element) {
      listData.add(Poll(
          factor: element.factor, isSelected: false, label: element.label));
    });
    var lisChoices = values.split(',');
    if (lisChoices.length > 0) {
      lisChoices.forEach((element) {
        listData.firstWhere((e) => e.label == element).isSelected = true;
      });
    }
    notifyListeners();
  }
  onChange(int index, bool val) {
    listData[index].isSelected = val;
    notifyListeners();
  }
}
