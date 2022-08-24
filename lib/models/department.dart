class RefDepartmentIdDepartmentDto {
  String? name;
  String? address;

  RefDepartmentIdDepartmentDto({this.name, this.address});

  RefDepartmentIdDepartmentDto.fromJson(json) {
    name = json['name'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['address'] = this.address;
    return data;
  }
}
