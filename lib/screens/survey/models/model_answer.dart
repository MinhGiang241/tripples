class Answer {
  // String? campaignId;
  String? id;
  String? scheduleId;
  String? tenantId;
  List<ResultsList>? data;

  Answer({this.scheduleId, this.data});

  Answer.fromJson(Map<String, dynamic> json) {
    // campaignId = json['campaign_id'];
    scheduleId = json['schedule_id'];
    if (json['resultsList'] != null) {
      data = <ResultsList>[];
      json['resultsList'].forEach((v) {
        data?.add(new ResultsList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // data['campaign_id'] = this.campaignId;
    data['schedule_id'] = this.scheduleId;
    if (this.data != null) {
      data['resultsList'] = this.data?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ResultsList {
  String? id;
  String? questionTemplateId;
  String? scheduleId;
  var score;
  String? note;
  String? google_drive_ids = '';
  var answer;

//no use
  List<Values>? values = [];
  AQuestion? question;
  List<Media>? media;
//no use

  ResultsList(
      {this.id,
      this.questionTemplateId,
      this.score,
      this.note,
      this.answer,
      this.scheduleId,
      this.google_drive_ids
      //this.question,
      //this.media
      //this.values
      });

  ResultsList.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    questionTemplateId = json['questionTemplateId'];
    score = json['score'];
    scheduleId = json['scheduleId'];
    answer = json['answer'];
    note = json['note'];
    google_drive_ids = json['google_drive_ids'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.id != null || this.id != "") {
      data['_id'] = this.id;
    }
    data['answer'] = this.answer;
    data['questionTemplateId'] = this.questionTemplateId;
    data['score'] = this.score;
    data['scheduleId'] = this.scheduleId;
    data['note'] = this.note;
    data['google_drive_ids'] = this.google_drive_ids;
    // if (this.questionTemplateId != null) data['_id'] = this.questionTemplateId;
    // data['score'] = this.score;
    // data['note'] = this.note;
    // if (this.values != null) {
    //   data['values'] = this.values?.map((v) => v.toJson()).toList();
    // }
    // if (this.question != null) {
    //   data['question'] = this.question?.toJson();
    // }
    // if (this.media != null) {
    //   data['media'] = this.media?.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}

class Values {
  String? label;

  Values({this.label});

  Values.fromJson(Map<String, dynamic> json) {
    label = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.label;
    return data;
  }
}

class AQuestion {
  String? questID;
  String? name;
  List<APoll>? poll;
  String? type;

  AQuestion({this.questID, this.name, this.poll, this.type});

  AQuestion.fromJson(Map<String, dynamic> json) {
    questID = json['questID'];
    name = json['name'];
    if (json['poll'] != null) {
      poll = <APoll>[];
      json['poll'].forEach((v) {
        poll?.add(new APoll.fromJson(v));
      });
    }
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['questID'] = this.questID;
    data['name'] = this.name;
    if (this.poll != null) {
      data['poll'] = this.poll?.map((v) => v.toJson()).toList();
    }
    data['type'] = this.type;
    return data;
  }
}

class APoll {
  String? label;

  APoll({this.label});

  APoll.fromJson(Map<String, dynamic> json) {
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    return data;
  }
}

class Media {
  String? sId;
  String? name;
  Media({this.sId, this.name});

  Media.fromJson(Map<dynamic, dynamic> json) {
    sId = json['file_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['display_name'] = this.name;
    return data;
  }
}
