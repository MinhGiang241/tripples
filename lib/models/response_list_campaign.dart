import 'package:googleapis/websecurityscanner/v1.dart';
import 'package:survey/models/company.dart';
import 'package:survey/models/question.dart';
import 'package:survey/screens/survey/models/model_answer.dart';

import 'campaign.dart';
import 'department.dart';

class ResponseListTemplate {
  QuerySchedulesDto? querySchedulesDto;

  ResponseListTemplate({this.querySchedulesDto});

  ResponseListTemplate.fromJson(Map<String, dynamic> json) {
    querySchedulesDto =
        json['scheduleresult_get_questions_and_answers_by_schedule'] != null
            ? new QuerySchedulesDto.fromJson(
                json['scheduleresult_get_questions_and_answers_by_schedule'])
            : null;
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

class QuerySchedulesDto {
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
            questionResultScheduleIdDto?.add(
                new QuestionResultScheduleIdDto.fromJson(
                    a, v['campaign']['questions'][i]));
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

class ScheduleCampaign {
  String? sId;
  String? surveyDate;
  String? surveyTime;
  RefCampaignIdCampaignDto? refCampaignIdCampaignDto;
  RefDepartmentIdDepartmentDto? refDepartmentIdDepartmentDto;
  RefCompanyIdCompanyDto? refCompanyIdCompanyDto;
  List<QuestionResultScheduleIdDto>? questionResultScheduleIdDto;
  List<Questions>? questions;
  ScheduleCampaign(
      {this.sId,
      this.surveyDate,
      this.surveyTime,
      this.refCampaignIdCampaignDto,
      this.refDepartmentIdDepartmentDto,
      this.refCompanyIdCompanyDto,
      this.questionResultScheduleIdDto,
      this.questions});

  ScheduleCampaign.fromJson(json) {
    sId = json['_id'];
    surveyDate = json['survey_date'];
    surveyTime = json['survey_time'];

    refCampaignIdCampaignDto = json['campaign'] != null
        ? new RefCampaignIdCampaignDto.fromJson(json['campaign'])
        : null;
    refCompanyIdCompanyDto = json['company'] != null
        ? new RefCompanyIdCompanyDto.fromJson(json['company'])
        : null;
    refDepartmentIdDepartmentDto = json['department'] != null
        ? new RefDepartmentIdDepartmentDto.fromJson(json['department'])
        : null;
    if (json['campaign']['question_list'] != null &&
        json['campaign']['question_list'].length > 0) {
      questions = [];
      json['campaign']['question_list'].asMap().forEach((i, v) {
        questions?.add(new Questions.fromJson(
            v,
            json['campaign']['questions'][i]['max_score'],
            json['campaign']['questions'][i]['required']));
      });
    }

    if (json["question_results"] != null) {
      questionResultScheduleIdDto = <QuestionResultScheduleIdDto>[];
      json['question_results'].asMap().forEach((i, v) {
        questionResultScheduleIdDto?.add(
            new QuestionResultScheduleIdDto.fromJson(
                v, json['campaign']["questions"][i]));
      });
    }
  }

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
    if (this.questionResultScheduleIdDto != null) {
      data['question_result'] =
          this.questionResultScheduleIdDto?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class QuestionResult {
  String? id;
  String? schedualId;
  Answer? data;
}

class QuestionResultScheduleIdDto {
  String? id;

  int? score;
  List<Answers>? answers;
  List<Media>? media;
  List<HValues>? values;
  Question? question;

  String? note;

  QuestionResultScheduleIdDto(
      {this.id,
      this.media,
      this.values,
      this.question,
      this.answers,
      this.score});

  QuestionResultScheduleIdDto.fromJson(json, q) {
    id = json['_id'];

    score = q['max_score'];

    if (json["question_results"] != null &&
        json["question_results"].length > 0) {
      answers = <Answers>[];
      json["question_results"].forEach((v) {
        answers?.add(new Answers.fromJson(v));
      });
    }

    // question = Question.fromJson(json['campaign']['questions']);
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

    if (this.media != null) {
      data['media'] = this.media?.map((v) => v.toJson()).toList();
    }
    if (this.values != null) {
      data['values'] = this.values?.map((v) => v.toJson()).toList();
    }
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
  int? score;
  var answer;
  String? gDriveLink;
  List<String>? links;
  Answers(
      {this.id,
      this.answer,
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
    answer = json['answer'];
    gDriveLink = json['google_drive_ids'];
    links = json['google_drive_ids'].split(',');
  }
}

class Question {
  String? questID;
  String? type;
  String? name;

  Question.fromJson(Map<dynamic, dynamic>? json) {
    questID = json!['questID'];
    type = json['type'];
    name = json['name'];
  }
}

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
