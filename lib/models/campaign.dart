import 'company.dart';
import 'question.dart';

class RefCampaignIdCampaignDto {
  String? id;
  String? name;
  String? description;
  String? startTime;
  String? endTime;
  RefCompanyIdCompanyDto? refCompanyIdCompanyDto;
  List<Questions>? questions;

  RefCampaignIdCampaignDto(
      {this.id,
      this.name,
      this.endTime,
      this.startTime,
      this.refCompanyIdCompanyDto,
      this.questions});

  RefCampaignIdCampaignDto.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    description = json['description'];
    refCompanyIdCompanyDto = json['ref_companyId_CompanyDto'] != null
        ? RefCompanyIdCompanyDto.fromJson(json['ref_companyId_CompanyDto'])
        : null;
    if (json['questions'] != null) {
      questions = <Questions>[];
      json['questions'].forEach((v) {
        questions?.add(new Questions.fromJson(v));
      });
    }
    startTime = json['start_time'];
    endTime = json['end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['name'] = this.name;
    return data;
  }
}
