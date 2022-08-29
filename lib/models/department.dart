class RefDepartmentIdDepartmentDto {
  String? company;
  String? name;
  String? address;
  String? id;

  RefDepartmentIdDepartmentDto(
      {this.name, this.address, this.company, this.id});

  RefDepartmentIdDepartmentDto.fromJson(json, companyName) {
    company = companyName;
    name = json['name'];
    id = json["_id"];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['address'] = this.address;
    return data;
  }
}
