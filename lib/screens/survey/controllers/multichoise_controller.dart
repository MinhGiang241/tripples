import 'package:flutter/material.dart';
import 'package:survey/models/question.dart';
import 'package:survey/models/response_list_campaign.dart';
import 'package:collection/collection.dart';

class MultichoiseController extends ChangeNotifier {
  List<Poll> listData = [];
  MultichoiseController(List<Poll> list, values) {
    list.asMap().forEach((i, element) {
      listData.add(Poll(factor: i, isSelected: false, label: element.label));
    });
    var lisChoices = values.split(',');
    if (values != '' && lisChoices != '' && lisChoices != null) {
      lisChoices.forEach((element) {
        var e = listData.firstWhereOrNull((e) => e.label == element);
        if (e != null) {
          e.isSelected = true;
        }
      });
    }
    print(listData);
    print(lisChoices);
    notifyListeners();
  }
  onChange(int index, bool val) {
    listData[index].isSelected = val;
    notifyListeners();
  }
}
