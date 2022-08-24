class RefCompanyIdCompanyDto {
  String? id;
  String? name;
  RefCompanyIdCompanyDto({this.id, this.name});

  RefCompanyIdCompanyDto.fromJson(json) {
    id = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }
}
