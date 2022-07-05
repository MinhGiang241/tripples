import 'package:survey/models/company.dart';
import 'package:survey/screens/survey/models/model_answer.dart';

import 'campaign.dart';
import 'department.dart';

class ResponseListTemplate {
  QuerySchedulesDto? querySchedulesDto;

  ResponseListTemplate({this.querySchedulesDto});

  ResponseListTemplate.fromJson(Map<String, dynamic> json) {
    querySchedulesDto = json['query_Schedules_dto'] != null
        ? new QuerySchedulesDto.fromJson(json['query_Schedules_dto'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.querySchedulesDto != null) {
      data['query_Schedules_dto'] = this.querySchedulesDto?.toJson();
    }
    return data;
  }
}

class QuerySchedulesDto {
  List<Campaign>? data;
  List<QuestionResultScheduleIdDto>? questionResultScheduleIdDto;
  QuerySchedulesDto({this.data});

  QuerySchedulesDto.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Campaign>[];
      json['data'].forEach((v) {
        data?.add(new Campaign.fromJson(v));
      });
      if (json['data'].length > 0) {
        questionResultScheduleIdDto =
            json['data'][0]['question_result']?.forEach((v) {
          questionResultScheduleIdDto
              ?.add(new QuestionResultScheduleIdDto.fromJson(v));
        });
      }
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

class Campaign {
  String? sId;
  String? appoitmentDate;
  String? appoitmentTime;
  RefCampaignIdCampaignDto? refCampaignIdCampaignDto;
  RefDepartmentIdDepartmentDto? refDepartmentIdDepartmentDto;
  RefCompanyIdCompanyDto? refCompanyIdCompanyDto;
  List<QuestionResultScheduleIdDto>? questionResultScheduleIdDto;
  Campaign(
      {this.sId,
      this.appoitmentDate,
      this.appoitmentTime,
      this.refCampaignIdCampaignDto,
      this.refDepartmentIdDepartmentDto,
      this.refCompanyIdCompanyDto,
      this.questionResultScheduleIdDto});

  Campaign.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    appoitmentDate = json['appointment_date'];
    appoitmentTime = json['appointment_time'];

    refCampaignIdCampaignDto = json['ref_campaignId_CampaignDto'] != null
        ? new RefCampaignIdCampaignDto.fromJson(
            json['ref_campaignId_CampaignDto'])
        : null;
    refDepartmentIdDepartmentDto =
        json['ref_departmentId_DepartmentDto'] != null
            ? new RefDepartmentIdDepartmentDto.fromJson(
                json['ref_departmentId_DepartmentDto'])
            : null;
    refCompanyIdCompanyDto = json['ref_companyId_CompanyDto'] != null
        ? new RefCompanyIdCompanyDto.fromJson(json['ref_companyId_CompanyDto'])
        : null;
    if (json['question_result'] != null) {
      questionResultScheduleIdDto = <QuestionResultScheduleIdDto>[];
      json['question_result'].forEach((v) {
        questionResultScheduleIdDto
            ?.add(new QuestionResultScheduleIdDto.fromJson(v));
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

class QuestionResultScheduleIdDto {
  String? sId;
  String? updatedTime;
  var score;
  String? note;
  List<Media>? media;
  List<HValues>? values;
  Question? question;

  QuestionResultScheduleIdDto(
      {this.sId,
      this.updatedTime,
      this.score,
      this.note,
      this.media,
      this.values,
      this.question});

  QuestionResultScheduleIdDto.fromJson(Map<dynamic, dynamic> json) {
    sId = json['_id'];
    updatedTime = json['updatedTime'];
    score = json['score'];
    note = json['note'];
    question = Question.fromJson(json['question']);
    if (json['media'] != null) {
      media = <Media>[];
      json['media'].forEach((v) {
        media?.add(new Media.fromJson(v));
      });
    }
    if (json['values'] != null) {
      values = <HValues>[];
      json['values'].forEach((v) {
        values?.add(new HValues.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['updatedTime'] = this.updatedTime;
    data['score'] = this.score;
    data['note'] = this.note;
    if (this.media != null) {
      data['media'] = this.media?.map((v) => v.toJson()).toList();
    }
    if (this.values != null) {
      data['values'] = this.values?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Question {
  String? questID;
  String? type;
  String? name;

  Question.fromJson(Map<dynamic, dynamic> json) {
    questID = json['questID'];
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
