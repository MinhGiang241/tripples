class Questions {
  String? questID;
  String? hint;
  String? title;
  String? type;
  var maxScore;
  String? note;
  bool? require;
  List<Poll>? poll;

  Questions({this.questID, this.title, this.type, this.poll});

  Questions.fromJson(Map<String, dynamic> json) {
    questID = json['questID'];
    hint = json['hint'];
    title = json['title'];
    type = json['type'];
    require = json['required'];
    maxScore = json['max_score'];
    if (json['poll'] != null) {
      poll = <Poll>[];
      json['poll'].forEach((v) {
        poll?.add(new Poll.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['questID'] = this.questID;
    data['hint'] = this.hint;
    data['name'] = this.title;
    data['type'] = this.type;
    data['score'] = this.maxScore;
    data['note'] = this.note;
    if (this.poll != null) {
      data['poll'] = this.poll?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Poll {
  String? label;
  int? factor;
  bool? isSelected;

  Poll({this.label, this.factor, this.isSelected = false});

  Poll.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    factor = json['factor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    return data;
  }
}
