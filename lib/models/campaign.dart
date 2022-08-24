import 'company.dart';
import 'question.dart';

class RefCampaignIdCampaignDto {
  String? cid;
  String? name;
  String? description;
  String? startTime;
  String? endTime;
  // RefCompanyIdCompanyDto? refCompanyIdCompanyDto;
  List<Questions>? questions;

  RefCampaignIdCampaignDto(
      {this.cid,
      this.name,
      this.endTime,
      this.startTime,
      this.description = '',
      // this.refCompanyIdCompanyDto,
      this.questions});

  RefCampaignIdCampaignDto.fromJson(json) {
    print(json);
    cid = json['_id'];
    name = json['name'];
    // description = json['description'];
    // refCompanyIdCompanyDto = json[0]['company'] != null
    //     ? RefCompanyIdCompanyDto.fromJson(json['company'])
    //     : null;
    // if (json[0]['question_list'] != null) {
    //   questions = <Questions>[];
    //   json[0]['question_list'].forEach((v) {
    //     questions?.add(new Questions.fromJson(v));
    //   });
    // }
    startTime = json['start_time'];
    endTime = json['end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['name'] = this.name;
    return data;
  }
}
