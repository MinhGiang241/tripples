import 'package:flutter/foundation.dart';

class Questions extends ChangeNotifier {
  bool valid = true;
  String? questID;
  String? hint;
  String? title;
  String? type;
  var maxScore;
  String? note;
  bool required = false;
  List<Poll>? poll;

  Questions({
    this.questID,
    this.title,
    this.type,
    this.poll,
  });

  Questions.fromJson(json, max, isRequired) {
    questID = json['_id'];
    // hint = json['hint'];
    // note = json['note'];
    title = json['name'];
    type = json['answer_type'];
    required = isRequired != null ? true : false;
    maxScore = max;
    if (json['choices'] != null) {
      poll = <Poll>[];
      json['choices'].asMap().forEach((i, v) {
        poll?.add(new Poll.fromJson(v, i));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.questID;
    data['hint'] = this.hint;
    data['name'] = this.title;
    data['answer_type'] = this.type;
    data['score'] = this.maxScore;
    data['note'] = this.note;
    if (this.poll != null) {
      data['choices'] = this.poll?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Poll extends ChangeNotifier {
  String? label;
  int? factor;
  bool? isSelected;

  Poll({this.label, this.factor, this.isSelected = false});

  Poll.fromJson(json, index) {
    label = json['title'];
    factor = index;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.label;
    return data;
  }
}
