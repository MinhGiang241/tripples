import 'package:flutter/material.dart';
import 'package:survey/models/question.dart';
import 'package:survey/models/response_list_campaign.dart';
import 'package:collection/collection.dart';

class MultichoiseController extends ChangeNotifier {
  List<Poll> listData = [];
  double value = 0;
  MultichoiseController(List<Poll> list, values) {
    list.asMap().forEach((i, element) {
      listData.add(Poll(
          factor: i,
          isSelected: false,
          label: element.label,
          score: element.score));
    });
    var lisChoices = values.split('</br>');
    if (values != '' && lisChoices != '' && lisChoices != null) {
      lisChoices.asMap().forEach((index, element) {
        var a = listData.firstWhereOrNull((e) => e.label == element);
        if (a != null) {
          a.isSelected = true;
          // lisChoices[index] = a;
        }
      });
    }
    print(listData);
    print(lisChoices);
    notifyListeners();
  }
  onChange(int index, bool val, Function(String)? choiceScore) {
    listData[index].isSelected = val;
    double score = 0;
    listData.forEach(
      (e) {
        if (e.isSelected == true && e.score != null) {
          score += e.score!;
          value = score;
        }
      },
    );
    if (choiceScore != null) {
      choiceScore(score.toString());
    }

    notifyListeners();
  }
}
