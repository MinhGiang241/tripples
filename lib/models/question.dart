import 'package:flutter/foundation.dart';

class Questions extends ChangeNotifier {
  bool valid = true;
  String? questID;
  String? hint;
  String? title;
  String? type;
  bool? auto_mark;
  var maxScore;
  String? note;
  bool required = false;
  List<Poll>? poll;
  String? createdTime;
  String? updatedTime;
  int? order_no;

  Questions({
    this.questID,
    this.title,
    this.type,
    this.poll,
    this.createdTime,
    this.updatedTime,
    this.auto_mark = false,
    this.order_no = 0,
  });

  Questions.fromJson(json, max, isRequired, order, automark) {
    questID = json['_id'];
    order_no = order != null ? order : 0;
    auto_mark = automark != null ? automark : false;
    title = json['name'];
    type = json['answer_type'];
    required = isRequired != null ? true : false;
    maxScore = max;
    createdTime = json['createdTime'] != null ? json['createdTime'] : '';
    updatedTime = json['updatedTime'] != null ? json['updatedTime'] : '';
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
  bool isSelected = false;
  double? score;

  Poll({
    this.label,
    this.factor,
    this.isSelected = false,
    this.score,
  });

  Poll.fromJson(json, index) {
    label = json['title'];
    score = (json['score'] != 0 &&
            double.tryParse(json['score'].toString()) != null)
        ? double.parse(json['score'].toString())
        : 0;
    factor = index;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.label;
    return data;
  }
}
