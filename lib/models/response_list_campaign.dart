import 'package:flutter/material.dart';
import 'package:googleapis/websecurityscanner/v1.dart';
import 'package:survey/models/company.dart';
import 'package:survey/models/question.dart';
import 'package:survey/screens/survey/models/model_answer.dart';

import 'campaign.dart';
import 'department.dart';

class ResponseListTemplate extends ChangeNotifier {
  QuerySchedulesDto? querySchedulesDto = new QuerySchedulesDto(data: [
    new ScheduleCampaign(
        refCampaignIdCampaignDto: RefCampaignIdCampaignDto(),
        refCompanyIdCompanyDto: RefCompanyIdCompanyDto(),
        refDepartmentIdDepartmentDto: RefDepartmentIdDepartmentDto(),
        questionResult: QuestionResult(answers: [], questions: []),
        sId: "",
        surveyDate: "",
        surveyTime: "")
  ]);

  ResponseListTemplate({this.querySchedulesDto});
  ResponseListTemplate.from(json) {
    querySchedulesDto = json != null &&
            json['scheduleresult_get_questions_and_answers_by_schedule'] != null
        ? new QuerySchedulesDto.fromJson(
            json['scheduleresult_get_questions_and_answers_by_schedule'])
        : null;
  }

  fromJson(json) {
    querySchedulesDto =
        json['scheduleresult_get_questions_and_answers_by_schedule'] != null
            ? new QuerySchedulesDto.fromJson(
                json['scheduleresult_get_questions_and_answers_by_schedule'])
            : null;
    // notifyListeners();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.querySchedulesDto != null) {
      data['scheduleresult_get_questions_and_answers_by_schedule'] =
          this.querySchedulesDto?.toJson();
    }
    return data;
  }
}

class QuerySchedulesDto extends ChangeNotifier {
  List<ScheduleCampaign>? data;
  List<QuestionResultScheduleIdDto>? questionResultScheduleIdDto;
  QuerySchedulesDto({this.data});

  QuerySchedulesDto.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ScheduleCampaign>[];
      json['data'].forEach((v) {
        data?.add(new ScheduleCampaign.fromJson(v));
        if (v['question_results'].length > 0) {
          questionResultScheduleIdDto =
              v['question_results']?.asMap().forEach((i, a) {
            questionResultScheduleIdDto
                ?.add(new QuestionResultScheduleIdDto.fromJson(
              a,
              v['campaign']['questions'][i],
            ));
          });
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ScheduleCampaign extends ChangeNotifier {
  String? sId;
  String? surveyDate;
  String? surveyTime;
  String? status;
  String? updatedTime;
  RefCampaignIdCampaignDto? refCampaignIdCampaignDto;
  RefDepartmentIdDepartmentDto? refDepartmentIdDepartmentDto;
  RefCompanyIdCompanyDto? refCompanyIdCompanyDto;
  QuestionResult? questionResult;
  List<QuestionResultScheduleIdDto>? questionResultScheduleIdDto;
  List<Questions>? questions;
  ScheduleCampaign(
      {this.sId,
      this.surveyDate,
      this.surveyTime,
      this.refCampaignIdCampaignDto,
      this.refDepartmentIdDepartmentDto,
      this.refCompanyIdCompanyDto,
      this.questionResult,
      this.status,
      this.updatedTime,
      // no use
      this.questionResultScheduleIdDto,
      // no use
      this.questions});

  ScheduleCampaign.fromJson(json) {
    updatedTime = json['updatedTime'];
    sId = json['_id'];
    surveyDate = json['survey_date'];
    surveyTime = json['survey_time'];
    status = json['status'];

    refCampaignIdCampaignDto = json['campaign'] != null
        ? new RefCampaignIdCampaignDto.fromJson(json['campaign'])
        : null;
    refCompanyIdCompanyDto = json['company'] != null
        ? new RefCompanyIdCompanyDto.fromJson(json['company'])
        : null;
    refDepartmentIdDepartmentDto = json['department'] != null
        ? new RefDepartmentIdDepartmentDto.fromJson(
            json['department'], refCompanyIdCompanyDto!.name)
        : null;
    if (json['campaign']['question_list'] != null &&
        json['campaign']['question_list'].length > 0) {
      questions = [];
      var list = json['campaign']['questions'];

      json['campaign']['question_list'].asMap().forEach((i, v) {
        var index = list.indexWhere((e) => e["questionTemplateId"] == v['_id']);
        double maxScore = 0;

        var y = json['campaign']['questions'][index];

        if (json['campaign']['questions'][index]['auto_mark'] == true &&
            v['answer_type'] == "MULTIPLECHOOSE") {
          // print(v);
          // print(y);
          // if (v['choice'] != null) {
          // v['choice']!.reduce((a, b) {
          //   return a + b['score'];
          // });
          // (v['choices'] as List).forEach((a) {
          //   if (a['score'] != null) {
          //     maxScore += (a['score'] as int);
          //   } else {}
          // });
          // }
          if (v['choices'] != null) {
            for (var i = 0; i < v['choices'].length; i++) {
              print('score: ${v['choices'][i]['score']}');
              if (v['choices'][i]['score'] != null) {
                maxScore = maxScore + (v['choices'][i]['score']);
                print('score: ${v['choices'][i]['score']}');
              } else {}
            }
          }

          // (v['choices']).forEach((a) {
          //   if (a['score'] != null) {
          //     return maxScore += (a['score'] as int);
          //   } else {}
          // });
        } else if (json['campaign']['questions'][index]['auto_mark'] == true &&
            v['answer_type'] == "ONECHOOSE") {
          if (v['choices'] != null &&
              double.tryParse(v['choices'][0]['score'].toString()) != null) {
            maxScore = double.parse(v['choices'][0]['score'].toString());
            for (var i = 0; i < v['choices'].length; i++) {
              if (v['choices'][i]['score'] != null) {
                if (v['choices'][i]['score'] > maxScore) {
                  maxScore = double.parse(v['choices'][i]['score'].toString());
                }
              } else {}
            }
          }
        } else {
          if (double.tryParse(json['campaign']['questions'][index]['max_score']
                  .toString()) !=
              null) {
            maxScore = double.parse(
                json['campaign']['questions'][index]['max_score'].toString());
          } else {
            maxScore = 10;
          }
        }
        print(maxScore);
        questions?.add(new Questions.fromJson(
          v,

          // json['campaign']['questions'][index]['max_score'],
          maxScore,
          // json['campaign']['questions'][required_index]['required']
          json['campaign']['questions'][index]['required'],
          json['campaign']['questions'][index]['order_no'],
          json['campaign']['questions'][index]['auto_mark'],
        ));
      });
    }

    if (json["question_results"] != null) {
      questionResult = new QuestionResult.fromJson(json['question_results'],
          json['campaign']["questions"], json['campaign']["question_list"]);
    }
    // no use
    if (json["question_results"] != null) {
      questionResultScheduleIdDto = <QuestionResultScheduleIdDto>[];
      json['question_results'].asMap().forEach((i, v) {
        questionResultScheduleIdDto?.add(
            new QuestionResultScheduleIdDto.fromJson(
                v, json['campaign']["questions"][i]));
      });
    }
  }
  // no use

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.refCampaignIdCampaignDto != null) {
      data['ref_campaignId_CampaignDto'] =
          this.refCampaignIdCampaignDto?.toJson();
    }
    if (this.refDepartmentIdDepartmentDto != null) {
      data['ref_departmentId_DepartmentDto'] =
          this.refDepartmentIdDepartmentDto?.toJson();
    }
    if (this.questionResult != null) {
      // data['question_results'] =
      //     this.questionResultScheduleIdDto?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class QuestionResult {
  List<Answers>? answers;
  String? schedualId;
  List<Questions>? questions;

  QuestionResult({this.answers, this.questions, this.schedualId});
  QuestionResult.fromJson(results, q, questionList) {
    if (results != null && results.length > 0) {
      answers = <Answers>[];
      results.asMap().forEach((i, v) {
        answers?.add(new Answers.fromJson(v));
      });
    }
    if (results.length > 0) {
      schedualId = results[0]['schedualId'];
    }

    if (questionList != null &&
        q.length == questionList.length &&
        questionList.length > 0) {
      questions = <Questions>[];
      questionList.asMap().forEach((i, v) {
        var index = q.indexWhere((e) => e["questionTemplateId"] == v['_id']);

        questions?.add(
          new Questions.fromJson(
            v,
            q[index]['max_score'],
            q[index]['required'],
            q[index]['order_no'],
            q[index]['auto_mark'],
          ),
        );
      });
    }
  }
}

class QuestionResultScheduleIdDto {
  String? id;

  int? score;
  List<Answers>? answers;
  List<Media>? media;
  List<HValues>? values;
  List<Questions>? questions;

  String? note;

  QuestionResultScheduleIdDto(
      {this.id,
      this.media,
      this.values,
      this.questions,
      this.answers,
      this.score});

  QuestionResultScheduleIdDto.fromJson(json, q) {
    id = json['_id'];

    score = json['max_score'] != null
        ? int.parse(json['max_score'].toStringAsFixed(0))
        : 0;

    if (json["question_results"] != null &&
        json["question_results"].length > 0) {
      answers = <Answers>[];
      json["question_results"].forEach((v) {
        answers?.add(new Answers.fromJson(v));
      });
    }
    // if (json['']) {}

    // questions = Questions.fromJson(json['campaign']['questions']);
    // if (json['media'] != null) {
    //   media = <Media>[];
    //   json['media'].forEach((v) {
    //     media?.add(new Media.fromJson(v));
    //   });
    // }
    // if (json['values'] != null) {
    //   values = <HValues>[];
    //   json['values'].forEach((v) {
    //     values?.add(new HValues.fromJson(v));
    //   });
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    // data['updatedTime'] = this.updatedTime;

    // if (this.media != null) {
    //   data['media'] = this.media?.map((v) => v.toJson()).toList();
    // }
    // if (this.values != null) {
    //   data['values'] = this.values?.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}

class Answers {
  String? id;
  String? scheduleId;
  String? questionTemplateId;
  String? note;
  String? createdTime;
  String? updatedTime;
  String? creator;
  String? updater;
  var score;
  String? answerText;
  double? answerNumber;
  String? gDriveLink;
  List<String>? links;
  Answers(
      {this.id,
      this.answerText,
      this.answerNumber,
      this.note,
      this.questionTemplateId,
      this.score,
      this.gDriveLink,
      this.links,
      this.scheduleId,
      this.createdTime,
      this.updatedTime,
      this.creator,
      this.updater});

  Answers.fromJson(json) {
    id = json['_id'];
    createdTime = json['createdTime'];
    updatedTime = json['updatedTime'];
    creator = json['creator'];
    updater = json['updater'];
    scheduleId = json['scheduleId'];
    questionTemplateId = json['questionTemplateId'];
    note = json['note'];
    score = json['score'];
    answerText = json['answer_text'];
    answerNumber = double.parse(json['answer_number'].toString());
    gDriveLink = json['google_drive_ids'];
    if (json['google_drive_ids'] != null) {
      links = json['google_drive_ids'].split(',');
    }
  }
}

// class Question {
//   String? questID;
//   String? type;
//   String? name;

//   Question.fromJson(Map<dynamic, dynamic>? json) {
//     questID = json!['questID'];
//     type = json['type'];
//     name = json['name'];
//   }
// }

class HValues {
  String? label;

  HValues({this.label});

  HValues.fromJson(Map<dynamic, dynamic> json) {
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    return data;
  }
}
